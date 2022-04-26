//
//  DepartmentAddMemberHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/17.
//

import Foundation
import UIKit

class DepartmentAddMemberHeader: UIView {
    var cancellCallback: ((User) -> ())?

    var members = [User]()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 15
        layout.scrollDirection = .horizontal
        layout.sectionInset.left = 15

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .custom(.white_ffffff)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DepartmentAddMemberHeaderCell.self, forCellWithReuseIdentifier: DepartmentAddMemberHeaderCell.reusableIdentifier)
        return collectionView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.bottom.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
    }
    
    func update(_ members: [User]) {
        self.members = members
        collectionView.reloadData()
        if members.count > 0 {
            collectionView.scrollToItem(at: IndexPath(row: members.count - 1, section: 0), at: .right, animated: true)
        }
        
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension DepartmentAddMemberHeader: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DepartmentAddMemberHeaderCell.reusableIdentifier, for: indexPath) as! DepartmentAddMemberHeaderCell
        cell.member = members[indexPath.row]
        cell.cancellCallback = cancellCallback

        return cell
    }
    
    
}




fileprivate class DepartmentAddMemberHeaderCell: UICollectionViewCell, ReusableView {
    var cancellCallback: ((User) -> ())?

    var member: User? {
        didSet {
            guard let member = member else {
                return
            }
            
//            icon.setImage(urlString: member.avatar_url, placeHolder: .assets(.default_avatar))
            label.text = member.nickname
        }
    }

    private lazy var icon = ImageView().then {
        $0.image = .assets(.default_avatar)
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private lazy var label = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.blue_2da3f6).withAlphaComponent(0.1)
        $0.layer.cornerRadius = 15
    }

    private lazy var cancelBtn = Button().then {
        $0.setImage(.assets(.close_button_rounded), for: .normal)
        $0.isEnhanceClick = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(container)
        container.addSubview(icon)
        container.addSubview(label)
        contentView.addSubview(cancelBtn)
        
        cancelBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            if let user = self.member {
                self.cancellCallback?(user)
            }
        }
    }
    
    private func setupConstraints() {
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        icon.snp.makeConstraints {
            $0.left.equalToSuperview().offset(3.5)
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
            $0.height.width.equalTo(24)
        }
        
        label.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.left.equalTo(icon.snp.right).offset(5)
            $0.right.equalToSuperview().offset(-12)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.width.height.equalTo(10)
            $0.centerY.equalTo(container.snp.top).offset(4)
            $0.centerX.equalTo(container.snp.right).offset(-4)
        }


    }

}
