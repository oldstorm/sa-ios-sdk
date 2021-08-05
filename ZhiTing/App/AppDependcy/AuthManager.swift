//
//  AuthManager.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/24.
//

import Foundation
import Moya
import Combine


class AuthManager {
    var apiService: MoyaProvider<ApiService> {
        return AppDelegate.shared.appDependency.apiService
    }
    
    var networkStateManager: NetworkStateManager {
        return AppDelegate.shared.appDependency.networkManager
    }
    
    /// 同步家庭队列
    lazy var syncAreaOperationQueue = OperationQueue().then {
        $0.maxConcurrentOperationCount = 1
    }
    /// 同步家庭队列锁
    lazy var operationSemaphore = DispatchSemaphore(value: 1)
    
    /// 当前选中家庭
    var currentArea = Area() {
        didSet {
            updateCurrentArea()
        }
    }
    
    var ztWebSocket: ZTWebSocket {
        return AppDelegate.shared.appDependency.websocket
    }

    var currentRolePermissions = RolePermission() {
        didSet {
            self.roleRefreshPublisher.send(())
        }
    }
    
    
    var roleRefreshPublisher = PassthroughSubject<Void, Never>()
    
    let currentAreaPublisher = PassthroughSubject<Area, Never>()
    
    let currentAPublisher = CurrentValueSubject<Area, Never>(Area())
    /// 是否在SA环境下
    var isSAEnviroment: Bool {
        let stateManager = AppDelegate.shared.appDependency.networkManager
        guard
            let macAddress = stateManager.getWifiBSSID(),
            let areaMacAddress = currentArea.macAddr
        else {
            return false
        }
        
        if macAddress == areaMacAddress { //判断wifi mac地址相同
            return true
        }
        
        return false
    }
    
