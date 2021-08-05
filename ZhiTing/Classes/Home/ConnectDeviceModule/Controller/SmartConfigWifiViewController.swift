//
//  SetWifiViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/5/31.
//

import UIKit
import NetworkExtension


class SmartConfigWifiViewController: BaseViewController {
    var espHandler = ESPTouchHandler()
    var espHandlerDelegate = ESPDelegateImpl()
    
    lazy var wifiModel = WifiModel()


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

    private lazy var wifiTextField = TitleTextField(keyboardType: .numberPad, title: "".localizedString, placeHolder: "请输入WIFI名".localizedString, isSecure: false, limitCount: 63).then {
        $0.textField.leftViewMode = .always
        
        let imageView = ImageView(frame: CGRect(x: 0, y: 11, width: 18, height: 18))
        imageView.image = .assets(.icon_wifi)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 40))
        leftView.clipsToBounds = true
        leftView.addSubview(imageView)
        
        
        $0.isUserInteractionEnabled = false
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
    
    private lazy var chooseOtherButton = Button().then {
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .regular)
        $0.setTitle("连接至其他路由器".localizedString, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wifiModel.ssid = networkStateManager.getWifiSSID() ?? ""
        wifiModel.bssid = networkStateManager.getWifiBSSID() ?? ""
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "连接路由器".localizedString
        updateWifiName()
    }

    
    override func setupViews() {
        view.addSubview(deviceImgView)
        view.addSubview(deviceNameLabel)
        view.addSubview(wifiTextField)
        view.addSubview(pwdTextField)
        view.addSubview(nextButton)
        view.addSubview(chooseOtherButton)
        
        chooseOtherButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let vc = HistoryWifiViewController()
            vc.callback = { [weak self] wifi in
                guard let self = self else { return }
                self.wifiModel = wifi
                self.updateWifiName()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        

        
        nextButton.addTarget(self, action: #selector(setupDeviceWifi), for: .touchUpInside)
        
        espHandlerDelegate.resultCallback = { [weak self] result in
            guard let self = self else { return }
            self.nextButton.buttonState = .normal
            if result.isSuc {
                self.showToast(string: "配网成功")
                print(result.bssid!)
                print(result.getAddressString()!)
            } else {
                self.showToast(string: "配网失败")
            }
        }
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
        
        
        chooseOtherButton.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.width.equalTo(180)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(ZTScaleValue(-10 - Screen.bottomSafeAreaHeight))
        }

        nextButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.equalTo(50)
            $0.bottom.equalTo(chooseOtherButton.snp.top).offset(ZTScaleValue(-20))
        }


    }
    

    
    
    private func updateWifiName() {
        wifiTextField.textField.text = wifiModel.ssid
    }

}

extension SmartConfigWifiViewController {
    @objc
    private func getWifiList() {
        let queue = DispatchQueue(label: "com.zhiting.hotspotHelper", qos: .default)

        NEHotspotHelper.register(options: nil, queue: queue) { cmd in
            if cmd.commandType == .filterScanList {
                cmd.networkList?.forEach { network in
                    print(network.ssid)
                }
            }
        }
    }
    
    /// 为设备配网
    @objc
    func setupDeviceWifi() {
        if wifiModel.ssid == "" || wifiModel.bssid == "" {
            return
        }
        
        let pwd = pwdTextField.text
        
        if pwd.count == 0 {
            showToast(string: "请先输入密码".localizedString)
            return
        }
        
        
        
        nextButton.buttonState = .waiting
        espHandler.executeSmartConfig(wifiModel.ssid, bssid: wifiModel.bssid, password: pwd, taskCount: 1, broadcast: true, delegate: espHandlerDelegate)


    }
}


class ESPDelegateImpl: EspTouchDelegateImplement {
    var resultCallback: ((ESPTouchResult) -> ())?

    override func onEsptouchResultAdded(with result: ESPTouchResult!) {
        DispatchQueue.main.async {
            self.resultCallback?(result)
        }
    }
}
