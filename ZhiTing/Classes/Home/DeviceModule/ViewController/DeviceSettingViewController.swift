//
//  DeviceSettingViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/16.
//

import UIKit
import IQKeyboardManagerSwift

class DeviceSettingViewController: BaseViewController {
    var device_id: Int?
    var device: Device?
    
    var plugin_url = ""
    private lazy var header = DeviceSettingHeader()

    private lazy var deviceAreaSettingView = DeviceLocationSettingView()
    
    private lazy var doneButton = ImageTitleButton(frame: .zero, icon: nil, title: "完成".localizedString, titleColor: .custom(.white_ffffff), backgroundColor: .custom(.blue_2da3f6)).then {
        $0.clickCallBack = { [weak self] in
            guard let self = self else { return }
            self.done()
        }
    }
    
    private var addAreaAlertView: InputAlertView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "设置".localizedString
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestNetwork()
    }
    
    override func setupViews() {
        view.addSubview(header)
        view.addSubview(deviceAreaSettingView)
        view.addSubview(doneButton)
        
        
        header.addAreaButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let addAreaAlertView = InputAlertView(labelText: "房间/区域名称".localizedString, placeHolder: "请输入房间/区域名称".localizedString) { [weak self] text in
                guard let self = self else { return }
                self.addArea(name: text)
            }
            
            self.addAreaAlertView = addAreaAlertView
            SceneDelegate.shared.window?.addSubview(addAreaAlertView)
        }
    }
    
    override func setupConstraints() {
        header.snp.makeConstraints {
            $0.top.right.left.equalToSuperview()
        }
        
        
        doneButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }

        deviceAreaSettingView.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalTo(doneButton.snp.top)
        }
    }

}

extension DeviceSettingViewController {
    private func requestNetwork() {
        guard let device_id = device_id else {
            return
        }

        apiService.requestModel(.deviceDetail(device_id: device_id), modelType: DeviceInfoResponse.self) { [weak self] (response) in
            guard let self = self else { return }
            self.device = response.device_info
            if self.header.deviceNameTextField.text == "" {
                self.header.deviceNameTextField.text = response.device_info.name
            }
            self.getAreaList()

        } failureCallback: { [weak self] (statusCode, errMessage) in
            self?.showToast(string: errMessage)
        }

    }
    
    private func getAreaList() {
        
        apiService.requestModel(.areaLocationsList, modelType: AreaLocationListResponse.self) { [weak self](response) in
            guard let self = self else { return }
            self.deviceAreaSettingView.selected_location_id = self.device?.location.id ?? -1
            self.deviceAreaSettingView.locations = response.locations
            

        }
    }
    
    private func addArea(name: String) {
        
        
        if deviceAreaSettingView.locations.map(\.name).contains(name) {
            let text = getCurrentLanguage() == .chinese ? "\(name)已存在" : "\(name) already existed"
            self.showToast(string: text)
            return
        }

        apiService.requestModel(.addLocation(name: name), modelType: BaseModel.self) { [weak self] (response) in
            self?.getAreaList()
            self?.addAreaAlertView?.removeFromSuperview()
        } failureCallback: { [weak self] code, err in
            self?.showToast(string: err)
        }
        
    }
    
    
    private func done() {
        guard
            let device_id = device?.id,
            let name = header.deviceNameTextField.text
        else {
            showToast(string: "error")
            return
            
        }
        
        if header.deviceNameTextField.text == "" || header.deviceNameTextField.text?.replacingOccurrences(of: " ", with: "") == "" {
            showToast(string: "设备名不能为空".localizedString)
            return
        }
        
        /// edit device
        apiService.requestModel(.editDevice(device_id: device_id, name: name, location_id: deviceAreaSettingView.selected_location_id), modelType: BaseModel.self) { [weak self] _ in
            guard let self = self else { return }
            let device_id = self.device?.id ?? -1
            let vc = DeviceWebViewController(link: self.plugin_url, device_id: device_id)
            self.navigationController?.pushViewController(vc, animated: true)
            
            if let count = self.navigationController?.viewControllers.count, count - 2 > 0 {
                self.navigationController?.viewControllers.remove(at: count - 2)
            }
            
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
        
        
    }
}

extension DeviceSettingViewController {
    private class DeviceInfoResponse: BaseModel {
        var device_info = Device()
    }
    
    private class AreaLocationListResponse: BaseModel {
        var locations = [Location]()
    }
}
