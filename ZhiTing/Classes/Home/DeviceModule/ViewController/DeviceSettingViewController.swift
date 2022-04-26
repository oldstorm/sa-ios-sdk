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
    var area = Area()

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
        
        if self.area.areaType == .family {
            header.addAreaButton.setTitle("添加房间".localizedString, for: .normal)
        } else {
            header.addAreaButton.setTitle("添加部门".localizedString, for: .normal)
        }

        header.addAreaButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let text1 = self.area.areaType == .family ? "房间名称".localizedString : "部门名称".localizedString
            let text2 = self.area.areaType == .family ? "请输入房间名称".localizedString : "请输入部门名称".localizedString

            let addAreaAlertView = InputAlertView(labelText: text1, placeHolder: text2) { [weak self] text in
                guard let self = self else { return }
                self.addLocation(name: text)
            }
            
            self.addAreaAlertView = addAreaAlertView
            SceneDelegate.shared.window?.addSubview(addAreaAlertView)
        }
    }
    
    override func setupConstraints() {
        header.snp.makeConstraints {
            $0.right.left.equalToSuperview()
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
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

        ApiServiceManager.shared.deviceDetail(area: area, device_id: device_id) { [weak self] (response) in
            guard let self = self else { return }
            self.device = response.device_info
            self.device?.plugin_id = response.device_info.plugin?.id ?? ""
            if self.header.deviceNameTextField.text == "" {
                self.header.deviceNameTextField.text = response.device_info.name
            }
            self.getLocationList()

        } failureCallback: { [weak self] (statusCode, errMessage) in
            self?.showToast(string: errMessage)
        }

    }
    
    private func getLocationList() {
        if area.areaType == .family {
            ApiServiceManager.shared.areaLocationsList(area: area) { [weak self] response in
                guard let self = self else { return }
                self.deviceAreaSettingView.selected_location_id = self.device?.location?.id ?? -1
                self.deviceAreaSettingView.locations = response.locations
                
            } failureCallback: { code, err in
                
            }
        } else {
            ApiServiceManager.shared.departmentList(area: area) { [weak self] response in
                guard let self = self else { return }
                self.deviceAreaSettingView.selected_location_id = self.device?.department?.id ?? -1
                self.deviceAreaSettingView.locations = response.departments
                
            } failureCallback: { code, err in
                
            }
        }
    }
    
    private func addLocation(name: String) {
        
        if deviceAreaSettingView.locations.map(\.name).contains(name) {
            let text = getCurrentLanguage() == .chinese ? "\(name)已存在" : "\(name) already existed"
            self.showToast(string: text)
            return
        }
        
        addAreaAlertView?.saveButton.selectedChangeView(isLoading: true)
        if area.areaType == .family {
            //添加房间
            ApiServiceManager.shared.addLocation(area: area, name: name) { [weak self] (response) in
                self?.addAreaAlertView?.saveButton.selectedChangeView(isLoading: false)
                self?.getLocationList()
                self?.addAreaAlertView?.removeFromSuperview()
            } failureCallback: { [weak self] code, err in
                self?.showToast(string: err)
                self?.addAreaAlertView?.saveButton.selectedChangeView(isLoading: true)
            }
        } else {
            //添加部门
            ApiServiceManager.shared.addDepartment(area: area, name: name) { [weak self] (response) in
                self?.addAreaAlertView?.saveButton.selectedChangeView(isLoading: false)
                self?.getLocationList()
                self?.addAreaAlertView?.removeFromSuperview()
            } failureCallback: { [weak self] code, err in
                self?.showToast(string: err)
                self?.addAreaAlertView?.saveButton.selectedChangeView(isLoading: true)
            }
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
        ApiServiceManager.shared.editDevice(area: area, device_id: device_id, name: name, location_id: deviceAreaSettingView.selected_location_id) { [weak self] _ in
            guard let self = self else { return }
            let device_id = self.device?.id
            let vc = DeviceWebViewController(link: self.plugin_url, device_id: device_id)
            vc.area = self.area
            
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            if let count = self.navigationController?.viewControllers.count,
               count - 2 > 0,
               var vcs = self.navigationController?.viewControllers {
                vcs.remove(at: count - 2)
                self.navigationController?.viewControllers = vcs
            }
            
            
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
        
    }
}

