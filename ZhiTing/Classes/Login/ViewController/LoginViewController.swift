//
//  LoginViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/22.
//

import UIKit

class LoginViewController: BaseViewController {
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

    private lazy var phoneTextField = TitleTextField(keyboardType: .numberPad, title: "手机号".localizedString, placeHolder: "请输入手机号".localizedString, isSecure: false, limitCount: 11).then {
        $0.textField.leftViewMode = .always
        
        let label = Label().then {
            $0.text = "+86"
            $0.font = .font(size: 12, type: .bold)
            $0.textColor = .custom(.black_3f4663)
        }
        
        let line = UIView().then {
            $0.backgroundColor = .custom(.gray_dddddd)
        }
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 40))
        leftView.clipsToBounds = true
        leftView.addSubview(label)
        leftView.addSubview(line)
        
        label.frame = CGRect(x: 0, y: 3, width: 35, height: 37)
        line.frame = CGRect(x: 28, y: 14, width: 0.5, height: 14)

        
        $0.textField.leftView = leftView
    }
    
    private lazy var pwdTextField = TitleTextField(title: "密码".localizedString, placeHolder: "请输入密码".localizedString, isSecure: true)
    
    private lazy var loginButton = LoadingButton(title: "登录".localizedString)
    
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
        containerView.addSubview(loginButton)
        containerView.addSubview(registerButton)
        view.addSubview(privacyBottomView)

        
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
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(pwdTextField.snp.bottom).offset(65 * Screen.screenRatio)
            $0.centerX.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        registerButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(20 * Screen.screenRatio)
            $0.height.equalTo(50)
            $0.left.equalTo(loginButton.snp.left)
            $0.right.equalTo(loginButton.snp.right)
            $0.bottom.equalToSuperview()
        }
        
        privacyBottomView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12 - Screen.bottomSafeAreaHeight)
        }
        
    }

}

extension LoginViewController {
    
    private func loginClick() {
        if phoneTextField.text == "" {
            phoneTextField.warning = "请输入手机号".localizedString
            return
        }
        
        if pwdTextField.text == "" {
            pwdTextField.warning = "请输入密码".localizedString
            return
        }
        
        if !privacyBottomView.selectButton.isSelected {
            SceneDelegate.shared.window?.hideAllToasts()
            showToast(string: "请阅读并勾选协议".localizedString)
            return
        }


        loginButton.buttonState = .waiting
        view.isUserInteractionEnabled = false
        
        authManager.logIn(phone: phoneTextField.text, pwd: pwdTextField.text) { [weak self] (user) in
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


