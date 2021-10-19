//
//  HomekitCodeController.swift
//  ZhiTing
//
//  Created by iMac on 2021/5/27.
//

import UIKit

class HomekitCodeController: BaseViewController {
    var removeCallback: (() -> ())?
    
    var device: DiscoverDeviceModel?
    
    var area = Area()
    
    /// pin attribute的instance_id
    var instance_id = 0
    
    /// 设备详情地址
    var deviceUrl = ""
    
    var device_id = -1

    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.homekit_icon)
    }

    private lazy var tipsLabel1 = Label().then {
        $0.font = .font(size: ZTScaleValue(20), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "输入HomeKit设置代码".localizedString
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var tipsLabel2 = Label().then {
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "请在包装或配件上查找8位设置代码".localizedString
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var inputCodeView = HomekitInputView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Homekit设置代码".localizedString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputCodeView.startEditing()
    }
    
    override func setupViews() {
        view.addSubview(icon)
        view.addSubview(tipsLabel1)
        view.addSubview(tipsLabel2)
        view.addSubview(inputCodeView)
        
        inputCodeView.completeCallback = { [weak self] code in
            guard let self = self else { return }
            self.sendHomekitCode(code: code)

        }

    }

    override func setupConstraints() {
        icon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ZTScaleValue(43))
            $0.height.equalTo(ZTScaleValue(65))
            $0.width.equalTo(ZTScaleValue(140))
        }
        
        tipsLabel1.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(icon.snp.bottom).offset(ZTScaleValue(14))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        tipsLabel2.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(tipsLabel1.snp.bottom).offset(ZTScaleValue(10.5))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        inputCodeView.snp.makeConstraints {
            $0.top.equalTo(tipsLabel2.snp.bottom).offset(ZTScaleValue(40))
            $0.left.right.equalToSuperview()
        }


    }
    
    private func sendHomekitCode(code: String) {
        guard let device = device else { return }
        showLoadingView()
        view.endEditing(true)
        websocket.executeOperation(operation: .setDeviceHomeKitCode(domain: device.plugin_id, identity: device.identity, instance_id: instance_id, code: code))
    }

    override func setupSubscriptions() {
        websocket.setHomekitCodePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] (identity, success) in
                guard let self = self else { return }
                self.hideLoadingView()
                if success && identity == self.device?.identity {
                    self.showToast(string: "设置成功".localizedString)

                    let vc = DeviceSettingViewController()
                    vc.area = self.authManager.currentArea
                    vc.device_id = self.device_id
                    vc.plugin_url = self.deviceUrl
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    if let count = self.navigationController?.viewControllers.count, count - 2 > 0 {
                        self.navigationController?.viewControllers.remove(at: count - 2)
                    }
                } else {
                    self.inputCodeView.clearCode(warning: "设置失败.".localizedString)
                }
                
                

            }
            .store(in: &cancellables)
    }

}

