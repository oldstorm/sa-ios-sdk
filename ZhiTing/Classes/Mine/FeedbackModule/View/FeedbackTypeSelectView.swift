//
//  FeedbackTypeSelectView.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/22.
//

import Foundation
import UIKit
import Combine


class FeedbackTypeSelectView: UIView {
    var selectedType: FeedbackType = .problem(category: nil)
    
    private lazy var typeChangedPublisher = CurrentValueSubject<FeedbackType, Never>(.problem(category: nil))
    
    var typeChanged: AnyPublisher<FeedbackType, Never> {
        typeChangedPublisher.eraseToAnyPublisher()
    }

    private lazy var btnW: CGFloat = (Screen.screenWidth - 70) / 3
    private lazy var btnH: CGFloat = btnW * 2 / 5

    // MARK: - Section1 Views
    private lazy var typeLabel = Label().then {
        $0.attributed.text = "\("* ", .foreground(.custom(.red_fe0000)), .font(.font(size: 14, type: .bold)))\("类型".localizedString, .foreground(.custom(.black_3f4663)), .font(.font(size: 14, type: .bold)))"
    }
    
    private lazy var typeBtn1 = Button().then {
        $0.setTitle("遇到问题".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: 12, type: .bold)
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .selected)
        $0.layer.cornerRadius = 2
        $0.layer.borderColor = UIColor.custom(.blue_2da3f6).cgColor
        $0.layer.borderWidth = 1
        $0.isSelected = true
    }
    
    private lazy var typeBtn1Corner = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.corner_select_icon)
        $0.isHidden = false
    }
    
    private lazy var typeBtn2 = Button().then {
        $0.setTitle("提建议/意见".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: 12, type: .bold)
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .selected)
        $0.layer.cornerRadius = 2
        $0.layer.borderColor = UIColor.custom(.gray_94a5be).cgColor
        $0.layer.borderWidth = 1
        $0.isSelected = false
    }
    
    private lazy var typeBtn2Corner = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.corner_select_icon)
        $0.isHidden = true
    }
    
    // MARK: - Section2 Views
    
    private lazy var categoryLabel = Label().then {
        $0.attributed.text = "\("* ", .foreground(.custom(.red_fe0000)), .font(.font(size: 14, type: .bold)))\("选择分类".localizedString, .foreground(.custom(.black_3f4663)), .font(.font(size: 14, type: .bold)))"
    }
    
    private lazy var categoryCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: btnW, height: btnH)
        flowLayout.minimumLineSpacing = 15
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(FeedbackTypeSelectViewCollectionCell.self, forCellWithReuseIdentifier: FeedbackTypeSelectViewCollectionCell.reusableIdentifier)
        return cv
    }()

    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupviews() {
        addSubview(typeLabel)
        addSubview(typeBtn1)
        typeBtn1.addSubview(typeBtn1Corner)
        addSubview(typeBtn2)
        typeBtn2.addSubview(typeBtn2Corner)
        addSubview(categoryLabel)
        addSubview(categoryCollectionView)
        addSubview(line)
        
        typeBtn1.clickCallBack = { [weak self] btn in
            btn.isSelected = true
            btn.layer.borderColor = UIColor.custom(.blue_2da3f6).cgColor
            self?.typeBtn1Corner.isHidden = false
            
            self?.typeBtn2.isSelected = false
            self?.typeBtn2.layer.borderColor = UIColor.custom(.gray_94a5be).cgColor
            self?.typeBtn2Corner.isHidden = true
            
            self?.selectedType = .problem(category: nil)
            self?.typeChangedPublisher.send(.problem(category: nil))
            self?.categoryCollectionView.reloadData()
        }
        
        typeBtn2.clickCallBack = { [weak self] btn in
            btn.isSelected = true
            btn.layer.borderColor = UIColor.custom(.blue_2da3f6).cgColor
            self?.typeBtn2Corner.isHidden = false
            
            self?.typeBtn1.isSelected = false
            self?.typeBtn1.layer.borderColor = UIColor.custom(.gray_94a5be).cgColor
            self?.typeBtn1Corner.isHidden = true
            
            self?.selectedType = .suggestion(category: nil)
            self?.typeChangedPublisher.send(.suggestion(category: nil))
            self?.categoryCollectionView.reloadData()
        }

    }
    
    private func setupConstraints() {
        typeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(20)
        }
        
        typeBtn1.snp.makeConstraints {
            $0.top.equalTo(typeLabel.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(15)
            $0.width.equalTo(btnW)
            $0.height.equalTo(btnH)
        }
        
        typeBtn1Corner.snp.makeConstraints {
            $0.height.width.equalTo(15)
            $0.top.right.equalToSuperview()
        }

        typeBtn2.snp.makeConstraints {
            $0.centerY.equalTo(typeBtn1.snp.centerY)
            $0.left.equalTo(typeBtn1.snp.right).offset(20)
            $0.width.equalTo(btnW)
            $0.height.equalTo(btnH)
        }
        
        typeBtn2Corner.snp.makeConstraints {
            $0.height.width.equalTo(15)
            $0.top.right.equalToSuperview()
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(typeBtn1.snp.bottom).offset(25)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(btnH * 2 + 15)
        }


        line.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom).offset(20)
            $0.height.equalTo(0.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview()
        }

    }
    
    

}

