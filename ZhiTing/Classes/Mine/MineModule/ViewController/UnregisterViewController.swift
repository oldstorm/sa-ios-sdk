//
//  UnregisterViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/1/4.
//

import UIKit
import AttributedString


class UnregisterViewController: BaseViewController {
    
    private lazy var scrollView = UIScrollView(frame: view.bounds)

    private lazy var container = UIView()

    private lazy var phoneLabel = Label().then {
        $0.text = "账号".localizedString + UserManager.shared.currentUser.phone + "正在申请注销".localizedString//"账号(\(UserManager.shared.currentUser.phone))正在申请注销"
        $0.font = .font(size: 18, type: .bold)
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var configTipsLabel = Label().then {
        $0.text = "注销后，你的账号将进行以下处理:".localizedString
        $0.font = .font(size: 14, type: .bold)
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var configDetailLabel = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
    }
    

    private lazy var tipsLabel1 = Label().then {
        $0.text = "永久注销，无法登录".localizedString
        $0.font = .font(size: 14, type: .bold)
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var detailLabel1 = Label().then {
        $0.text = "账号一旦注销，无法登录，且会解除第三方账号的绑定关系".localizedString
        $0.font = .font(size: 14, type: .regular)
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var tipsLabel2 = Label().then {
        $0.text = "所有产品数据将无法找回".localizedString
        $0.font = .font(size: 14, type: .bold)
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var detailLabel2 = Label().then {
        $0.text = "注销后账号在智汀系产品内的云端数据将无法找回".localizedString
        $0.font = .font(size: 14, type: .regular)
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
    }

    private lazy var tipsLabel3 = Label().then {
        $0.text = "智汀云账号通用但不限于以下产品：".localizedString
        $0.font = .font(size: 14, type: .bold)
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var productView1 = ProductView(img: .assets(.app_logo), title: "智汀家庭云".localizedString)
    
    private lazy var productView2 = ProductView(img: .assets(.icon_nas), title: "智汀云盘".localizedString)
    
    private lazy var logOffBtn = Button().then {
        $0.setTitle("申请注销".localizedString, for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.layer.cornerRadius = 4
    }
    
    lazy var alert = UnregisterAlert()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "账号注销".localizedString
        
    }
    
    override func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(container)
        container.addSubview(phoneLabel)
        container.addSubview(configTipsLabel)
        container.addSubview(configDetailLabel)
        container.addSubview(tipsLabel1)
        container.addSubview(detailLabel1)
        container.addSubview(tipsLabel2)
        container.addSubview(detailLabel2)
        container.addSubview(tipsLabel3)
        container.addSubview(productView1)
        container.addSubview(productView2)
        container.addSubview(logOffBtn)
        
        getAreaTips()
        
        alert.sureCallback = { [weak self] in
            guard let self = self else { return }
            self.unregister()

        }

        logOffBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            SceneDelegate.shared.window?.addSubview(self.alert)
        }

    }
    
    override func setupConstraints() {
        
        container.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth)
        }
        
        phoneLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(21)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
        }
        
        configTipsLabel.snp.makeConstraints {
            $0.top.equalTo(phoneLabel.snp.bottom).offset(31)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
        }
        
        configDetailLabel.snp.makeConstraints {
            $0.top.equalTo(configTipsLabel.snp.bottom).offset(13)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
        }
        
        tipsLabel1.snp.makeConstraints {
            $0.top.equalTo(configDetailLabel.snp.bottom)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
        }
        
        detailLabel1.snp.makeConstraints {
            $0.top.equalTo(tipsLabel1.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
        }
        
        tipsLabel2.snp.makeConstraints {
            $0.top.equalTo(detailLabel1.snp.bottom).offset(40)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
        }
        
        detailLabel2.snp.makeConstraints {
            $0.top.equalTo(tipsLabel2.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
        }
        
        tipsLabel3.snp.makeConstraints {
            $0.top.equalTo(detailLabel2.snp.bottom).offset(33)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
        }
        
        productView1.snp.makeConstraints {
            $0.top.equalTo(tipsLabel3.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
        }
        
        productView2.snp.makeConstraints {
            $0.top.equalTo(productView1.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
        }
        
        logOffBtn.snp.makeConstraints {
            $0.top.equalTo(productView2.snp.bottom).offset(42)
            $0.bottom.equalToSuperview().offset(-15)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
            $0.height.equalTo(50)
        }


    }
    
    private func getAreaTips() {
        ApiServiceManager.shared.unregisterList(user_id: UserManager.shared.currentUser.user_id) { [weak self] response in
            guard let self = self else { return }
            var titleText: ASAttributedString = .init(string: "")
            let delete_areas = response.areas.filter({ $0.is_owner == true })
            let quit_areas = response.areas.filter({ $0.is_owner == false })

            if delete_areas.count > 0 {
                let attrStr: ASAttributedString = .init(string: "删除以下公司/家庭\n".localizedString, with: [.font(.font(size: 14, type: .regular)), .foreground(.custom(.black_3f4663))])
                titleText += attrStr
                
                delete_areas.map(\.name).forEach {
                    let attrStr: ASAttributedString = .init(string: "• \($0)\n", with: [.font(.font(size: 14, type: .regular)), .foreground(.custom(.black_3f4663))])
                    titleText += attrStr
                }
            }
            
            titleText += .init("\n")

            if quit_areas.count > 0 {
                let attrStr: ASAttributedString = .init(string: "退出以下公司/家庭\n".localizedString, with: [.font(.font(size: 14, type: .regular)), .foreground(.custom(.black_3f4663))])
                titleText += attrStr
                
                quit_areas.map(\.name).forEach {
                    let attrStr: ASAttributedString = .init(string: "• \($0)\n", with: [.font(.font(size: 14, type: .regular)), .foreground(.custom(.black_3f4663))])
                    titleText += attrStr
                }
            }
            
            
            self.configDetailLabel.attributed.text = titleText

        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            var titleText: ASAttributedString = .init(string: "")
            let attrStr: ASAttributedString = .init(string: "删除以下公司/家庭\n".localizedString, with: [.font(.font(size: 14, type: .regular)), .foreground(.custom(.black_3f4663))])
            titleText += attrStr
            
            AreaCache.areaList().map(\.name).forEach {
                let attrStr: ASAttributedString = .init(string: "• \($0)\n", with: [.font(.font(size: 14, type: .regular)), .foreground(.custom(.black_3f4663))])
                titleText += attrStr
            }
            
            self.configDetailLabel.attributed.text = titleText
        }


       
        
    }
    
    private func unregister() {
        let captchaId = self.alert.captcha_id
        let captcha = self.alert.captchaTextField.text
        
        if captcha == "" {
            showToast(string: "请输入验证码".localizedString)
            return
        }

        alert.isSureBtnLoading = true
        
        ApiServiceManager.shared.unregister(user_id: UserManager.shared.currentUser.user_id, captcha: captcha, captchaId: captchaId) { [weak self] _ in
            guard let self = self else { return }
            AreaCache.removeAllCloudArea()
            UserManager.shared.currentUser.user_id = 0
            UserManager.shared.currentUser.phone = ""
            UserManager.shared.isLogin = false
            
            if AreaCache.areaList().count == 0 {
                AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family)
            }
            
            if let area = AreaCache.areaList().first {
                AuthManager.shared.currentArea = area
            }
            
            self.alert.isSureBtnLoading = false
            self.alert.captchaTextField.textField.text = ""
            self.alert.removeFromSuperview()
            
            let alert = WarningAlert(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight), message: "账号已注销，如需继续使用智汀云服务，可重新绑定云。".localizedString, image: .assets(.icon_warning_light))
            alert.sureBtn.setTitle("确定".localizedString, for: .normal)
            alert.sureCallback = { [weak self] in
                self?.navigationController?.tabBarController?.selectedIndex = 0
                self?.navigationController?.popToRootViewController(animated: false)
                
            }
            SceneDelegate.shared.window?.addSubview(alert)
            
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.alert.isSureBtnLoading = false
            
            if code == 2004 { /// 验证码错误
                self.showToast(string: err)
            } else {
                self.alert.captcha_id = ""
                self.alert.captchaTextField.textField.text = ""
                self.alert.removeFromSuperview()
                let alert = WarningAlert(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight), message: "账号注销失败，请稍后重试".localizedString, image: .assets(.icon_warning_light))
                alert.sureBtn.setTitle("确定".localizedString, for: .normal)
                SceneDelegate.shared.window?.addSubview(alert)
            }
            
        }


    }
}






extension UnregisterViewController {
    class ProductView: UIView {
        private lazy var icon = ImageView().then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 20
            $0.contentMode = .scaleAspectFit
        }
        
        private lazy var titleLabel = Label().then {
            $0.font = .font(size: 14, type: .regular)
            $0.textColor = .custom(.black_3f4663)
        }
        
        convenience init(img: UIImage?, title: String) {
            self.init(frame: .zero)
            icon.image = img
            titleLabel.text = title
            addSubview(icon)
            addSubview(titleLabel)
            
            icon.snp.makeConstraints {
                $0.width.height.equalTo(40)
                $0.bottom.top.equalToSuperview()
                $0.left.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints {
                $0.centerY.equalTo(icon.snp.centerY)
                $0.left.equalTo(icon.snp.right).offset(14)
                $0.right.equalToSuperview().offset(-14)
            }
        }

    }
    
}
