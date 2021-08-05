//
//  RegisterViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/22.
//

import UIKit

class RegisterViewController: BaseViewController {
    lazy var captcha_id = ""
    
    var loginComplete: (() -> ())?
    
    private lazy var containerView = UIView()
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 20, type: .regular)
        $0.text = "绑定云".localizedString
        $0.textAlignment = .center
    }
    
    private lazy var phoneTextField = TitleTextField(keyboardType: .numberPad, title: "手机号".localizedString, placeHolder: "请输入手机号".localizedString, limitCount: 11).then {
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
    
    private lazy var captchaButton = CaptchaButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    
    private lazy var captchaTextField = TitleTextField(keyboardType: .numberPad, title: "验证码".localizedString, placeHolder: "请输入验证码".localizedString, limitCount: 6).then {
        $0.textField.rightViewMode = .always
        $0.textField.rightView = captchaButton
    }
    
    
    private lazy var doneButton = LoadingButton(title: "绑定".localizedString)
    
    private lazy var loginButton = Button().then {
        $0.setTitle("已绑定，点击登录".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .regular)

    }
    

    private lazy var protocolLabel = Label().then {
        var attrText = NSMutableAttributedString(
            string: "绑定即代表你已同意智汀家庭云".localizedString,
            attributes: [
                NSAttributedString.Key.font : UIFont.font(size: 11, type: .medium),
                NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)
            ])
        let attrText1 = NSAttributedString(
            string: "用户协议、隐私政策".localizedString,
            attributes: [
                NSAttributedString.Key.font : UIFont.font(size: 11, type: .medium),
                NSAttributedString.Key.foregroundColor : UIColor.custom(.blue_2da3f6)
            ])
        
        attrText.append(attrText1)
        
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.attributedText = attrText
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViews() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(phoneTextField)
        containerView.addSubview(pwdTextField)
        containerView.addSubview(captchaTextField)
        containerView.addSubview(doneButton)
        containerView.addSubview(loginButton)
        view.addSubview(protocolLabel)
        
        captchaButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.sendCaptcha()
        }
        
        captchaButton.endCountingCallback = { [weak self] in
            self?.phoneTextField.isUserInteractionEnabled = true
        }
        
        doneButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.doneButtonClick()
        }
        
        loginButton.clickCallBack = { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resignKeyboard)))
        containerView.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resignKeyboard)))
        view.isUserInteractionEnabled = true
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(47)
            $0.right.equalToSuperview().offset(-47)
            $0.top.equalToSuperview().offset(22.5 * Screen.screenRatio)
            
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
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
        
        captchaTextField.snp.makeConstraints {
            $0.top.equalTo(pwdTextField.snp.bottom).offset(30 * Screen.screenRatio)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints {
            $0.top.equalTo(captchaTextField.snp.bottom).offset(55 * Screen.screenRatio)
            $0.centerX.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(50)
            
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(doneButton.snp.bottom).offset(20 * Screen.screenRatio)
            $0.right.equalTo(doneButton.snp.right)
            $0.height.equalTo(18)
            $0.bottom.equalToSuperview()
        }
        
        protocolLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.greaterThanOrEqualToSuperview().offset(15 * Screen.screenRatio)
            $0.right.lessThanOrEqualToSuperview().offset(-15 * Screen.screenRatio)
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
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

//        phoneTextField.textPublisher
//            .combineLatest(pwdTextField.textPublisher, captchaTextField.textPublisher)
//            .map { $0 != "" && $1 != "" && $2 != "" }
//            .sink { [weak self] (isEnable) in
//                guard let self = self else { return }
//                self.doneButton.setIsEnable(isEnable)
//            }
//            .store(in: &cancellables)
        
    }
    
    @objc func resignKeyboard() {
        self.view.endEditing(true)
    }
}

extension RegisterViewController {
    private func sendCaptcha() {
        if phoneTextField.text.count < 11 {
            phoneTextField.warning = "请输入11位手机号码".localizedString
            return
        }

        captchaButton.setIsEnable(false)
        captchaButton.btnLabel.text = "发送中...".localizedString
        ApiServiceManager.shared.getCaptcha(type: .register, target: phoneTextField.text) { [weak self] (response) in
            self?.showToast(string: "验证码已发送".localizedString)
            self?.captcha_id = response.captcha_id
            self?.captchaButton.beginCountDown()
            self?.phoneTextField.isUserInteractionEnabled = false
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.captchaButton.setIsEnable(true)
            self?.captchaButton.btnLabel.text = "获取验证码".localizedString
        }
        
    }
    
    private func doneButtonClick() {
        

        if !(phoneTextField.text.count > 0) {
            showToast(string: "手机号不能为空".localizedString)
            return
        }

        if !(pwdTextField.text.count > 0) {
            showToast(string: "密码不能为空".localizedString)
            return
        }
        
        if pwdTextField.text.count < 6 {
            showToast(string: "密码不能少于6位".localizedString)
            return
        }
        
        if !(captchaTextField.text.count > 0) {
            showToast(string: "验证码不能为空".localizedString)
            return
        }
        
        doneButton.buttonState = .waiting
        view.isUserInteractionEnabled = false
        
        ApiServiceManager.shared.register(phone: phoneTextField.text, password: pwdTextField.text, captcha: captchaTextField.text, captchaId: captcha_id) { [weak self] (response) in
            self?.showToast(string: "绑定成功".localizedString)
            self?.navigationController?.popViewController(animated: true)
            
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.doneButton.buttonState = .normal
            self?.view.isUserInteractionEnabled = true
        }

        
    }
}