extension FeedbackTypeSelectView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedType {
        case .problem:
            return FeedbackProblemCategory.allCases.count
        case .suggestion:
            return FeedbackSuggestionCategory.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: FeedbackTypeSelectViewCollectionCell.reusableIdentifier, for: indexPath) as! FeedbackTypeSelectViewCollectionCell
        switch selectedType {
        case .problem(let category):
            let problemType = FeedbackProblemCategory.allCases[indexPath.row]
            cell.problemType = problemType
            cell._selected = problemType == category

        case .suggestion(let category):
            let suggestionType = FeedbackSuggestionCategory.allCases[indexPath.row]
            cell.suggestionType = suggestionType
            cell._selected = suggestionType == category
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch selectedType {
        case .problem:
            let problemType = FeedbackProblemCategory.allCases[indexPath.row]
            selectedType = .problem(category: problemType)
            typeChangedPublisher.send(.problem(category: problemType))
        case .suggestion:
            let suggestionType = FeedbackSuggestionCategory.allCases[indexPath.row]
            selectedType = .suggestion(category: suggestionType)
            typeChangedPublisher.send(.suggestion(category: suggestionType))
        }
        collectionView.reloadData()
    }
    
    
}


// MARK: - Cells
class FeedbackTypeSelectViewCell: UITableViewCell {
    
    lazy var selectView = FeedbackTypeSelectView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(selectView)
        selectView.snp.makeConstraints {
            $0.edges.equalToSuperview().priority(.high)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class FeedbackTypeSelectViewCollectionCell: UICollectionViewCell, ReusableView {
    var _selected = false {
        didSet {
            btn.isSelected = _selected
            btnCorner.isHidden = !_selected
            btn.layer.borderColor = _selected ? UIColor.custom(.blue_2da3f6).cgColor : UIColor.custom(.gray_94a5be).cgColor

        }
    }

    var suggestionType: FeedbackSuggestionCategory? {
        didSet {
            guard let type = suggestionType else { return }
            btn.setTitle(type.title, for: .normal)
        }
    }

    var problemType: FeedbackProblemCategory? {
        didSet {
            guard let type = problemType else { return }
            btn.setTitle(type.title, for: .normal)
        }
    }
    
    

    private lazy var btn = Button().then {
        $0.setTitle(" ".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: 12, type: .bold)
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .selected)
        $0.layer.cornerRadius = 2
        $0.layer.borderColor = UIColor.custom(.gray_94a5be).cgColor
        $0.layer.borderWidth = 1
        $0.isSelected = false
        $0.isUserInteractionEnabled = false
    }
    
    private lazy var btnCorner = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.corner_select_icon)
        $0.isHidden = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(btn)
        btn.addSubview(btnCorner)
        btn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        btnCorner.snp.makeConstraints {
            $0.height.width.equalTo(15)
            $0.top.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