    /// 是否登录云端账号
    var isLogin: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "zhiting.userDefault.isLogin")
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "zhiting.userDefault.isLogin")
            UserDefaults.standard.synchronize()
        }
    }
    
    /// 当前账号
    var currentUser = User()
    
    /// 当前家庭切换后更新状态
    func updateCurrentArea() {
        updateCurrentNickname()
        
        
        AppDelegate.shared.appDependency.websocket.disconnect()
        
        if isLogin && !isSAEnviroment {
            let addr = cloudUrl
            if addr.contains("http://"),
               let scAddr = addr.components(separatedBy: "http://").last {
                AppDelegate.shared.appDependency.websocket.setUrl(urlString: "wss://\(scAddr)/ws", token: currentArea.sa_user_token)
                AppDelegate.shared.appDependency.websocket.connect()
            }
            
            else if addr.contains("https://"),
                    let scAddr = addr.components(separatedBy: "https://").last {
                AppDelegate.shared.appDependency.websocket.setUrl(urlString: "wss://\(scAddr)/ws", token: currentArea.sa_user_token)
                AppDelegate.shared.appDependency.websocket.connect()
            }
            
            
        } else {
            if let addr = currentArea.sa_lan_address,
               addr.contains("http://"),
               let saAddr = addr.components(separatedBy: "http://").last {
                AppDelegate.shared.appDependency.websocket.setUrl(urlString: "ws://\(saAddr)/ws", token: currentArea.sa_user_token)
                AppDelegate.shared.appDependency.websocket.connect()
            }
            
            else if let addr = currentArea.sa_lan_address,
                    addr.contains("https://"),
                    let saAddr = addr.components(separatedBy: "https://").last {
                AppDelegate.shared.appDependency.websocket.setUrl(urlString: "wss://\(saAddr)/ws", token: currentArea.sa_user_token)
                AppDelegate.shared.appDependency.websocket.connect()
            }
        }
                 
        if let addr = currentArea.sa_lan_address, currentArea.macAddr == nil {
            checkIfSAAvailable(addr: addr, sa_user_token: currentArea.sa_user_token) { [weak self] available in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if available {
                        self.currentArea.macAddr = self.networkStateManager.getWifiBSSID()
                        self.currentArea.ssid = self.networkStateManager.getWifiSSID()
                        AreaCache.cacheArea(areaCache: self.currentArea.toAreaCache())
                    }
                    
                    self.currentAreaPublisher.send(self.currentArea)
                    /// 获取用户权限
                    self.getRolePermissions()
                }
                
            }
        } else {
            currentAreaPublisher.send(currentArea)
            /// 获取用户权限
            getRolePermissions()
        }
    }

    /// log out the account
    func logOut(callback: (() -> ())) {
        ApiServiceManager.shared.logout(successCallback: nil, failureCallback: nil)
        isLogin = false
        updateCurrentArea()
        callback()
    }
    
    func lostLoginState() {
        isLogin = false
        updateCurrentArea()
    }
    
    /// Login
    /// - Parameters:
    ///   - phone: phone
    ///   - pwd: password
    ///   - success: success callback
    ///   - failure: failure callback
    func logIn(phone: String, pwd: String, success: ((User) -> Void)?, failure: ((String) -> Void)?) {
        ApiServiceManager.shared.login(phone: phone, password: pwd) { [weak self] (response) in
            guard let self = self else { return }
            let user = response.user_info
            self.isLogin = true
            self.currentUser.icon_url = user.icon_url
            self.currentUser.phone = user.phone
            self.currentUser.user_id = user.user_id
            if user.nickname != "" {
                self.currentUser.nickname = user.nickname
            }
            
            UserCache.update(from: user)
            
            let needCleanArea = AreaCache.areaList().filter({ $0.cloud_user_id != user.user_id })

            needCleanArea.forEach {
                if $0.cloud_user_id > 0 {
                    AreaCache.deleteArea(id: $0.id, sa_token: $0.sa_user_token)
                }
                
            }
            
            /// 登录成功后获取家庭列表
            ApiServiceManager.shared.areaList { [weak self] response in
                guard let self = self else { return }
                response.areas.forEach { $0.cloud_user_id = self.currentUser.user_id }
                AreaCache.cacheAreas(areas: response.areas, needRemove: false)
                
                /// 如果该账户云端没有家庭则自动创建一个
                if AreaCache.areaList().count == 0 {
                    self.currentArea = AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)", cloud_user_id: user.user_id).transferToArea()
                    
                }

                /// 同步本地家庭到云
                self.syncLocalAreasToCloud {
                    success?(user)
                }

            } failureCallback: { code, err in
                failure?(err)
            }
            
        } failureCallback: { (code, err) in
            failure?(err)
        }

    }
    
    func updateCurrentNickname() {
        ApiServiceManager.shared.editUser(user_id: currentArea.sa_user_id, nickname: currentUser.nickname, account_name: "", password: "", successCallback: nil, failureCallback: nil)
    }

    func getRolePermissions() {
        if !isSAEnviroment && !isLogin {
            self.currentRolePermissions = RolePermission()
            return
        }
        
        ApiServiceManager.shared.rolesPermissions(area: currentArea, user_id: currentArea.sa_user_id) { [weak self] response in
            guard let self = self else { return }

            self.currentRolePermissions = response.permissions
            
            
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }

            self.currentRolePermissions = RolePermission()
            
        }


    }
    
    /// 检查是否登录
    /// 如果未登录则弹出登录页面
    /// - Parameter loginComplete: 登录结果回调
    /// - Returns: nil
    static func checkLoginWhenComplete(loginComplete: @escaping () -> (), jumpAfterLogin: Bool = false) {
        if AppDelegate.shared.appDependency.authManager.isLogin {
            loginComplete()
            return
        }
        
        let vc = LoginViewController()
        if jumpAfterLogin {
            vc.loginComplete = loginComplete
        }
        vc.hidesBottomBarWhenPushed = true
        let nav = BaseNavigationViewController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        AppDelegate.shared.appDependency.tabbarController.present(nav, animated: true, completion: nil)
        
    }
    
    
    /// 检测请求地址是否在对应的SA环境
    /// - Parameters:
    ///   - addr: 地址
    ///   - resultCallback: 结果回调
    func checkIfSAAvailable(addr: String, sa_user_token: String, resultCallback: ((_ available: Bool) -> Void)?) {
        if let url = URL(string: "\(addr)/api/check") {
            var request = URLRequest(url: url)
            request.timeoutInterval = 0.5
            request.httpMethod = "POST"
            request.headers["smart-assistant-token"] = sa_user_token
            
            URLSession(configuration: .default)
                .dataTask(with: request) { (data, response, error) -> Void in
                    guard error == nil else {
                        resultCallback?(false)
                        return
                    }
                    
                    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                        resultCallback?(false)
                        return
                    }
                    
                    guard
                        let data = data,
                        let response = ApiServiceResponseModel<SAAccessResponse>.deserialize(from: String(data: data, encoding: .utf8)),
                        response.data.access_allow == true
                    else {
                        resultCallback?(false)
                        return
                    }
                    
                    resultCallback?(true)
                }
                .resume()
        } else {
            resultCallback?(false)
        }
    }
    
}

