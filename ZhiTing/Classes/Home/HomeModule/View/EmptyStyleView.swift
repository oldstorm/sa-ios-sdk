//
//  EmptyStyleView.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/24.
//


import UIKit

class EmptyStyleView: UIView {
    enum Style {
        case noNetwork
        case noAuth
        case noContent
        case noList
        case developing
        case noRoom
        case noDepartment
        case noHistory
        case noToken
        case noMember
        case noDepartmentMember
        case noFeedbacks
    }

    var style: Style = .noNetwork
    
    var buttonCallback: (() -> ())?
    
    lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }

    private lazy var emptyImage = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_noNetwork)
    }

    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
        $0.textAlignment = .center
        $0.text = "暂无网络".localizedString
    }
    
    lazy var button = LoadingButton().then {
        $0.setTitle("重试".localizedString, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 4
        $0.titleColor = .custom(.blue_2da3f6)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.blue_2da3f6).cgColor
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, style: Style, buttonCallback: (() -> ())? = nil) {
        self.init(frame: frame)
        self.style = style
        self.buttonCallback = buttonCallback
        
        switch style {
        case .noNetwork:
            emptyImage.image = .assets(.icon_noNetwork)
            button.isHidden = false
            button.setTitle("重试".localizedString, for: .normal)
            titleLabel.text = "暂无网络".localizedString
            button.titleColor = .custom(.blue_2da3f6)
            button.backgroundColor = .clear
        case .noAuth:
            emptyImage.image = .assets(.icon_noAuth)
            button.isHidden = true
            titleLabel.text = "暂无权限".localizedString
        case .noContent:
            emptyImage.image = .assets(.icon_noContent)
            button.isHidden = true
            titleLabel.text = "暂无内容".localizedString
        case .noList:
            emptyImage.image = .assets(.icon_noList)
            button.isHidden = true
            titleLabel.text = "暂无列表".localizedString
        case .developing:
            emptyImage.image = .assets(.icon_developing)
            button.isHidden = true
            titleLabel.text = "正在开发中".localizedString
        case .noRoom:
            emptyImage.image = .assets(.icon_noRoom)
            button.isHidden = true
            titleLabel.text = "暂无房间".localizedString
            
        case .noDepartment:
            emptyImage.image = .assets(.icon_noRoom)
            button.isHidden = true
            titleLabel.text = "暂无部门".localizedString
            
        case .noHistory:
            emptyImage.image = .assets(.icon_noHistory)
            button.isHidden = true
            titleLabel.text = "暂无日志".localizedString
            
        case .noToken:
            emptyImage.image = .assets(.noToken)
            button.isHidden = true
            titleLabel.text = "暂无凭证或已过期".localizedString
            
        case .noMember:
            emptyImage.image = .assets(.icon_noContent)
            button.isHidden = true
            titleLabel.text = "暂无成员".localizedString
            
        case .noDepartmentMember:
            emptyImage.image = .assets(.icon_noRoom)
            button.isHidden = true
            titleLabel.text = "暂无成员".localizedString
            
        case .noFeedbacks:
            emptyImage.image = .assets(.icon_noList)
            button.isHidden = true
            titleLabel.text = "暂无反馈记录".localizedString
        }
        
        button.buttonState = .normal
        
    }
    
    private func setupViews() {
        container.backgroundColor = UIColor.custom(.white_ffffff).withAlphaComponent(0.8)
        container.layer.cornerRadius = 10
        addSubview(container)
        container.addSubview(emptyImage)
        container.addSubview(titleLabel)
        container.addSubview(button)
        
        button.clickCallBack = { [weak self] _ in
            self?.buttonCallback?()
        }
    }
    
    private func setConstrains() {
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        button.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(button.snp.top).offset(-36.5)
        }
        
        emptyImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(titleLabel.snp.top).offset(-11)
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }
    }
    
}
