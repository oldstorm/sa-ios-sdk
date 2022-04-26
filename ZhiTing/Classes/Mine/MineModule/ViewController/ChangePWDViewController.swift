//
//  ChangePWDViewController.swift
//  ZhiTing
//
//  Created by zy on 2022/1/6.
//

import UIKit

class ChangePWDViewController: BaseViewController {
    
    private lazy var containerView = UIView()
    private lazy var originPwdTextField = TitleTextField(title: "旧密码".localizedString, placeHolder: "请输入旧密码".localizedString, isSecure: true)
    private lazy var newPwdTextField = TitleTextField(title: "新密码".localizedString, placeHolder: "请输入新密码（6-20位）".localizedString, isSecure: true)
    private lazy var confirmPwdTextField = TitleTextField(title: "确认新密码".localizedString, placeHolder: "确认新密码（6-20位）".localizedString, isSecure: true)

    private lazy var sureButton = LoadingButton(title: "确认".localizedString)


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "密码修改".localizedString
        
    }

    override func setupViews() {
        view.addSubview(containerView)
        containerView.addSubview(originPwdTextField)
        containerView.addSubview(newPwdTextField)
        containerView.addSubview(confirmPwdTextField)
        containerView.addSubview(sureButton)
        
        
        sureButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.loginClick()
        }
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.left.equalToSuperview().offset(47)
            $0.right.equalToSuperview().offset(-47)
            $0.bottom.equalToSuperview()
        }
        
        originPwdTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(75))
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        newPwdTextField.snp.makeConstraints {
            $0.top.equalTo(originPwdTextField.snp.bottom).offset(ZTScaleValue(30))
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        confirmPwdTextField.snp.makeConstraints {
            $0.top.equalTo(newPwdTextField.snp.bottom).offset(ZTScaleValue(30))
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }

        sureButton.snp.makeConstraints {
            $0.top.equalTo(confirmPwdTextField.snp.bottom).offset(ZTScaleValue(85))
            $0.centerX.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(50)
        }

    }
    
    private func loginClick() {
        if originPwdTextField.text == "" {
            originPwdTextField.warning = "请输入旧密码".localizedString
            self.showToast(string: "请输入旧密码".localizedString)
            return
        }
        
        if newPwdTextField.text == "" {
            newPwdTextField.warning = "请输入新密码".localizedString
            self.showToast(string: "请输入新密码".localizedString)
            return
        }
        
        if confirmPwdTextField.text == "" {
            confirmPwdTextField.warning = "请输入确认密码".localizedString
            self.showToast(string: "请输入确认密码".localizedString)
            return
        }
        
        if newPwdTextField.text != confirmPwdTextField.text {
            showToast(string: "两次新密码输入不一致".localizedString)
            return
        }
        
        ApiServiceManager.shared.changePWD(area: AuthManager.shared.currentArea, old_password: originPwdTextField.text, new_password: confirmPwdTextField.text) {[weak self] response in
            guard let self = self else {return}
            WarningAlert.show(message: "密码已修改，请重新登陆".localizedString,sureTitle: "确定".localizedString,iconImage: .assets(.icon_warning_light)) {
                AuthManager.shared.logOut { [weak self] in
                    self?.navigationController?.popToRootViewController(animated: false)
                    let vc = LoginViewController()
                    vc.hidesBottomBarWhenPushed = true
                    let nav = BaseNavigationViewController(rootViewController: vc)
                    nav.modalPresentationStyle = .overFullScreen
                    AppDelegate.shared.appDependency.tabbarController.present(nav, animated: true, completion: nil)
                }
            }
        } failureCallback: {[weak self] code, err in
            guard let self = self else {return}
//            WarningAlert.show(message: err, sureTitle: "知道了",iconImage: .assets(.icon_warning_light)) {
//
//            }
            self.showToast(string: err)
        }

        
    }

}