extension AuthManager {
    /// 登录后 将本地的家庭信息同步到云端，并绑定当前SA的家庭
    func syncLocalAreasToCloud(finish: (() -> ())?) {
        let areas = AreaCache.areaList().filter { $0.id == 0 }
        var finishTask = 0
        if areas.count == 0 {
            bindSAAreaToCloud(finish: finish)
        }

        areas.forEach { area in
            let locations = LocationCache.areaLocationList(area_id: area.id, sa_token: area.sa_user_token).map(\.name)
            
            syncAreaOperationQueue.addOperation { [weak self] in
                guard let self = self else { return }
                self.operationSemaphore.wait()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    ApiServiceManager.shared.createArea(name: area.name, locations_name: locations) { [weak self] response in
                        guard let self = self else { return }
                        area.id = response.id
                        AreaCache.cacheArea(areaCache: area.toAreaCache())
                        finishTask += 1
                        print("test: \(area.name)")
                        if finishTask == areas.count {
                            self.bindSAAreaToCloud(finish: finish)
                        }
                        
                        self.operationSemaphore.signal()
                    } failureCallback: { [weak self] code, err in
                        finishTask += 1
                        if finishTask == areas.count {
                            self?.bindSAAreaToCloud(finish: finish)
                        }
                        print("test: \(area.name)")
                        self?.operationSemaphore.signal()
                    }


                }

            }
        }
    }
    
    /// 本地的家庭信息同步到云端完成
    /// 将当前SA环境的家庭绑定到云端
    func bindSAAreaToCloud(finish: (() -> ())?) {
        let wifiMAC = networkStateManager.getWifiBSSID()
        
        guard
            let area = AreaCache.areaList()
                .filter({ $0.ssid != nil
                            && $0.macAddr != nil
                            && $0.macAddr == wifiMAC
                            && $0.is_bind_sa == true })
                .first
        else {
            if let area = AreaCache.areaList().last {
                currentArea = area
            }
            finish?()
            return
            
        }

        ApiServiceManager.shared.bindCloud(area: area, cloud_user_id: currentUser.user_id) { [weak self] response in
            guard let self = self else { return }
            print("绑定成功")
            if let area = AreaCache.areaList().first(where: { $0.macAddr == self.networkStateManager.getWifiBSSID() && $0.macAddr != nil }) {
                area.cloud_user_id = self.currentUser.user_id
                self.currentArea = area
                AreaCache.cacheArea(areaCache: area.toAreaCache())
            }
            finish?()
        } failureCallback: { [weak self] code, err in
            print("绑定失败")
            if let area = AreaCache.areaList().first {
                self?.currentArea = area
            }
            finish?()
        }

    }
    
    

}



extension AuthManager {

    private class SAAccessResponse: BaseModel {
        /// 是否允许访问(判断用户token是否在该SA中有效)
        var access_allow = false
    }
}
