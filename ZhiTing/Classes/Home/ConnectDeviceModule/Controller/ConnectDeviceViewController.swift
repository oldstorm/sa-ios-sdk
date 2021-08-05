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
            $0.top.equalToSuperview().offset(75)
            $0.width.height.equalTo(Screen.screenWidth - 175)
        }
        
        statusLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(percentageView.snp.bottom).offset(20)
        }
    }
    
    
    private func requestNetwork(device: DiscoverDeviceModel?) {
        guard let device = device else { return }
        startLoading()
        
        
        if device.model.contains("smart_assistant") { /// add SA
            ApiServiceManager.shared.addSADevice(url: device.address, device: device) { [weak self] response in
                guard let self = self else { return }
                let success = response.device_id != -1
                if success {
                    self.syncLocalDataToSmartAssistant(info: response.user_info)
                } else {
                    self.failToConnect()
                }
                
            } failureCallback: { [weak self] (code, err) in
                self?.failToConnect()
            }

        } else { /// add device
            ApiServiceManager.shared.addDiscoverDevice(device: device, area: authManager.currentArea) { [weak self] response in
                guard let self = self else {
                    return
                }
                
                let success = response.device_id != -1
                if success {
                    self.removeCallback?()
                    self.device_id = response.device_id
                    self.plugin_url = response.plugin_url
                    self.finishLoadingDevice()
                } else {
                    self.failToConnect()
                }
            } failureCallback: { [weak self] (code, err) in
                self?.failToConnect(err)
            }
        }

    }
    

    private func syncLocalDataToSmartAssistant(info: User) {
        
        let deleteToken = "\(authManager.currentArea.sa_user_token)"
        let deleteAreaId = authManager.currentArea.id

        let realm = try! Realm()
        
        
        
        

        
        let areaSyncModel = SyncSAModel.AreaSyncModel()
        areaSyncModel.name = authManager.currentArea.name
        
        let locations = realm.objects(LocationCache.self).filter("area_id = \(authManager.currentArea.id) AND sa_user_token = '\(authManager.currentArea.sa_user_token)'")
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
        saArea.sa_lan_address = device?.address ?? ""
        saArea.ssid = dependency.networkManager.getWifiSSID()
        saArea.macAddr = dependency.networkManager.getWifiBSSID()
        saArea.sa_user_token = info.token
        saArea.is_bind_sa = true
        saArea.sa_user_id = info.user_id
        saArea.name = authManager.currentArea.name
        saArea.id = self.area.id >= 1 ? self.area.id : 0
        
        
        try? realm.write {
            realm.add(saArea.toAreaCache())
        }
        self.authManager.currentArea = saArea
        
        ApiServiceManager.shared.syncArea(syncModel: syncModel) { [weak self] response in
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
            
            if saArea.id > 0 { // 云端家庭情况下同步完数据到SA后 将SA家庭绑定到云端
                ApiServiceManager.shared.bindCloud(area: saArea, cloud_user_id: self.authManager.currentUser.user_id) { [weak self] response in
                    print("绑定成功")
                    self?.finishLoadingSA()
                    if let area = AreaCache.areaList().first(where: { $0.macAddr == self?.dependency.networkManager.getWifiBSSID() && $0.macAddr != nil }) {
                        self?.authManager.currentArea = area
                    }
                } failureCallback: { [weak self] code, err in
                    print("绑定失败")
                    self?.finishLoadingSA()
                    if let area = AreaCache.areaList().first {
                        self?.authManager.currentArea = area
                    }
                }
            } else {
                self.finishLoadingSA()
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
    
    private func finishLoadingDevice() {
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
    
    private func finishLoadingSA() {
        timer?.invalidate()
        timer = Timer(timeInterval: 0.05, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.count += 0.01
            self.percentageView.setProgress(progress: self.count)
            if self.count >= 1 {
                timer.invalidate()
                self.statusLabel.status = .success
                AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
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
