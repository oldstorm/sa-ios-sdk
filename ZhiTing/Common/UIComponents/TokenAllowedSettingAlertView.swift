//
//  TokenAllowedSettingAlertView.swift
//  ZhiTing
//
//  Created by zy on 2021/10/20.
//

import UIKit

class TokenAllowedSettingAlertView: UIView {
    
    var sureCallback: ((_ tap: Int) -> ())?
    var cancelCallback: (() -> ())?

    var removeWithSure = true
    
    var isSureBtnLoading = false {
        didSet {
            sureBtn.selectedChangeView(isLoading: isSureBtnLoading)
        }
    }
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.3)
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.clipsToBounds = true
    }

    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(16), type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.text = "用户凭证".localizedString
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private lazy var tipsSubscriptLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(13), type: .regular)
        $0.text = "用户凭证是访问智慧中心的密钥，请选择是否允许成员通过云端获取找回凭证。".localizedString
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private lazy var allowChooseButton = Button().then {
        $0.setImage(.assets(.unselected_tick), for: .normal)
        $0.setImage(.assets(.selected_tick), for: .selected)
        $0.isSelected = false
        $0.addTarget(self, action: #selector(allowChooseButtonOnPress), for: .touchUpInside)
    }
    
    private lazy var allowChooseLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(13), type: .bold)
        $0.text = "允许找回".localizedString
        $0.textAlignment = .left
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(allowChooseButtonOnPress)))
    }
    
    private lazy var allowChooseDescriptionLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(11), type: .bold)
        $0.text = "成员可以在任何客户端找回凭证连接智慧中心".localizedString
        $0.textAlignment = .left
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(allowChooseButtonOnPress)))
    }
    
    private lazy var noAllowChooseButton = Button().then {
        $0.setImage(.assets(.unselected_tick), for: .normal)
        $0.setImage(.assets(.selected_tick), for: .selected)
        $0.isSelected = true
        $0.addTarget(self, action: #selector(noAllowChooseButtonOnPress), for: .touchUpInside)
    }
    
    private lazy var noAllowChooseLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.text = "不允许找回".localizedString
        $0.textAlignment = .left
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(noAllowChooseButtonOnPress)))
    }
    
    private lazy var noAllowChooseDescriptionLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(11), type: .bold)
        $0.text = "成员可以在有凭证的客户端连接智慧中心,但卸载APP后无法再次连接".localizedString
        $0.textAlignment = .left
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(noAllowChooseButtonOnPress)))
    }

    private lazy var placeLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(11), type: .regular)
        $0.text = "拥有者可以到专业版-家居-智慧中心修改".localizedString
        $0.textAlignment = .center
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(noAllowChooseButtonOnPress)))
    }
    
    private lazy var sureBtn = CustomButton(buttonType:
                                                .centerTitleAndLoading(normalModel:
                                                                        .init(
                                                                            title: "确定".localizedString,
                                                                            titleColor: .custom(.white_ffffff),
                                                                            font: .font(size: ZTScaleValue(14), type: .bold),
                                                                            backgroundColor: .custom(.blue_2da3f6)
                                                                        )
                                                )).then {
                                                    $0.layer.cornerRadius = ZTScaleValue(4)
                                                    $0.addTarget(self, action: #selector(onClickSure), for: .touchUpInside)
                                                }
    
    
    private lazy var cancelBtn = Button().then {
        $0.setTitle("取消".localizedString, for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.layer.borderWidth = ZTScaleValue(0.5)
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.cancelCallback?()
            self?.removeFromSuperview()
        }

        
    }

    
    
    @objc private func allowChooseButtonOnPress(){
        allowChooseButton.isSelected = true
        noAllowChooseButton.isSelected = false
    }
    
    @objc private func noAllowChooseButtonOnPress(){
        allowChooseButton.isSelected = false
        noAllowChooseButton.isSelected = true
    }

    @objc private func onClickSure() {
        
        sureCallback?(allowChooseButton.isSelected ? 1 : 0)//已选择返回1，未选择返回0
        if removeWithSure {
            removeFromSuperview()
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init(frame: CGRect, message: String) {
        self.init(frame: frame)
        self.tipsLabel.text = message.localizedString
    }
    
    convenience init(frame: CGRect, attributedString: NSAttributedString,chooseString: String) {
        self.init(frame: frame)
        self.tipsLabel.attributedText = attributedString
        self.allowChooseLabel.text = chooseString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        container.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform.identity
        })
            
        
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        },completion: { isFinished in
            if isFinished {
                super.removeFromSuperview()
            }
            
        })
        
    }
    
    private func setupViews() {
        addSubview(cover)
        addSubview(container)
        
        container.addSubview(tipsLabel)
        container.addSubview(tipsSubscriptLabel)
        
        container.addSubview(allowChooseLabel)
        container.addSubview(allowChooseButton)
        container.addSubview(allowChooseDescriptionLabel)
        
        container.addSubview(noAllowChooseLabel)
        container.addSubview(noAllowChooseButton)
        container.addSubview(noAllowChooseDescriptionLabel)
        
        container.addSubview(placeLabel)
        
        container.addSubview(sureBtn)
//        container.addSubview(cancelBtn)
        
    }

    private func setConstrains() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - ZTScaleValue(75))
        }
        
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(30))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        tipsSubscriptLabel.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(ZTScaleValue(12))
            $0.left.equalToSuperview().offset(ZTScaleValue(24.5))
            $0.right.equalToSuperview().offset(ZTScaleValue(-24.5))
        }
        
        
        allowChooseButton.snp.makeConstraints {
            $0.top.equalTo(tipsSubscriptLabel.snp.bottom).offset(ZTScaleValue(24.5))
            $0.left.equalTo(ZTScaleValue(24.5))
            $0.width.height.equalTo(ZTScaleValue(18.5))
        }
        
        allowChooseLabel.snp.makeConstraints {
            $0.left.equalTo(allowChooseButton.snp.right).offset(ZTScaleValue(10))
            $0.top.equalTo(allowChooseButton)
            $0.right.equalTo(-ZTScaleValue(24.5))
        }
        
        allowChooseDescriptionLabel.snp.makeConstraints {
            $0.left.equalTo(allowChooseLabel)
            $0.top.equalTo(allowChooseLabel.snp.bottom).offset(ZTScaleValue(7.5))
            $0.right.equalTo(-ZTScaleValue(24.5))
        }
        
        noAllowChooseButton.snp.makeConstraints {
            $0.top.equalTo(allowChooseDescriptionLabel.snp.bottom).offset(ZTScaleValue(9.5))
            $0.left.equalTo(ZTScaleValue(24.5))
            $0.width.height.equalTo(ZTScaleValue(18.5))
        }
        
        noAllowChooseLabel.snp.makeConstraints {
            $0.left.equalTo(noAllowChooseButton.snp.right).offset(ZTScaleValue(10))
            $0.top.equalTo(noAllowChooseButton)
            $0.right.equalTo(-ZTScaleValue(24.5))
        }
        
        noAllowChooseDescriptionLabel.snp.makeConstraints {
            $0.left.equalTo(noAllowChooseLabel)
            $0.top.equalTo(noAllowChooseLabel.snp.bottom).offset(ZTScaleValue(7.5))
            $0.right.equalTo(-ZTScaleValue(23.5))
        }

        placeLabel.snp.makeConstraints {
            $0.top.equalTo(noAllowChooseDescriptionLabel.snp.bottom).offset(ZTScaleValue(25))
            $0.left.equalTo(ZTScaleValue(24.5))
            $0.right.equalTo(-ZTScaleValue(24.5))

        }
        
        sureBtn.snp.makeConstraints {
            $0.top.equalTo(placeLabel.snp.bottom).offset(ZTScaleValue(20))
            $0.height.equalTo(ZTScaleValue(40))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(100))
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(16.5))
        }
        
//        cancelBtn.snp.makeConstraints {
//            $0.height.equalTo(ZTScaleValue(50))
//            $0.left.equalToSuperview()
//            $0.top.equalTo(placeLabel.snp.bottom).offset(ZTScaleValue(16))
//            $0.width.equalTo((Screen.screenWidth - ZTScaleValue(75)) / 2)
//            $0.bottom.equalToSuperview()
//        }
    }
    
    @discardableResult
    static func show(message: String, sureCallback: ((_ tap: Int) -> ())?, cancelCallback: (() -> ())? = nil, removeWithSure: Bool = true) -> TokenAllowedSettingAlertView {
        let tipsView = TokenAllowedSettingAlertView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight), message: message)
        tipsView.removeWithSure = removeWithSure
        tipsView.sureCallback = sureCallback
        tipsView.cancelCallback = cancelCallback
        UIApplication.shared.windows.first?.addSubview(tipsView)
        return tipsView
    }

}
