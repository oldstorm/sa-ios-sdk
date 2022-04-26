//
//  LoginViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/22.
//

import UIKit

class LoginViewController: BaseViewController {
    lazy var captcha_id = ""
    var loginComplete: (() -> ())?
    
    private lazy var containerView = UIView()

    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 20, type: .regular)
        $0.text = "登录".localizedString
        $0.textAlignment = .center
    }
    
    private lazy var logo = ImageView().then {
        $0.image = .assets(.login_logo)
        $0.contentMode = .scaleAspectFit
    }

    private lazy var phoneZoneView = PhoneZoneCodeView(frame: CGRect(x: 0, y: 0, width: 75, height: 40)).then {
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPhoneZone)))
    }
    
    private lazy var zoneViewAlert = PhoneZoneCodeViewAlert()

    private lazy var phoneTextField = TitleTextField(keyboardType: .numberPad, title: "手机号".localizedString, placeHolder: "请输入手机号".localizedString, isSecure: false, limitCount: 11).then {
        $0.textField.leftViewMode = .always
        let leftView = phoneZoneView
        leftView.clipsToBounds = true

        
        $0.textField.leftView = leftView
    }
    
    private lazy var pwdTextField = TitleTextField(title: "密码".localizedString, placeHolder: "请输入密码".localizedString, isSecure: true)
    
    private lazy var captchaButton = CaptchaButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    
    private lazy var captchaTextField = TitleTextField(keyboardType: .numberPad, title: "验证码".localizedString, placeHolder: "请输入验证码".localizedString, limitCount: 6).then {
        $0.textField.rightViewMode = .always
        $0.textField.rightView = captchaButton
    }
    
    private lazy var loginButton = LoadingButton(title: "登录".localizedString)
    
    private lazy var forgetPwdButton = Button().then {
        $0.setTitle("忘记密码".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.textAlignment = .left
        $0.titleLabel?.font = .font(size: 14, type: .regular)
    }
    
    private lazy var changeLoginButton = Button().then {
        $0.setTitle("短信验证码登录".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.setTitle("密码登录".localizedString, for: .selected)
        $0.titleLabel?.font = .font(size: 14, type: .regular)
        $0.isSelected = false
        $0.titleLabel?.textAlignment = .right
    }

    
    private lazy var registerButton = Button().then {
        $0.setTitle("绑定云".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .regular)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_94a5be).cgColor
        $0.layer.cornerRadius = 4
    }
    
    private lazy var privacyBottomView = PrivacyBottomView()

    
    private lazy var dismissButton = Button().then {
        $0.setImage(.assets(.navigation_back), for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func setupViews() {
        view.addSubview(dismissButton)
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(logo)
        containerView.addSubview(phoneTextField)
        containerView.addSubview(pwdTextField)
        containerView.addSubview(captchaTextField)
        containerView.addSubview(forgetPwdButton)
        containerView.addSubview(changeLoginButton)
        containerView.addSubview(loginButton)
        containerView.addSubview(registerButton)
        view.addSubview(privacyBottomView)

        zoneViewAlert.selectCallback = { [weak self] zone in
            guard let self = self else { return }
            self.phoneZoneView.label.text = "+\(zone.code)"
        }
        
        zoneViewAlert.dismissCallback = { [weak self] in
            guard let self = self else { return }
            self.phoneZoneView.arrow.image = .assets(.arrow_down)
        }
        
        forgetPwdButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let vc = ForgetPWDViewController()
            vc.phoneNumber = self.phoneTextField.text
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        changeLoginButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.changeLoginButton.isSelected = !self.changeLoginButton.isSelected
            self.changeLoginUI()
        }

        registerButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let vc = RegisterViewController()
            vc.loginComplete = self.loginComplete
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        loginButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.loginClick()
        }
        
        privacyBottomView.privacyCallback = { [weak self] in
            guard let self = self else { return }
            let vc = WKWebViewController(linkEnum: .privacy)
            vc.title = "隐私政策".localizedString
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        privacyBottomView.userAgreementCallback = { [weak self] in
            guard let self = self else { return }
            let vc = WKWebViewController(linkEnum: .userAgreement)
            vc.title = "用户协议".localizedString
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        captchaButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.sendCaptcha()
        }
        
        captchaButton.endCountingCallback = { [weak self] in
            self?.phoneTextField.isUserInteractionEnabled = true
        }
        
    }
    
        
    override func setupConstraints() {
        dismissButton.snp.makeConstraints {
            $0.width.height.equalTo(ZTScaleValue(24))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.top.equalToSuperview().offset(Screen.statusBarHeight + 12)
        }
        
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(47)
            $0.right.equalToSuperview().offset(-47)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-55 * Screen.screenRatio + Screen.k_nav_height)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        logo.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(47 * Screen.screenRatio)
            $0.centerX.equalToSuperview().offset(-5)
            $0.height.equalTo(40.5)
            $0.width.equalTo(157)
        }

        phoneTextField.snp.makeConstraints {
            $0.top.equalTo(logo.snp.bottom).offset(60 * Screen.screenRatio)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
                
        pwdTextField.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(30 * Screen.screenRatio)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        captchaTextField.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(30 * Screen.screenRatio)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        
        if changeLoginButton.isSelected {
            pwdTextField.isHidden = true
            loginButton.snp.makeConstraints {
                $0.top.equalTo(captchaTextField.snp.bottom).offset(50 * Screen.screenRatio)
                $0.centerX.equalToSuperview()
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
                $0.height.equalTo(50)
            }
        }else{
            captchaTextField.isHidden = true
            loginButton.snp.makeConstraints {
                $0.top.equalTo(pwdTextField.snp.bottom).offset(50 * Screen.screenRatio)
                $0.centerX.equalToSuperview()
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
                $0.height.equalTo(50)
            }
        }

        registerButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(20 * Screen.screenRatio)
            $0.height.equalTo(50)
            $0.left.equalTo(loginButton.snp.left)
            $0.right.equalTo(loginButton.snp.right)
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(20))
        }
        
        forgetPwdButton.snp.makeConstraints {
            $0.top.equalTo(registerButton.snp.bottom).offset(10 * Screen.screenRatio)
            $0.left.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(15))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(60))
        }
        
        changeLoginButton.snp.makeConstraints {
            $0.top.equalTo(registerButton.snp.bottom).offset(10 * Screen.screenRatio)
            $0.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(15))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(100))
        }
        
        privacyBottomView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12 - Screen.bottomSafeAreaHeight)
        }
        
    }
    
    private func changeLoginUI(){
        if changeLoginButton.isSelected {
            pwdTextField.isHidden = true
            captchaTextField.isHidden = false
            loginButton.snp.remakeConstraints {
                $0.top.equalTo(captchaTextField.snp.bottom).offset(50 * Screen.screenRatio)
                $0.centerX.equalToSuperview()
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
                $0.height.equalTo(50)
            }
            changeLoginButton.snp.remakeConstraints {
                $0.top.equalTo(registerButton.snp.bottom).offset(10 * Screen.screenRatio)
                $0.right.equalToSuperview()
                $0.height.equalTo(ZTScaleValue(15))
                $0.width.greaterThanOrEqualTo(ZTScaleValue(100))
            }

        }else{
            pwdTextField.isHidden = false
            captchaTextField.isHidden = true
            loginButton.snp.remakeConstraints {
                $0.top.equalTo(pwdTextField.snp.bottom).offset(50 * Screen.screenRatio)
                $0.centerX.equalToSuperview()
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
                $0.height.equalTo(50)
            }
            changeLoginButton.snp.remakeConstraints {
                $0.top.equalTo(registerButton.snp.bottom).offset(10 * Screen.screenRatio)
                $0.right.equalToSuperview()
                $0.height.equalTo(ZTScaleValue(15))
                $0.width.greaterThanOrEqualTo(ZTScaleValue(100))
            }

        }
    }

    

}

