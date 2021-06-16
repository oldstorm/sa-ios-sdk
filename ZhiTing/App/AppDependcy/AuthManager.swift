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
    
    var networkStateManager: StateManager {
        return AppDelegate.shared.appDependency.networkManager
    }
    
    var currentArea: Area {
        return AppDelegate.shared.appDependency.currentAreaManager.currentArea
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
    

    var currentSA = SmartAssistant() {
        didSet {
            getRolePermissions()
            apiService.requestModel(.editUser(user_id: currentSA.user_id, nickname: currentSA.nickname, account_name: "", password: ""), modelType: BaseModel.self, successCallback: nil)
            AppDelegate.shared.appDependency.websocket.setUrl(urlString: "ws://\(currentSA.ip_address)/ws", token: currentSA.token)
            if currentSA.ip_address != "" {
                AppDelegate.shared.appDependency.websocket.connect()
            }
            
        }
    }
    
    /// 是否在SA环境下
    var isSAEnviroment: Bool {

        #if targetEnvironment(simulator)
            return true
        #else
        if let wifiSSID = networkStateManager.currentWifiSSID {
            /// 暂时写死 wifiSSid == "YCTC2409-5G"
            if currentArea.sa_token == currentSA.token && ztWebSocket.status == .connected {
                return true
            }
            
            return false
        } else {
            return false
        }
        #endif
    }

    var currentUser = User()
    
    /// log out the account
    func logOut() {
        apiService.requestModel(.logout, modelType: BaseModel.self, successCallback: nil)
        currentUser = User()
        SceneDelegate.shared.window?.rootViewController = BaseNavigationViewController(rootViewController: LoginViewController())
        AppDelegate.shared.appDependency.tabbarController = TabbarController()
    }
    
    /// Login
    /// - Parameters:
    ///   - phone: phone
    ///   - pwd: password
    ///   - success: success callback
    ///   - failure: failure callback
    func logIn(phone: String, pwd: String, success: ((User) -> Void)?, failure: ((String) -> Void)?) {
        apiService.requestModel(.login(phone: phone, password: pwd), modelType: ResponseModel.self) { [weak self] (response) in
            self?.currentUser = response.user_info
            success?(response.user_info)
        } failureCallback: { (code, err) in
            failure?(err)
        }
    }
    
    func getRolePermissions() {
        apiService.requestModel(.rolesPermissions(user_id: currentSA.user_id), modelType: RolePermissionsResponse.self) { [weak self] response in
            guard let self = self else { return }

            self.currentRolePermissions = response.permissions
            
            
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }

            self.currentRolePermissions = RolePermission()
            
        }

    }
    
}


extension AuthManager {
    private class ResponseModel: BaseModel {
        var user_info = User()
    }
    
    private class RolePermissionsResponse: BaseModel {
        var permissions = RolePermission()
    }
}
