//
//  AddAreaAlert.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/12.
//

import Foundation
import UIKit

// MARK: - AddAreaAlert
class AddAreaAlert: UIView {
    var types = AddAreaType.allCases

    var selectCallback: ((_ type: AddAreaType) -> ())?


    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    
    private lazy var closeButton = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.isEnhanceClick = true
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.register(AddAreaAlertCell.self, forCellReuseIdentifier: AddAreaAlertCell.reusableIdentifier)
        $0.rowHeight = 60
        $0.delegate = self
        $0.dataSource = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(closeButton)
        containerView.addSubview(line)
        containerView.addSubview(tableView)
        
    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(10)
            $0.height.equalTo(200)
        }
        
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16.5)
            $0.right.equalToSuperview().offset(-15)
            $0.height.width.equalTo(14)
        }
        
        line.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.left.right.equalToSuperview()
            $0.top.equalTo(closeButton.snp.bottom).offset(17)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
        }
    }

    @objc private func close() {
        removeFromSuperview()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
        
        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
        
        
    }
}

extension AddAreaAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddAreaAlertCell.reusableIdentifier, for: indexPath) as! AddAreaAlertCell
        cell.title.text = types[indexPath.row].title
        cell.icon.image = types[indexPath.row].icon

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.removeFromSuperview()
        selectCallback?(types[indexPath.row])
        
    }
    
}


extension AddAreaAlert {
    class AddAreaAlertCell: UITableViewCell, ReusableView {
        lazy var icon = ImageView().then {
            $0.image = .assets(.icon_brand)
        }
        
        lazy var title = Label().then {
            $0.text = "  ".localizedString
            $0.font = .font(size: 14, type: .medium)
            $0.textColor = .custom(.black_3f4663)
        }
        
        
        private lazy var line = UIView().then { $0.backgroundColor = .custom(.gray_eeeeee) }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setEnable(_ enable: Bool) {
            if enable {
                isUserInteractionEnabled = true
                contentView.subviews.forEach { $0.alpha = 1 }
            } else {
                isUserInteractionEnabled = false
                contentView.subviews.forEach { $0.alpha = 0.5 }
            }
        }

        private func setupViews() {
            contentView.backgroundColor = .custom(.white_ffffff)
            contentView.addSubview(icon)
            contentView.addSubview(title)
            contentView.addSubview(line)

            
            icon.snp.makeConstraints {
                $0.width.equalTo(16)
                $0.height.equalTo(16)
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(19.5)
            }
            
            title.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(icon.snp.right).offset(14.5)
            }
            
            
            line.snp.makeConstraints {
                $0.bottom.equalToSuperview()
                $0.height.equalTo(0.5)
                $0.right.equalToSuperview()
                $0.left.equalToSuperview()
            }
        }
        
    }

}

extension AddAreaAlert {
    enum AddAreaType: CaseIterable {
        case family
        case company
        
        var title: String {
            switch self {
            case .family:
                return "添加家庭".localizedString
            case .company:
                return "添加公司".localizedString
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .family:
                return .assets(.icon_addFamily)
            case .company:
                return .assets(.icon_addCompany)
            }
        }
    }
}
