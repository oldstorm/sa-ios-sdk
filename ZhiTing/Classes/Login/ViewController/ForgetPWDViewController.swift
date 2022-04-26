//
//  ForgetPWDViewController.swift
//  ZhiTing
//
//  Created by zy on 2022/1/11.
//

import UIKit

class ForgetPWDViewController: BaseViewController {
    lazy var captcha_id = ""
    private lazy var containerView = UIView()
    var phoneNumber = ""
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 20, type: .regular)
        $0.text = "忘记密码".localizedString
        $0.textAlignment = .center
    }
    private lazy var subTitleLabel = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.text = "如果你已忘记密码，可通过手机重新设置密码".localizedString
        $0.textAlignment = .center
    }

    
    private lazy var phoneZoneView = PhoneZoneCodeView(frame: CGRect(x: 0, y: 0, width: 75, height: 40)).then {
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPhoneZone)))
    }
    
    private lazy var zoneViewAlert = PhoneZoneCodeViewAlert()
    
    private lazy var phoneTextField = TitleTextField(keyboardType: .numberPad, title: "手机号".localizedString, placeHolder: "请输入手机号".localizedString, limitCount: 11).then {
        $0.textField.leftViewMode = .always
        let leftView = phoneZoneView
        leftView.clipsToBounds = true
        $0.textField.leftView = leftView
    }
    
    private lazy var newPwdTextField = TitleTextField(title: "新密码".localizedString, placeHolder: "请输入新密码（6-20位，包含字母和数字）".localizedString, isSecure: true)
    private lazy var confirmPwdTextField = TitleTextField(title: "确认新密码".localizedString, placeHolder: "请确认新密码（6-20位，包含字母和数字）".localizedString, isSecure: true)

    private lazy var captchaButton = CaptchaButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    
    private lazy var captchaTextField = TitleTextField(keyboardType: .numberPad, title: "验证码".localizedString, placeHolder: "请输入验证码".localizedString, limitCount: 6).then {
        $0.textField.rightViewMode = .always
        $0.textField.rightView = captchaButton
    }
    
    private lazy var sureButton = LoadingButton(title: "确认".localizedString)


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func setupViews() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subTitleLabel)
        containerView.addSubview(phoneTextField)
        containerView.addSubview(newPwdTextField)
        containerView.addSubview(confirmPwdTextField)
        containerView.addSubview(captchaTextField)
        containerView.addSubview(sureButton)

        phoneTextField.textField.text = self.phoneNumber

        zoneViewAlert.selectCallback = { [weak self] zone in
            guard let self = self else { return }
            self.phoneZoneView.label.text = "+\(zone.code)"
        }

        zoneViewAlert.dismissCallback = { [weak self] in
            guard let self = self else { return }
            self.phoneZoneView.arrow.image = .assets(.arrow_down)
        }
        
        captchaButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.sendCaptcha()
        }
        
        captchaButton.endCountingCallback = { [weak self] in
            self?.phoneTextField.isUserInteractionEnabled = true
        }
        
        
        sureButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.loginClick()
        }
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(47)
            $0.right.equalToSuperview().offset(-47)
            $0.top.equalToSuperview().offset(22.5 * Screen.screenRatio + Screen.k_nav_height)
            
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10 * Screen.screenRatio)
            $0.centerX.equalToSuperview()
        }
        
        phoneTextField.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(50 * Screen.screenRatio)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        newPwdTextField.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(30 * Screen.screenRatio)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        confirmPwdTextField.snp.makeConstraints {
            $0.top.equalTo(newPwdTextField.snp.bottom).offset(30 * Screen.screenRatio)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        captchaTextField.snp.makeConstraints {
            $0.top.equalTo(confirmPwdTextField.snp.bottom).offset(30 * Screen.screenRatio)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        sureButton.snp.makeConstraints {
            $0.top.equalTo(captchaTextField.snp.bottom).offset(55 * Screen.screenRatio)
            $0.centerX.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview()
        }

    }
    
    override func setupSubscriptions() {
        phoneTextField.textPublisher
            .map { $0 != "" }
            .sink { [weak self] (isEnable) in
                guard let self = self else { return }
                self.captchaButton.setIsEnable(isEnable)
                
            }
            .store(in: &cancellables)
        captchaButton.setIsEnable(phoneTextField.textField.text != "")

    }

    


}

extension ForgetPWDViewController {
    @objc private func selectPhoneZone() {
        phoneZoneView.arrow.image = .assets(.arrow_up)
        let associatedFrame = containerView.convert(phoneTextField.frame, to: view)
        zoneViewAlert.setAssociateFrame(frame: associatedFrame)
        SceneDelegate.shared.window?.addSubview(zoneViewAlert)
    }
    
    private func sendCaptcha() {
        if phoneTextField.text.count < 11 {
            phoneTextField.warning = "请输入11位手机号码".localizedString
            return
        }

        captchaButton.setIsEnable(false)
        captchaButton.btnLabel.text = "发送中...".localizedString
        ApiServiceManager.shared.getCaptcha(type: .forget_password, target: phoneTextField.text) { [weak self] (response) in
            self?.showToast(string: "验证码已发送".localizedString)
            self?.captcha_id = response.captcha_id
            self?.captchaButton.beginCountDown()
            self?.phoneTextField.isUserInteractionEnabled = false
        } failureCallback: { [weak self] (code, err) in
            if err != "error" {
                self?.showToast(string: err)
            }
            self?.captchaButton.setIsEnable(true)
            self?.captchaButton.btnLabel.text = "获取验证码".localizedString
        }
        
    }
    
    private func loginClick() {
        
        if phoneTextField.text == "" {
            phoneTextField.warning = "请输入手机号".localizedString
            self.showToast(string: "请输入手机号")
            return
        }
        
        if newPwdTextField.text == "" {
            newPwdTextField.warning = "请输入新密码".localizedString
            self.showToast(string: "请输入新密码")
            return
        }
        
        if confirmPwdTextField.text == "" {
            confirmPwdTextField.warning = "请确认新密码".localizedString
            self.showToast(string: "请确认新密码")
            return
        }
        
        if captchaTextField.text == "" {
            captchaTextField.warning = "请输入验证码".localizedString
            self.showToast(string: "请输入验证码")
            return
        }
        
        if newPwdTextField.text != confirmPwdTextField.text {
            showToast(string: "两次新密码输入不一致")
            return
        }

        ApiServiceManager.shared.forgetPwd(phone: phoneTextField.text, new_password: newPwdTextField.text, captcha: captchaTextField.text, captcha_id: captcha_id) {[weak self] response in
            guard let self = self else {return}
            self.showToast(string: "")
            WarningAlert.show(message: "密码已重新设置，请使用新密码登录",sureTitle: "确定",iconImage: .assets(.icon_warning_light)) {
                    self.navigationController?.popToRootViewController(animated: true)
            }
        } failureCallback: {[weak self] code, err in
            guard let self = self else {return}
            self.showToast(string: err)
        }

        
    }
}
