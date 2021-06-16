//
//  ThirdPartyLoginViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/22.
//

import UIKit

class ThirdPartyLoginViewController: BaseViewController {
    private lazy var containerView = UIView()
    
    private lazy var logo = ImageView().then {
        $0.image = .assets(.login_logo)
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.text = "登录后将会访问你的智汀账号信息和设备控制权".localizedString
        $0.textAlignment = .center
        $0.numberOfLines = 0
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
        line.frame = CGRect(x: 28, y: 9, width: 0.5, height: 14)

        
        $0.textField.leftView = leftView
    }
    
    private lazy var pwdTextField = TitleTextField(title: "密码".localizedString, placeHolder: "请输入密码".localizedString, isSecure: true)
    
    private lazy var loginButton = OnNextButton(title: "授权登录".localizedString)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "智汀账号登录".localizedString
    }
    
    override func setupViews() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(logo)
        containerView.addSubview(phoneTextField)
        containerView.addSubview(pwdTextField)
        containerView.addSubview(loginButton)
        
        loginButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.loginClick()
        }
        
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(47)
            $0.right.equalToSuperview().offset(-47)
            $0.top.equalToSuperview().offset(42.5 * Screen.screenRatio)
            
        }
        
        logo.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview().offset(-5)
            $0.height.equalTo(40.5)
            $0.width.equalTo(112)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logo.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
            $0.left.greaterThanOrEqualToSuperview()
            $0.right.lessThanOrEqualToSuperview()
        }
        
        

        phoneTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(60 * Screen.screenRatio)
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
            $0.bottom.equalToSuperview()
        }
    }

}


extension ThirdPartyLoginViewController {
    private func loginClick() {
        if phoneTextField.text == "" {
            phoneTextField.warning = "请输入手机号".localizedString
            return
        }
        
        if pwdTextField.text == "" {
            pwdTextField.warning = "请输入密码".localizedString
            return
        }

        loginButton.buttonState = .waiting
        view.isUserInteractionEnabled = false
        
        authManager.logIn(phone: phoneTextField.text, pwd: pwdTextField.text) { (user) in
            SceneDelegate.shared.window?.rootViewController = AppDelegate.shared.appDependency.tabbarController
        } failure: { [weak self] (err) in
            self?.loginButton.buttonState = .normal
            self?.view.isUserInteractionEnabled = true
            self?.showToast(string: err)
        }
    }
}
