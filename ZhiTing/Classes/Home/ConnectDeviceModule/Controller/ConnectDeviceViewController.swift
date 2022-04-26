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
    
    private lazy var statusView = ConnectStatusView()
    

    
    private lazy var retryBtn = Button().then {
        $0.setTitle("重试".localizedString, for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.layer.cornerRadius = 4
        $0.isHidden = true
    }

    
    private var tokenAlertView: TokenAllowedSettingAlertView?
    
    private var timer: Timer?

    var count: CGFloat = 0.0
    
    var removeCallback: (() -> ())?
    
    var device: DiscoverDeviceModel?
    
    var area = Area()
    

    var plugin_url = ""

    lazy var device_id: Int = -1
    
    /// 设备认证相关属性
    var auth_params: [String: Any]?
    /// 设备认证失败回调
    var authFailCallback: (() -> ())?


    override func viewDidLoad() {
        super.viewDidLoad()
        requestNetwork(device: device)
    }
    
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(percentageView)
        view.addSubview(statusView)
        view.addSubview(retryBtn)
        
        retryBtn.clickCallBack = { [weak self] _ in
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
        
        statusView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(percentageView.snp.bottom).offset(20)
        }
        
        retryBtn.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-15 - Screen.bottomSafeAreaHeight)
        }
    }
    
    override func setupSubscriptions() {
        
        /// 添加websocket发现的设备结果回调
        websocket.connectDevicePublisher
            .receive(on: DispatchQueue.main)
            .filter { $0.0 == self.device?.iid }
            .sink { [weak self] (iid, response) in
                guard let self = self else { return }
                if response.success && iid == self.device?.iid {
                    self.removeCallback?()
                    self.device_id = response.data?.device?.id ?? -1
                    self.plugin_url = response.data?.device?.plugin_url ?? ""
                    self.finishNormalDevice()
                    
                } else {
                    if self.device?.auth_required == true { /// 如果是需要认证的设备根据错误处理
                        guard let error = response.error else {
                            self.failToConnect()
                            return
                        }
                        
                        if error.code == 10006 { /// 认证失败
                            self.authFailCallback?()
                            self.navigationController?.popViewController(animated: true)
                        } else { /// 不是认证失败的情况下停留在该页面展示错误
                            self.failToConnect(failType: .normalDevice(msg: error.message))
                        }
                        
                    } else { /// 如果是不需要认证的设备直接失败
                        self.failToConnect()
                    }
    
                }
            }
            .store(in: &cancellables)
        

    }

    
    private func requestNetwork(device: DiscoverDeviceModel?) {
        guard let device = device else { return }
        
        if device.model.hasPrefix("MH-SA") { /// 添加SA
            guard let device = device as? DiscoverSAModel else { return }
            startLoading()

            device.area_type = area.area_type
            ApiServiceManager.shared.addSADevice(url: device.address, device: device) { [weak self] response in
                guard let self = self else { return }
                let success = response.device_id != -1
                if success {
                    self.syncLocalDataToSmartAssistant(info: response.user_info, area_info: response.area_info, sa_id: device.sa_id)
                } else {
                    self.failToConnect()
                }
                
            } failureCallback: { [weak self] (code, err) in
                self?.failToConnect()
            }

        } else { /// 添加设备
            startLoading()
            websocket.executeOperation(operation: .connectDevice(domain: device.plugin_id, iid: device.iid, auth_params: auth_params))
        }

    }
    
    
    /// 同步家庭信息到SA
    private func syncLocalDataToSmartAssistant(info: User, area_info: AddDeviceResponseModel.AreaInfo, sa_id: String?) {
        
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
        locations.forEach { location in
            let locationSyncModel = SyncSAModel.LocationSyncModel()
            locationSyncModel.name = location.name
            locationSyncModel.sort = sort
            if authManager.currentArea.areaType == .family {
                areaSyncModel.locations.append(locationSyncModel)
            } else {
                areaSyncModel.departments.append(locationSyncModel)
            }
            
            sort += 1
        }
            
        let syncModel = SyncSAModel()
        syncModel.area = areaSyncModel
        syncModel.nickname = UserManager.shared.currentUser.nickname
        
        
        
        let saArea = Area()
        saArea.sa_id = sa_id
        saArea.area_type = area.area_type
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
            if UserManager.shared.isLogin {
                
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
                        self?.failToConnect(err: "云端家庭迁移失败".localizedString)
                    }



                } failureCallback: { [weak self] code, err in
                    self?.failToConnect(err: "获取云端家庭迁移地址失败".localizedString)
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
        statusView.status = .connecting
        retryBtn.isHidden = true
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
                self.statusView.status = .success
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
                    
                    if self.device?.auth_required == true {
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
                self.statusView.status = .success
                
                self.tokenAlertView = TokenAllowedSettingAlertView.show(message: "用户凭证", sureCallback: { [weak self] tap in
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
                        self.navigationController?.popToRootViewController(animated: true)
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
    
    private func failToConnect(err: String = "", failType: ConnectStatusView.Status.FailType = .sa) {
        timer?.invalidate()
        count = 0
        percentageView.setProgress(progress: 0)
        statusView.status = .fail(type: failType)
        
        switch failType {
        case .sa:
            retryBtn.isHidden = false
        case .normalDevice:
            retryBtn.isHidden = true
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
