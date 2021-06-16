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
    var area: Area?
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
            apiService.requestModel(.addSADevice(url: device.address, device: device), modelType: ResponseModel.self) { [weak self] response in
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
            apiService.requestModel(.addDiscoverDevice(device: device), modelType: ResponseModel.self, successCallback:  { [weak self] response in
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
            }, failureCallback: { [weak self] (code, err) in
                self?.failToConnect(err)
            })
        }

    }
    

    private func syncLocalDataToSmartAssistant(info: User) {
        let sa = SmartAssistantCache()
        sa.token = info.token
        sa.ip_address = device?.address ?? ""
        sa.user_id = info.user_id
        sa.nickname = authManager.currentSA.nickname
        SmartAssistantCache.cacheSmartAssistants(sa: sa)
        authManager.currentSA = sa.transformToSAModel()
        
        let realm = try! Realm()
        
        guard
            let currentArea = area,
            currentArea.sa_token.contains("unbind"),
            let area = realm.objects(AreaCache.self).filter("sa_token = '\(currentArea.sa_token)'").first
        else {
            failToConnect()
            return
            
        }
        

        
        let areaSyncModel = SyncSAModel.AreaSyncModel()
        areaSyncModel.name = area.name
        
        let areas = realm.objects(LocationCache.self).filter("area_id = \(area.id) AND sa_token = '\(area.sa_token)'")
        var sort = 1
        areas.forEach { area in
            let locationSyncModel = SyncSAModel.LocationSyncModel()
            locationSyncModel.name = area.name
            locationSyncModel.sort = sort
            areaSyncModel.locations.append(locationSyncModel)
            sort += 1
        }
            

            
            
        
        let syncModel = SyncSAModel()
        syncModel.area = areaSyncModel
        syncModel.nickname = authManager.currentSA.nickname
        
        apiService.requestModel(.syncArea(syncModel: syncModel), modelType: BaseModel.self) { [weak self] response in
            guard let self = self else { return }
            
            if let area = realm.objects(AreaCache.self).filter("sa_token = '\(currentArea.sa_token)'").first {
                
                
                let locations = realm.objects(LocationCache.self).filter("area_id = \(area.id) AND sa_token = '\(area.sa_token)'")
                try? realm.write {
                    locations.forEach { area in
                        realm.delete(area)
                    }
                    
                }
                
                try? realm.write {
                    realm.delete(area)
                }
            }
            
            self.finishLoadingSA()

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
