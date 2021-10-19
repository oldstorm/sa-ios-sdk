//
//  ConnectDeviceViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit
import RealmSwift

class ConnectDeviceViewController: BaseViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "设备连接".localizedString
    }
    
    private lazy var percentageView = ConnectPercentageView()
    
    private lazy var statusLabel = ConnectStatusLabel()
    
    private var timer: Timer?

    var count: CGFloat = 0.0
    
    var removeCallback: (() -> ())?
    
    var device: DiscoverDeviceModel?
    
    var area = Area()
    

    var plugin_url = ""

    lazy var device_id: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestNetwork(device: device)
    }
    
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(percentageView)
        view.addSubview(statusLabel)
        
        
        statusLabel.reconnectCallback = { [weak self] in
            guard let self = self else { return }
            self.requestNetwork(device: self.device)
        }
  
    }
    
    override func setupConstraints() {
        percentageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(75 + Screen.k_nav_height)
            $0.width.height.equalTo(Screen.screenWidth - 175)
        }
        
        statusLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(percentageView.snp.bottom).offset(20)
        }
    }
    
    override func setupSubscriptions() {
        websocket.deviceStatusPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] response in
                guard let self = self else { return }
                

                response.device.instances.forEach { instance in
                    instance.attributes.forEach { attr in
                        if attr.attribute == "pin" && (attr.val as? String) == "" {
                            /// 如果homekit设备pin码未设置时 跳转设置homekit pin码
                            self.finishHomeKitDevice(instance_id: instance.instance_id)
                            return
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    
    private func requestNetwork(device: DiscoverDeviceModel?) {
        guard let device = device else { return }
        startLoading()
        
        
        if device.model.contains("smart_assistant") { /// 添加SA
            ApiServiceManager.shared.addSADevice(url: device.address, device: device) { [weak self] response in
                guard let self = self else { return }
                let success = response.device_id != -1
                if success {
                    self.syncLocalDataToSmartAssistant(info: response.user_info, area_info: response.area_info)
                } else {
                    self.failToConnect()
                }
                
            } failureCallback: { [weak self] (code, err) in
                self?.failToConnect()
            }

        } else { /// 添加设备
            ApiServiceManager.shared.addDiscoverDevice(device: device, area: authManager.currentArea) { [weak self] response in
                guard let self = self else {
                    return
                }
                
                let success = response.device_id != -1
                if success {
                    self.removeCallback?()
                    self.device_id = response.device_id
                    self.plugin_url = response.plugin_url
                    if device.plugin_id.lowercased() == "homekit" { /// 如果是homekit设备
                        self.websocket.executeOperation(operation: .getDeviceAttributes(domain: device.plugin_id, identity: device.identity))
                    } else { /// 普通设备
                        self.finishNormalDevice()
                    }

                    
                } else {
                    self.failToConnect()
                }
            } failureCallback: { [weak self] (code, err) in
                self?.failToConnect(err)
            }
        }

    }
    
    
    /// 同步家庭信息到SA
    private func syncLocalDataToSmartAssistant(info: User, area_info: AddDeviceResponseModel.AreaInfo) {
        
        let deleteToken = "\(authManager.currentArea.sa_user_token)"
        let deleteAreaId: String
        if let deleteId = authManager.currentArea.id {
            deleteAreaId = "'\(deleteId)'"
        } else {
            deleteAreaId = "nil"
        }


        let realm = try! Realm()
        
        let areaSyncModel = SyncSAModel.AreaSyncModel()
        areaSyncModel.name = authManager.currentArea.name
        
        let locations = realm.objects(LocationCache.self).filter("area_id = \(deleteAreaId) AND sa_user_token = '\(authManager.currentArea.sa_user_token)'")
        var sort = 1
        locations.forEach { area in
            let locationSyncModel = SyncSAModel.LocationSyncModel()
            locationSyncModel.name = area.name
            locationSyncModel.sort = sort
            areaSyncModel.locations.append(locationSyncModel)
            sort += 1
        }
            
        let syncModel = SyncSAModel()
        syncModel.area = areaSyncModel
        syncModel.nickname = authManager.currentUser.nickname
        
        
        
        let saArea = Area()
        saArea.sa_lan_address = device?.address
        saArea.ssid = networkStateManager.getWifiSSID()
        saArea.bssid = networkStateManager.getWifiBSSID()
        saArea.sa_user_token = info.token
        saArea.is_bind_sa = true
        saArea.sa_user_id = info.user_id
        saArea.name = authManager.currentArea.name
        /// 这个id是SA上的areaID
        saArea.id = area_info.id
        
        
       
        
        ApiServiceManager.shared.syncArea(syncModel: syncModel, url: device?.address ?? "", token: saArea.sa_user_token) { [weak self] response in
            guard let self = self else { return }
            
            if let area = realm.objects(AreaCache.self).filter("sa_user_token = '\(deleteToken)'").first {
                let devices = realm.objects(DeviceCache.self).filter("area_id = \(deleteAreaId) AND sa_user_token = '\(deleteToken)'")
                let locations = realm.objects(LocationCache.self).filter("area_id = \(deleteAreaId) AND sa_user_token = '\(deleteToken)'")
                try? realm.write {
                    realm.delete(devices)
                    realm.delete(locations)
                    realm.delete(area)
                }
            }
            
            // 云端家庭情况下同步完数据到SA后 将SA家庭绑定到云端
            if AuthManager.shared.isLogin {

                ApiServiceManager.shared.bindCloud(area: saArea, cloud_area_id: deleteAreaId, cloud_user_id: self.authManager.currentUser.user_id, url: saArea.sa_lan_address ?? "") { [weak self] response in
                    guard let self = self else { return }
                    try? realm.write {
                        realm.add(saArea.toAreaCache())
                    }
                    self.authManager.currentArea = saArea
                    print("绑定成功")
                    self.finishSA()
                    
                } failureCallback: { [weak self] code, err in
                    guard let self = self else { return }

                    print("绑定失败")
                    try? realm.write {
                        realm.add(saArea.toAreaCache())
                    }
                    self.authManager.currentArea = saArea
                    self.finishSA()
                }
            } else {
                try? realm.write {
                    realm.add(saArea.toAreaCache())
                }
                self.authManager.currentArea = saArea
                self.finishSA()
            }

        } failureCallback: { [weak self] (code, err) in
            self?.failToConnect()
        }

        
        
    }
}

extension ConnectDeviceViewController {
    private func startLoading() {
        timer?.invalidate()
        percentageView.setProgress(progress: 0)
        statusLabel.status = .connecting
        timer = Timer(timeInterval: 0.05, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.count += 0.01
            self.percentageView.setProgress(progress: self.count)
            if self.count >= 0.95 {
                timer.invalidate()
            }
        })
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    /// 成功添加普通设备
    private func finishNormalDevice() {
        timer?.invalidate()
        timer = Timer(timeInterval: 0.05, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.count += 0.01
            self.percentageView.setProgress(progress: self.count)
            if self.count >= 1 {
                timer.invalidate()
                self.statusLabel.status = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self = self else { return }
                    let vc = DeviceSettingViewController()
                    vc.area = self.authManager.currentArea
                    vc.device_id = self.device_id
                    vc.plugin_url = self.plugin_url
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    if let count = self.navigationController?.viewControllers.count, count - 2 > 0 {
                        self.navigationController?.viewControllers.remove(at: count - 2)
                    }
                }
                
            }
        })
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    /// 成功添加普通设备
    private func finishHomeKitDevice(instance_id: Int) {
        timer?.invalidate()
        timer = Timer(timeInterval: 0.05, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.count += 0.01
            self.percentageView.setProgress(progress: self.count)
            if self.count >= 1 {
                timer.invalidate()
                self.statusLabel.status = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self = self else { return }
                    let vc = HomekitCodeController()
                    vc.device = self.device
                    vc.area = self.area
                    vc.deviceUrl = self.plugin_url
                    vc.device_id = self.device_id
                    vc.instance_id = instance_id
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    if let count = self.navigationController?.viewControllers.count, count - 2 > 0 {
                        self.navigationController?.viewControllers.remove(at: count - 2)
                    }
                }
                
            }
        })
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }

    /// 成功添加SA
    private func finishSA() {
        timer?.invalidate()
        timer = Timer(timeInterval: 0.05, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.count += 0.01
            self.percentageView.setProgress(progress: self.count)
            if self.count >= 1 {
                timer.invalidate()
                self.statusLabel.status = .success
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self = self else { return }
                    self.navigationController?.popToRootViewController(animated: true)
                }
                
            }
        })
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func failToConnect(_ err: String = "") {
        timer?.invalidate()
        count = 0
        percentageView.setProgress(progress: 0)
        statusLabel.status = .fail
        if err != "" {
            showToast(string: err)
        }
    }
}


extension ConnectDeviceViewController {
    private class ResponseModel: BaseModel {
        var device_id: Int = -1
        var user_info = User()
        var plugin_url = ""
    }
    
}
