//
//  UnregisterAlert.swift
//  ZhiTing
//
//  Created by iMac on 2022/1/4.
//

import UIKit

class UnregisterAlert: UIView {
    var sureCallback: (() -> ())?
    var cancelCallback: (() -> ())?

    lazy var captcha_id = ""
    
    var removeWithSure = false
    
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
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private lazy var detailLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.text = "账号注销为风险操作，需要获取你的手机（\(UserManager.shared.currentUser.phone)）验证码进行验证"
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private lazy var captchaButton = CaptchaButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    
    lazy var captchaBGView = UIView().then {
        $0.backgroundColor = .custom(.gray_f5f5f5)
        $0.layer.cornerRadius = 4
    }

    lazy var captchaTextField = TitleTextField(keyboardType: .numberPad, title: "".localizedString, placeHolder: "请输入验证码".localizedString, limitCount: 6).then {
        $0.line.isHidden = true
        $0.textField.rightViewMode = .always
        $0.textField.rightView = captchaButton
    }

    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "提示".localizedString
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private lazy var sureBtn = CustomButton(buttonType:
                                                .centerTitleAndLoading(normalModel:
                                                                        .init(
                                                                            title: "确定注销".localizedString,
                                                                            titleColor: .custom(.blue_2da3f6),
                                                                            font: .font(size: 14, type: .bold),
                                                                            backgroundColor: .custom(.white_ffffff)
                                                                        )
                                                )).then {
                                                    $0.layer.borderWidth = 0.5
                                                    $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
                                                    $0.addTarget(self, action: #selector(onClickSure), for: .touchUpInside)
                                                }
    
    private lazy var cancelBtn = Button().then {
        $0.setTitle("取消".localizedString, for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.cancelCallback?()
            self?.removeFromSuperview()
        }

        
    }

    @objc private func onClickSure() {
        sureCallback?()
        if removeWithSure {
            removeFromSuperview()
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
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
        container.addSubview(detailLabel)
        container.addSubview(captchaBGView)
        captchaBGView.addSubview(captchaTextField)
        container.addSubview(sureBtn)
        container.addSubview(cancelBtn)
        
        captchaButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.sendCaptcha()
        }
        
    }

    private func setConstrains() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 75)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        captchaBGView.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(21)
            $0.right.equalToSuperview().offset(-26)
            $0.height.equalTo(50)
        }

        captchaTextField.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        sureBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.equalToSuperview()
            $0.top.equalTo(captchaTextField.snp.bottom).offset(30)
            $0.width.equalTo((Screen.screenWidth - 75) / 2)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.right.equalToSuperview()
            $0.top.equalTo(captchaTextField.snp.bottom).offset(30)
            $0.width.equalTo((Screen.screenWidth - 75) / 2)
            $0.bottom.equalToSuperview()
        }
    }
    
    
    private func sendCaptcha() {
        captchaButton.setIsEnable(false)
        captchaButton.btnLabel.text = "发送中...".localizedString
        ApiServiceManager.shared.getCaptcha(type: .unregister, target: UserManager.shared.currentPhoneNumber ?? "") { [weak self] (response) in
            SceneDelegate.shared.window?.makeToast("验证码已发送".localizedString)
            self?.captcha_id = response.captcha_id
            self?.captchaButton.beginCountDown()
        } failureCallback: { [weak self] (code, err) in
            if err != "error" {
                SceneDelegate.shared.window?.makeToast(err)
            }
            self?.captchaButton.setIsEnable(true)
            self?.captchaButton.btnLabel.text = "获取验证码".localizedString
        }
        
    }

}


