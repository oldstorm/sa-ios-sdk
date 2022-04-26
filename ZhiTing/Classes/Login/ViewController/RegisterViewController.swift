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
    

    private lazy var privacyBottomView = PrivacyBottomView()
    
    
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
        view.addSubview(privacyBottomView)
        
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
        
        doneButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.doneButtonClick()
        }
        
        loginButton.clickCallBack = { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
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
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(47)
            $0.right.equalToSuperview().offset(-47)
            $0.top.equalToSuperview().offset(22.5 * Screen.screenRatio + Screen.k_nav_height)
            
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
        
        privacyBottomView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12 - Screen.bottomSafeAreaHeight)
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
    
    }
    
}

extension RegisterViewController {
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
        ApiServiceManager.shared.getCaptcha(type: .register, target: phoneTextField.text) { [weak self] (response) in
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
        
        if !privacyBottomView.selectButton.isSelected {
            SceneDelegate.shared.window?.hideAllToasts()
            showToast(string: "请阅读并勾选协议".localizedString)
            return
        }
        
        doneButton.buttonState = .waiting
        view.isUserInteractionEnabled = false
        
        ApiServiceManager.shared.register(phone: phoneTextField.text, password: pwdTextField.text, captcha: captchaTextField.text, captchaId: captcha_id) { [weak self] (registerResponse) in
            
            /// 同步前,当前家庭用户昵称
            let oldName = UserManager.shared.currentUser.nickname

            let user = registerResponse.user_info
            UserManager.shared.isLogin = true
            UserManager.shared.currentUser.avatar_url = user.avatar_url
            UserManager.shared.currentUser.phone = user.phone
            UserManager.shared.currentUser.user_id = user.user_id
            if user.nickname != "" {
                UserManager.shared.currentUser.nickname = user.nickname
            }
            
            UserCache.update(from: user)
            
            let needCleanArea = AreaCache.areaList().filter({ $0.cloud_user_id != user.user_id })
            
            needCleanArea.forEach {
                if $0.cloud_user_id > 0 {
                    AreaCache.deleteArea(id: $0.id, sa_token: $0.sa_user_token)
                }
                
            }
            
            /// 登录成功后获取家庭列表
            ApiServiceManager.shared.areaList { [weak self] response in
                guard let self = self else { return }
                response.areas.forEach { $0.cloud_user_id = UserManager.shared.currentUser.user_id }
                
                /// 如果登录的账号已存在该sa家庭，清除该本地sa家庭的token，避免出现sa_user_id和token对应不是同一个用户的情况
                let cacheAreas = AreaCache.areaList()
                cacheAreas.forEach { cacheArea in
                    if let responseArea = response.areas.first(where: { $0.sa_id == cacheArea.sa_id && $0.is_bind_sa }) {
                        if cacheArea.sa_user_id != responseArea.sa_user_id {
                            cacheArea.sa_user_token = ""
                            AreaCache.cacheArea(areaCache: cacheArea.toAreaCache())
                        }
                    }
                }

                AreaCache.cacheAreas(areas: response.areas, needRemove: false)
                
                /// 如果该账户云端没有家庭则自动创建一个
                if AreaCache.areaList().count == 0 {
                    AuthManager.shared.currentArea = AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)", cloud_user_id: user.user_id, mode: .family).transferToArea()
                }
                
                /// 如果该账户云端没有家庭,将用户名字更新为当前家庭名字
                if response.areas.count == 0 {
                    ApiServiceManager.shared.editCloudUser(user_id: user.user_id, nickname: oldName, successCallback: { _ in
                        UserManager.shared.currentUser.nickname = oldName
                        user.nickname = oldName
                        UserCache.update(from: user)

                    }, failureCallback: nil)
                }
                
                /// 同步本地家庭到云
                AuthManager.shared.syncLocalAreasToCloud(needUpdateCurrentArea: true) {
                    self.showToast(string: "绑定成功".localizedString)
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
                /// 保存真实手机号
                UserManager.shared.currentPhoneNumber = self.phoneTextField.text
            } failureCallback: { code, err in
                self?.showToast(string: err)
                self?.doneButton.buttonState = .normal
                self?.view.isUserInteractionEnabled = true
            }
            
            
            
            
//            self?.navigationController?.popViewController(animated: true)
        } failureCallback: { [weak self] (code, err) in
            if err != "error" {
                self?.showToast(string: err)
            }
            self?.doneButton.buttonState = .normal
            self?.view.isUserInteractionEnabled = true
        }

        
    }
}

