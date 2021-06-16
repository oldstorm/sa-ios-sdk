//
//  DeviceSetAreaViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/16.
//

import UIKit

class DeviceSetLocationViewController: BaseViewController {
    var device: Device?

    private lazy var addButton = Button().then {
        $0.setTitle("添加房间/区域".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        if getCurrentLanguage() == .chinese {
            $0.titleLabel?.font = .font(size: 14, type: .bold)
        } else {
            $0.titleLabel?.font = .font(size: 12, type: .bold)
        }
        
    }
    
    private lazy var deviceAreaSettingView = DeviceLocationSettingView()
    
    private lazy var doneButton = BottomButton(frame: .zero, icon: nil, title: "完成".localizedString, titleColor: .custom(.white_ffffff), backgroundColor: .custom(.blue_2da3f6)).then {
        $0.clickCallBack = { [weak self] in
            guard let self = self else { return }
            self.save()
        }
    }
    
    private var addAreaAlertView: InputAlertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "设置位置".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestNetwork()
    }
    
    override func setupViews() {
        view.addSubview(deviceAreaSettingView)
        view.addSubview(doneButton)
        
        addButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let addAreaAlertView = InputAlertView(labelText: "房间/区域名称".localizedString, placeHolder: "请输入房间/区域名称".localizedString) { [weak self] text in
                guard let self = self else { return }
                self.addLocation(name: text)
                
            }
            
            self.addAreaAlertView = addAreaAlertView
            SceneDelegate.shared.window?.addSubview(addAreaAlertView)
        }
    }
    
    override func setupConstraints() {
        doneButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }

        deviceAreaSettingView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalTo(doneButton.snp.top)
        }
    }

}

extension DeviceSetLocationViewController {
    private func requestNetwork() {
       
        apiService.requestModel(.areaLocationsList, modelType: AreaLocationListResponse.self) { [weak self](response) in
            guard let self = self else { return }
            self.deviceAreaSettingView.selected_location_id = self.device?.location.id ?? -1
            self.deviceAreaSettingView.locations = response.locations
            

        }
    }
    
    private func addLocation(name: String) {
        
        
        if deviceAreaSettingView.locations.map(\.name).contains(name) {
            let text = getCurrentLanguage() == .chinese ? "\(name)已存在" : "\(name) already existed"
            self.showToast(string: text)
            return
        }
        
        apiService.requestModel(.addLocation(name: name), modelType: BaseModel.self) { [weak self] (response) in
            self?.requestNetwork()
            self?.addAreaAlertView?.removeFromSuperview()
        } failureCallback: { [weak self] code, err in
            self?.showToast(string: err)
        }
        
    }
    
    private func save() {
        guard let device_id = device?.id else { return }
        
        let location_id = deviceAreaSettingView.selected_location_id
        
        apiService.requestModel(.editDevice(device_id: device_id, name: "", location_id: location_id), modelType: BaseModel.self) { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
            self.showToast(string: "保存成功".localizedString)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
    }
    
    
}

extension DeviceSetLocationViewController {
    private class AreaLocationListResponse: BaseModel {
        var locations = [Location]()
    }
}
