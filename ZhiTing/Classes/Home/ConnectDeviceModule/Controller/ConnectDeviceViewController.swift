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
    
    private var tokenAlertView: TokenAllowedSettingAlertView?
    
    private var timer: Timer?

    var count: CGFloat = 0.0
    
    var removeCallback: (() -> ())?
    
    var device: DiscoverDeviceModel?
    
    var area = Area()
    

    var plugin_url = ""

    lazy var device_id: Int = -1
    
    // homekit相关
    var homekitCode = ""
    var homekitCodeFailCallback: (() -> ())?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let device = device, device.plugin_id.lowercased() == "homekit" {
            startLoading()
            websocket.executeOperation(operation: .setDeviceHomeKitCode(domain: device.plugin_id, identity: device.identity, instance_id: 1, code: homekitCode))
        } else {
            requestNetwork(device: device)
        }
        
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
        websocket.setHomekitCodePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] (identity, success) in
                guard let self = self else { return }
                self.hideLoadingView()
                if success && identity == self.device?.identity {
                    self.requestNetwork(device: self.device)
                } else {
                    self.homekitCodeFailCallback?()
                    self.navigationController?.popViewController(animated: true)
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
                    self.finishNormalDevice()
                    
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
            
            // 云端家庭情况下同步完数据到SA后,进行云端家庭迁移流程
            if AuthManager.shared.isLogin {
                
                // 1. 请求云端家庭迁移地址
                ApiServiceManager.shared.getMigrationUrl(area: AuthManager.shared.currentArea) { [weak self] resp in
                    guard let self = self else { return }
                    // 2.请求本地SA进行云端家庭迁移
                    ApiServiceManager.shared.migrateCloudToLocal(area: saArea, migration_url: resp.url, backup_file: resp.backup_file, sum: resp.sum) { [weak self] _ in
                        guard let self = self else { return }
                        // 迁移成功后 家庭id、token等变成云端的信息
                        saArea.id = AuthManager.shared.currentArea.id
                        saArea.sa_user_token = AuthManager.shared.currentArea.sa_user_token
                        saArea.sa_user_id = AuthManager.shared.currentArea.sa_user_id
                        try? realm.write {
                            realm.add(saArea.toAreaCache())
                        }
                        self.authManager.currentArea = saArea
                        self.finishSA()

                    } failureCallback: { [weak self] code, err in
                        self?.failToConnect("云端家庭迁移失败".localizedString)
                    }



                } failureCallback: { [weak self] code, err in
                    self?.failToConnect("获取云端家庭迁移地址失败".localizedString)
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
                    
                    
                    
                    if let count = self.navigationController?.viewControllers.count,
                       count - 2 > 0,
                       var vcs = self.navigationController?.viewControllers {
                        vcs.remove(at: count - 2)
                        self.navigationController?.viewControllers = vcs
                    }
                    
                    if self.device?.plugin_id.lowercased() == "homekit" {
                        if let count = self.navigationController?.viewControllers.count,
                           count - 3 > 0,
                           var vcs = self.navigationController?.viewControllers {
                            vcs.remove(at: count - 2)
                            vcs.remove(at: count - 3)
                            self.navigationController?.viewControllers = vcs
                        }
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
                
                self.tokenAlertView = TokenAllowedSettingAlertView.show(message: "找回用户凭证", sureCallback: { [weak self] tap in
                    guard let self = self else { return }
                    self.tokenAlertView?.isSureBtnLoading = true
                    let token = TokenAuthSettingModel()
                    token.user_credential_found = tap == 1 ? true : false
                    //设置权限
                    ApiServiceManager.shared.settingTokenAuth(area: self.authManager.currentArea, tokenModel: token) { [weak self] _ in
                        guard let self = self else { return }
                        self.tokenAlertView?.isSureBtnLoading = false
                        self.navigationController?.popToRootViewController(animated: true)
                    } failureCallback: { [weak self] code, error in
                        guard let self = self else { return }
                        self.showToast(string: error)
                    }

                }, cancelCallback: { [weak self] in
                    guard let self = self else { return }
                    self.navigationController?.popToRootViewController(animated: true)
                }, removeWithSure: true)
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
        if device?.plugin_id.lowercased() == "homekit" {
            statusLabel.reconnectBtn.isHidden = true
        }

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
