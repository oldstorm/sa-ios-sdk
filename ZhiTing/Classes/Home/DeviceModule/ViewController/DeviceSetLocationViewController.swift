//
//  DeviceSetAreaViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/16.
//

import UIKit

class DeviceSetLocationViewController: BaseViewController {
    var device: Device?
    var area = Area()

    private lazy var addButton = Button().then {
        $0.setTitle("添加房间/区域".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        if getCurrentLanguage() == .chinese {
            $0.titleLabel?.font = .font(size: 14, type: .bold)
        } else {
            $0.titleLabel?.font = .font(size: 12, type: .bold)
        }
        
    }
    
    private lazy var loadingView = LodingView().then {
        $0.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight - Screen.k_nav_height)
    }
    
    
    private lazy var deviceLocationSettingView = DeviceLocationSettingView()
    
    private lazy var doneButton = ImageTitleButton(frame: .zero, icon: nil, title: "完成".localizedString, titleColor: .custom(.white_ffffff), backgroundColor: .custom(.blue_2da3f6)).then {
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
        view.addSubview(deviceLocationSettingView)
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

        deviceLocationSettingView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalTo(doneButton.snp.top)
        }
    }

    private func showLoadingView(){
        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        loadingView.show()
    }
    
    private func hideLoadingView(){
        loadingView.hide()
        loadingView.removeFromSuperview()
    }
    
}

extension DeviceSetLocationViewController {
    private func requestNetwork() {
       showLoadingView()
        ApiServiceManager.shared.areaLocationsList(area: area) { [weak self] (response) in
            guard let self = self else { return }
            self.hideLoadingView()
            self.deviceLocationSettingView.selected_location_id = self.device?.location.id ?? -1
            self.deviceLocationSettingView.locations = response.locations

        } failureCallback: { [weak self] code, err in
            self?.hideLoadingView()
            self?.showToast(string: err)
        }
    }
    
    private func addLocation(name: String) {
        
        
        if deviceLocationSettingView.locations.map(\.name).contains(name) {
            let text = getCurrentLanguage() == .chinese ? "\(name)已存在" : "\(name) already existed"
            self.showToast(string: text)
            return
        }
        
        addAreaAlertView?.saveButton.selectedChangeView(isLoading: true)
        ApiServiceManager.shared.addLocation(area: area, name: name) { [weak self] (response) in
            self?.addAreaAlertView?.saveButton.selectedChangeView(isLoading: false)
            self?.requestNetwork()
            self?.addAreaAlertView?.removeFromSuperview()
        } failureCallback: { [weak self] code, err in
            self?.showToast(string: err)
            self?.addAreaAlertView?.saveButton.selectedChangeView(isLoading: false)
        }
        
    }
    
    private func save() {
        guard let device_id = device?.id else { return }
        
        let location_id = deviceLocationSettingView.selected_location_id
        
        ApiServiceManager.shared.editDevice(area: area, device_id: device_id, name: "",location_id: location_id) { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
            self.showToast(string: "保存成功".localizedString)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }

    }
    
    
}