extension LoginViewController {
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
        ApiServiceManager.shared.getCaptcha(type: .login, target: phoneTextField.text) { [weak self] (response) in
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
            return
        }
        
        if !changeLoginButton.isSelected {
            if pwdTextField.text == "" {
                pwdTextField.warning = "请输入密码".localizedString
                return
            }
        }else{
            if captchaTextField.text == "" {
                captchaTextField.warning = "请输入验证码".localizedString
                return
            }
        }
        

        
        if !privacyBottomView.selectButton.isSelected {
            SceneDelegate.shared.window?.hideAllToasts()
            showToast(string: "请阅读并勾选协议".localizedString)
            return
        }


        loginButton.buttonState = .waiting
        view.isUserInteractionEnabled = false
        
        if !changeLoginButton.isSelected {//密码登录
            authManager.logIn(phone: phoneTextField.text, password: pwdTextField.text, login_type: 0, country_code: "86", captcha: "", captcha_id: "") { [weak self] (user) in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.showToast(string: "登录成功".localizedString)
                    self?.loginComplete?()
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                }
                
            } failure: { [weak self] (err) in
                self?.loginButton.buttonState = .normal
                self?.view.isUserInteractionEnabled = true
                if err != "error" {
                    self?.showToast(string: err)
                }
            }

        }else{//验证码登录
            authManager.logIn(phone: phoneTextField.text, password: "", login_type: 1, country_code: "86", captcha: captchaTextField.text, captcha_id: captcha_id) { [weak self] (user) in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.showToast(string: "登录成功".localizedString)
                    self?.loginComplete?()
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                }
                
            } failure: { [weak self] (err) in
                self?.loginButton.buttonState = .normal
                self?.view.isUserInteractionEnabled = true
                if err != "error" {
                    self?.showToast(string: err)
                }
            }
        }
        
    }
    
}


