//
//  RegisterViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/22.
//

import UIKit

class RegisterViewController: BaseViewController {
    lazy var captcha_id = ""
    
    private lazy var containerView = UIView()
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 20, type: .regular)
        $0.text = "注册".localizedString
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
    
    private lazy var pwdTextField = TitleTextField(title: "密码".localizedString, placeHolder: "请输入密码(6-20位，包含字母和数字)".localizedString, isSecure: true)
    
    private lazy var captchaButton = CaptchaButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    
    private lazy var captchaTextField = TitleTextField(keyboardType: .numberPad, title: "验证码".localizedString, placeHolder: "请输入验证码".localizedString, limitCount: 10).then {
        $0.textField.rightViewMode = .always
        $0.textField.rightView = captchaButton
    }
    
    
    private lazy var doneButton = OnNextButton(title: "完成".localizedString).then { $0.setIsEnable(false) }
    
    private lazy var protocolLabel = Label().then {
        var attrText = NSMutableAttributedString(
            string: "注册即代表你已同意智汀".localizedString,
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

        phoneTextField.textPublisher
            .combineLatest(pwdTextField.textPublisher, captchaTextField.textPublisher)
            .map { $0 != "" && $1 != "" && $2 != "" }
            .sink { [weak self] (isEnable) in
                guard let self = self else { return }
                self.doneButton.setIsEnable(isEnable)
            }
            .store(in: &cancellables)
        
    }
}

extension RegisterViewController {
    private func sendCaptcha() {
        if phoneTextField.text.count < 11 {
            phoneTextField.warning = "请输入11位手机号码".localizedString
            return
        }

        apiService.requestModel(.captcha(type: .register, target: phoneTextField.text), modelType: CaptchaResponse.self) { [weak self] (response) in
            self?.captcha_id = response.captcha_id
            self?.captchaButton.beginCountDown()
            self?.phoneTextField.isUserInteractionEnabled = false
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
        
    }
    
    private func doneButtonClick() {
        doneButton.buttonState = .waiting
        view.isUserInteractionEnabled = false
        
        apiService.requestModel(.register(phone: phoneTextField.text, password: pwdTextField.text, captcha: captchaTextField.text, captcha_id: captcha_id), modelType: RegisterResponse.self) { [weak self] (response) in
            self?.authManager.currentUser = response.user_info
            SceneDelegate.shared.window?.rootViewController = AppDelegate.shared.appDependency.tabbarController
            
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.doneButton.buttonState = .normal
            self?.view.isUserInteractionEnabled = true
        }

        
    }
}


extension RegisterViewController {
    private class CaptchaResponse: BaseModel {
        var captcha_id = ""
    }
    
    private class RegisterResponse: BaseModel {
        var user_info = User()
    }
}
