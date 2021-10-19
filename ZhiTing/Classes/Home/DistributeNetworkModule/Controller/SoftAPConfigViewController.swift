//
//  SoftAPConfigViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/9/7.
//


import UIKit
import NetworkExtension
import ESPProvision

class SoftAPConfigViewController: BaseViewController {
    #warning("暂时写死设备热点SSID")
    lazy var deviceSSID = "ZTSW3ZL001W"
    
    /// 智汀设备配网工具
    private lazy var apConfigTool = ZTAPDistributionTool()
    
    private lazy var espProvisionTool = SoftAPTool()
    

    private lazy var deviceImgView = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.default_device)
    }
    
    private lazy var deviceNameLabel = Label().then {
        $0.text = ""
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
    }

    private lazy var wifiTextField = TitleTextField(title: "".localizedString, placeHolder: "请输入wifi名称".localizedString, isSecure: false, limitCount: 63).then {
        $0.textField.leftViewMode = .always
        
        let imageView = ImageView(frame: CGRect(x: 0, y: 11, width: 18, height: 18))
        imageView.image = .assets(.icon_wifi)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 40))
        leftView.clipsToBounds = true
        leftView.addSubview(imageView)
        
        
        $0.textField.leftView = leftView
    }
    
    private lazy var pwdTextField = TitleTextField(title: "".localizedString, placeHolder: "请输入wifi密码".localizedString, isSecure: true, limitCount: 63).then {
        $0.textField.leftViewMode = .always
        
        let imageView = ImageView(frame: CGRect(x: 0, y: 11, width: 18, height: 18))
        imageView.image = .assets(.icon_lock)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 40))
        leftView.clipsToBounds = true
        leftView.addSubview(imageView)
        

        
        $0.textField.leftView = leftView
    }
    
    private lazy var nextButton = LoadingButton(title: "下一步".localizedString)
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        wifiTextField.textField.text = NetworkStateManager.shared.getWifiSSID() ?? ""

    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "设备配网".localizedString
        
    }

    
    override func setupViews() {
        view.addSubview(deviceImgView)
        view.addSubview(deviceNameLabel)
        view.addSubview(wifiTextField)
        view.addSubview(pwdTextField)
        view.addSubview(nextButton)
        nextButton.addTarget(self, action: #selector(setupDeviceWifi), for: .touchUpInside)

    }

    override func setupConstraints() {
        deviceImgView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ZTScaleValue(43))
            $0.width.height.equalTo(ZTScaleValue(105))
        }
        
        deviceNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(deviceImgView.snp.bottom).offset(5)
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        wifiTextField.snp.makeConstraints {
            $0.top.equalTo(deviceNameLabel.snp.bottom).offset(ZTScaleValue(55))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))

        }
        
        pwdTextField.snp.makeConstraints {
            $0.top.equalTo(wifiTextField.snp.bottom).offset(ZTScaleValue(10))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))

        }
        

        nextButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(ZTScaleValue(-10 - Screen.bottomSafeAreaHeight))
        }


    }
    
    

}


extension SoftAPConfigViewController {

    /// 为设备配网
    @objc func setupDeviceWifi() {

        let ssid = wifiTextField.text
        let pwd = pwdTextField.text
        
        if ssid.count == 0 {
            showToast(string: "请先输入wifi名称".localizedString)
            return
        }

        if pwd.count == 0 {
            showToast(string: "请先输入密码".localizedString)
            return
        }
        
        nextButton.buttonState = .waiting
        



    }
}

