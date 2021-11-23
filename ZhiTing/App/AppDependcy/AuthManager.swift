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
        return NetworkStateManager.shared
    }
    
    static let shared = AuthManager()
    
    private init() {}
    
    /// 同步家庭队列
    lazy var syncAreaOperationQueue = DispatchQueue(label: "zhiting.syncAreaQueue")
    /// 同步家庭队列锁
    lazy var operationSemaphore = DispatchSemaphore(value: 1)
    /// 同步家庭队列锁
    lazy var operationFuncSemaphore = DispatchSemaphore(value: 1)
    
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
        guard
            let macAddress = networkStateManager.getWifiBSSID(),
            let areaMacAddress = currentArea.bssid
        else {
            return false
        }
        
        if macAddress == areaMacAddress { //判断wifi mac地址相同
            return true
        }
        
        return false
    }
    
    /// 是否登录云端账号
    @UserDefaultBool(key: .isLogin) var isLogin
    
    /// 当前账号
    var currentUser = User()
    
    /// 当前家庭切换后更新状态
    func updateCurrentArea() {
        if currentArea.id != nil {
            updateCurrentNickname()
        }
        
        
        
        AppDelegate.shared.appDependency.websocket.disconnect()
        
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            /// 如果没有wifi bssid 先ping一下检查当前是否SA环境
            if let addr = self.currentArea.sa_lan_address,
               self.currentArea.is_bind_sa == true,
               self.currentArea.bssid == nil {
                self.checkIfSAAvailable(addr: addr) { [weak self] available in
                    guard let self = self else { return }
                    if available {
                        self.currentArea.bssid = self.networkStateManager.getWifiBSSID()
                        self.currentArea.ssid = self.networkStateManager.getWifiSSID()
                        AreaCache.cacheArea(areaCache: self.currentArea.toAreaCache())
                    } else { // sa地址发生变化
                        UDPDeviceTool.updateAreaSAAddress()
                    }
                    self.updateWebsocket()
                    self.currentAreaPublisher.send(self.currentArea)
                    /// 获取用户权限
                    self.getRolePermissions()
                }
            } else {
                if (self.currentArea.sa_lan_address == "" || self.currentArea.sa_lan_address == nil) && self.currentArea.is_bind_sa { // 找回sa地址
                    UDPDeviceTool.updateAreaSAAddress()
                }

                self.updateWebsocket()
                self.currentAreaPublisher.send(self.currentArea)
                /// 获取用户权限
                self.getRolePermissions()
            }
            
        }
        
        
    }
    
    /// 切换家庭后根据环境更新websocket状态
    func updateWebsocket() {
        if isLogin && !isSAEnviroment {
            /// 请求临时通道
            ApiServiceManager.shared.requestTemporaryIP(area: currentArea, complete: { [weak self] addr in
                guard let self = self else { return }
                
                AppDelegate.shared.appDependency.websocket.setUrl(urlString: "wss://\(addr)/ws", token: self.currentArea.sa_user_token)
                AppDelegate.shared.appDependency.websocket.connect()
                
                
                
                
            }, failureCallback: nil)
            
            
            
            
        } else if isSAEnviroment && currentArea.is_bind_sa {
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
        } else {
            AppDelegate.shared.appDependency.websocket.disconnect()
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
            /// 同步前,当前家庭用户昵称
            let oldName = self.currentUser.nickname

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
                
                /// 如果该账户云端没有家庭,将用户名字更新为当前家庭名字
                if response.areas.count == 0 {
                    ApiServiceManager.shared.editCloudUser(user_id: user.user_id, nickname: oldName, successCallback: { [weak self] _ in
                        guard let self = self else { return }
                        self.currentUser.nickname = oldName
                        user.nickname = oldName
                        UserCache.update(from: user)

                    }, failureCallback: nil)
                }
                
                /// 同步本地家庭到云
                self.syncLocalAreasToCloud(needUpdateCurrentArea: true) {
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
    static func checkLoginWhenComplete(loginComplete: (() -> ())?, jumpAfterLogin: Bool = false) {
        if AuthManager.shared.isLogin {
            loginComplete?()
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
    func checkIfSAAvailable(addr: String, resultCallback: ((_ available: Bool) -> Void)?) {
        if let url = URL(string: "\(addr)/api/check") {
            var request = URLRequest(url: url)
            request.timeoutInterval = 0.5
            request.httpMethod = "POST"
            
            URLSession(configuration: .default)
                .dataTask(with: request) { (data, response, error) -> Void in
                    guard error == nil else {
                        DispatchQueue.main.async {
                            resultCallback?(false)
                        }
                        return
                    }
                    
                    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                        DispatchQueue.main.async {
                            resultCallback?(false)
                        }
                        
                        return
                    }
                    
                    
                    DispatchQueue.main.async {
                        resultCallback?(true)
                    }
                }
                .resume()
        } else {
            DispatchQueue.main.async {
                resultCallback?(false)
            }
        }
    }
    
}

// MARK: - 同步家庭到云端相关
extension AuthManager {
    /// 登录后 将本地的家庭信息同步到云端，并绑定当前SA的家庭
    func syncLocalAreasToCloud(needUpdateCurrentArea: Bool = false, finish: (() -> ())?) {
        /// 未同步到云端的家庭
        operationFuncSemaphore.wait()
        syncAreaOperationQueue.async { [weak self] in
            guard let self = self else { return }
            
            let areas = AreaCache.areaList().filter { $0.id == nil || $0.cloud_user_id == -1 || $0.needRebindCloud }
            var finishTask = 0
            if areas.count == 0 {
                DispatchQueue.main.async {
                    if let area = AreaCache.areaList().last {
                        if needUpdateCurrentArea {
                            AuthManager.shared.currentArea = area
                        }
                        
                    }
                    self.operationFuncSemaphore.signal()
                    finish?()
                }
                
                return
            }
            
            var accessToken = ""

            self.operationSemaphore.wait()
            ApiServiceManager.shared.getDeviceAccessToken { [weak self] response in
                guard let self = self else { return }
                accessToken = response.access_token
                self.operationSemaphore.signal()
                
            } failureCallback: { [weak self] code, err in
                guard let self = self else { return }
                self.operationSemaphore.signal()
            }

            
            
            areas.forEach { area in
                let locations = LocationCache.areaLocationList(area_id: area.id, sa_token: area.sa_user_token).map(\.name)
                self.operationSemaphore.wait()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    /// 云端创建对应本地的无SA家庭
                    if area.id == nil {
                        ApiServiceManager.shared.createArea(name: area.name, locations_name: locations) { [weak self] response in
                            guard let self = self else { return }
                            /// 如果同步的家庭是本地未绑定SA的家庭  清除本地同一个家庭数据 直接取云端家庭（家庭id为云端家庭id)
                            AreaCache.deleteArea(id: area.id, sa_token: area.sa_user_token)
                            
                            area.id = response.id
                            area.cloud_user_id = AuthManager.shared.currentUser.user_id
                            area.sa_user_id = response.cloud_sa_user_info?.id ?? 0
                            area.sa_user_token = response.cloud_sa_user_info?.token ?? ""
                            AreaCache.cacheArea(areaCache: area.toAreaCache())
                            
                            finishTask += 1
                            if finishTask == areas.count { ///所有同步任务已完成时
                                if let area = AreaCache.areaList().last {
                                    if needUpdateCurrentArea {
                                        AuthManager.shared.currentArea = area
                                    }
                                }
                                self.operationFuncSemaphore.signal()
                                finish?()
                            }
                            self.operationSemaphore.signal()
                            
                            
                        } failureCallback: { [weak self] code, err in
                            finishTask += 1
                            /// 同步到云端失败的家庭直接移除
                            AreaCache.deleteArea(id: area.id, sa_token: area.sa_user_token)
                            
                            if finishTask == areas.count { ///所有同步任务已完成时
                                if let area = AreaCache.areaList().last {
                                    if needUpdateCurrentArea {
                                        AuthManager.shared.currentArea = area
                                    }
                                }
                                self?.operationFuncSemaphore.signal()
                                finish?()
                            }
                            self?.operationSemaphore.signal()
                        }
                        
                        
                    } else {
                        if accessToken == "" {
                            finishTask += 1
                            if finishTask == areas.count { ///所有同步任务已完成时
                                if let area = AreaCache.areaList().last {
                                    if needUpdateCurrentArea {
                                        AuthManager.shared.currentArea = area
                                    }
                                }
                                self.operationFuncSemaphore.signal()
                                finish?()
                            }
                            self.operationSemaphore.signal()
                            return
                        }
                        
                        self.bindSAToCloud(area: area, access_token: accessToken) { [weak self] success in
                            guard let self = self else { return }
                            if success { /// 如果绑定成功
                                finishTask += 1
                                if finishTask == areas.count { ///所有同步任务已完成时
                                    if let area = AreaCache.areaList().last {
                                        if needUpdateCurrentArea {
                                            AuthManager.shared.currentArea = area
                                        }
                                    }
                                    self.operationFuncSemaphore.signal()
                                    finish?()
                                }
                                
                                self.operationSemaphore.signal()
                                
                            } else {
                                /// 绑定SA到云失败
                                finishTask += 1
                                if finishTask == areas.count { ///所有同步任务已完成时
                                    if let area = AreaCache.areaList().last {
                                        if needUpdateCurrentArea {
                                            AuthManager.shared.currentArea = area
                                        }
                                    }
                                    self.operationFuncSemaphore.signal()
                                    finish?()
                                }
                                
                                self.operationSemaphore.signal()
                            }
                        }
  
                    }
                    
                    
                }
                
            }
        }
    }
    
    
    /// 将家庭SA绑定到云端
    /// - Parameters:
    ///   - area: 本地SA家庭
    ///   - cloud_area_id: 云端家庭id
    ///   - result: 绑定结果回调
    func bindSAToCloud(area: Area, access_token: String, result: ((_ isSuccess: Bool) -> Void)?) {
        /// 若家庭没绑定SA 直接返回
        guard area.is_bind_sa else {
            result?(false)
            return
        }
        checkIfSAAvailable(addr: area.sa_lan_address ?? "") { available in
            if available { /// 在SA环境
                ApiServiceManager.shared.bindCloud(area: area, cloud_user_id: AuthManager.shared.currentUser.user_id, url: area.sa_lan_address ?? "", access_token: access_token) { response in
                    area.cloud_user_id = AuthManager.shared.currentUser.user_id
                    area.ssid = NetworkStateManager.shared.getWifiSSID()
                    area.bssid = NetworkStateManager.shared.getWifiBSSID()
                    area.needRebindCloud = false
                    /// 清除一下原本地家庭数据
                    AreaCache.deleteArea(id: area.id, sa_token: area.sa_user_token)
                    
                    /// （家庭id为SA家庭id)
                    AreaCache.cacheArea(areaCache: area.toAreaCache())
                    result?(true)
                } failureCallback: { code, err in
                    area.cloud_user_id = AuthManager.shared.currentUser.user_id
                    area.needRebindCloud = true
                    AreaCache.cacheArea(areaCache: area.toAreaCache())
                    result?(false)
                }
                
                
            } else { /// 不在SA环境
                if self.isLogin { /// 通过sa_id拿临时通道去绑定
                    ApiServiceManager.shared.requestTemporaryIP(sa_id: area.sa_id ?? "") { url in
                        ApiServiceManager.shared.bindCloud(area: area, cloud_user_id: AuthManager.shared.currentUser.user_id, url: url, access_token: access_token) { response in
                            area.cloud_user_id = AuthManager.shared.currentUser.user_id
                            area.needRebindCloud = false
                            /// 清除一下原本地家庭数据
                            AreaCache.deleteArea(id: area.id, sa_token: area.sa_user_token)
                            /// （家庭id为SA家庭id)
                            AreaCache.cacheArea(areaCache: area.toAreaCache())
                            result?(true)
                        } failureCallback: { code, err in
                            /// 绑定SA到云失败
                            area.cloud_user_id = AuthManager.shared.currentUser.user_id
                            area.needRebindCloud = true
                            AreaCache.cacheArea(areaCache: area.toAreaCache())
                            result?(false)
                        }
                    } failure: { code, err in
                        area.cloud_user_id = AuthManager.shared.currentUser.user_id
                        area.needRebindCloud = true
                        AreaCache.cacheArea(areaCache: area.toAreaCache())
                        result?(false)
                    }


                } else {
                    area.cloud_user_id = AuthManager.shared.currentUser.user_id
                    area.needRebindCloud = true
                    AreaCache.cacheArea(areaCache: area.toAreaCache())
                    result?(false)
                }
                
            }
        }
    }
    
    
    
    
    
}



extension AuthManager {
    
    private class SAAccessResponse: BaseModel {
        /// 是否允许访问(判断用户token是否在该SA中有效)
        var access_allow = false
    }
}
