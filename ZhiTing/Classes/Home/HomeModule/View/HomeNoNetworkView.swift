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
        
    }

    var style: Style = .noNetwork
    
    var retryCallback: (() -> ())?
    
    private lazy var container = UIView().then {
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
    
    private lazy var retryButton = Button().then {
        $0.setTitle("重试".localizedString, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 4
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
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
        self.retryCallback = buttonCallback
        
        switch style {
        case .noNetwork:
            emptyImage.image = .assets(.icon_noNetwork)
            retryButton.isHidden = false
            retryButton.setTitle("重试".localizedString, for: .normal)
            titleLabel.text = "暂无网络".localizedString
        
            
        case .noAuth:
            emptyImage.image = .assets(.icon_noAuth)
            retryButton.isHidden = true
            titleLabel.text = "暂无权限".localizedString
        case .noContent:
            emptyImage.image = .assets(.icon_noContent)
            retryButton.isHidden = true
            titleLabel.text = "暂无内容".localizedString
        case .noList:
            emptyImage.image = .assets(.icon_noList)
            retryButton.isHidden = true
            titleLabel.text = "暂无列表".localizedString
        case .developing:
            emptyImage.image = .assets(.icon_developing)
            retryButton.isHidden = true
            titleLabel.text = "正在开发中".localizedString
        }
        
    }
    
    private func setupViews() {
        container.backgroundColor = UIColor.custom(.white_ffffff).withAlphaComponent(0.8)
        container.layer.cornerRadius = 10
        addSubview(container)
        container.addSubview(emptyImage)
        container.addSubview(titleLabel)
        container.addSubview(retryButton)
        
        retryButton.clickCallBack = { [weak self] _ in
            self?.retryCallback?()
        }
    }
    
    private func setConstrains() {
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        retryButton.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(retryButton.snp.top).offset(-36.5)
        }
        
        emptyImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(titleLabel.snp.top).offset(-11)
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }
    }
    
}
