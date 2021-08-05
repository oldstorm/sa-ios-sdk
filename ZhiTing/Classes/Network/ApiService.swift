//
//  ApiService.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/4.
//

import Moya
import Foundation


enum CaptchaType: String {
    case register
}

/// 接口枚举
enum ApiService {
    // login & register
    case register(country_code: String = "86", phone: String, password: String, captcha: String, captcha_id: String)
    case login(phone: String, password: String)
    case logout
    case captcha(type: CaptchaType, target: String, country_code: String = "86")
    case editUser(area: Area = AppDelegate.shared.appDependency.authManager.currentArea, user_id: Int, nickname: String = "", account_name: String, password: String)
    case bindCloud(area: Area, cloud_user_id: Int)
    /// 云端账号信息
    case cloudUserDetail(id: Int)
    /// 编辑云端账号信息
    case editCloudUser(user_id: Int, nickname: String = "")

    //sa
    case syncArea(syncModel: SyncSAModel)
    case checkSABindState(url: String)

    // device
    case deviceList(type: Int = 0, area: Area)
    case addDiscoverDevice(device: DiscoverDeviceModel, area: Area)
    case addSADevice(url: String, device: DiscoverDeviceModel)
    case deviceDetail(area: Area, device_id: Int)
    case editDevice(area: Area, device_id: Int, name: String = "", location_id: Int = -1)
    case deleteDevice(area: Area, device_id: Int)
    
    // scene
    
    case sceneList(type: Int = 0, area: Area = AppDelegate.shared.appDependency.authManager.currentArea)
    case createScene(scene: SceneDetailModel, area: Area = AppDelegate.shared.appDependency.authManager.currentArea)
    case sceneDetail(id: Int, area: Area = AppDelegate.shared.appDependency.authManager.currentArea)
    case editScene(id: Int, scene: SceneDetailModel, area: Area = AppDelegate.shared.appDependency.authManager.currentArea)
    case deleteScene(id: Int, area: Area = AppDelegate.shared.appDependency.authManager.currentArea)
    case sceneExecute(scene_id: Int, is_execute: Bool, area: Area = AppDelegate.shared.appDependency.authManager.currentArea)
    case sceneLogs(start: Int = 0, size: Int = 20, area: Area = AppDelegate.shared.appDependency.authManager.currentArea)

    
    // brand
    case brands(name: String, area: Area = AppDelegate.shared.appDependency.authManager.currentArea)
    case brandDetail(name: String, area: Area = AppDelegate.shared.appDependency.authManager.currentArea)
    
    // plugin
    case pluginDetail(plugin_id: String, area: Area = AppDelegate.shared.appDependency.authManager.currentArea)
    
    // area
    case defaultLocationList
    case areaList
    case createArea(name: String, locations_name: [String])
    case areaDetail(area: Area)
    case changeAreaName(area: Area, name: String)
    case deleteArea(area: Area)
    case quitArea(area: Area)
    case getInviteQRCode(area: Area, role_ids: [Int])
    case scanQRCode(qr_code: String, url: String, nickname: String, token: String?, area_id: Int = 0)
    
    // members
    case memberList(area: Area)
    case userDetail(area: Area, id: Int)
    case deleteMember(area: Area, id: Int)
    case editMember(area: Area, id: Int, role_ids: [Int])
    
    // roles
    case rolesList(area: Area)
    case rolesPermissions(area: Area, user_id: Int)
    
    // location
    case areaLocationsList(area: Area)
    case locationDetail(area: Area, id: Int)
    case addLocation(area: Area, name: String)
    case changeLocationName(area: Area, id: Int, name: String)
    case deleteLocation(area: Area, id: Int)
    case setLocationOrders(area: Area, location_order: [Int])
    
    // diskAuth
    case scopeList(area: Area)
    case scopeToken(area: Area, scopes: [String])
    
    //转移拥有者
    case transferOwner(area: Area,id: Int)
    
}

/// if print the debug info
fileprivate let printDebugInfo = true


var cloudUrl = "https://sc.zhitingtech.com"




extension ApiService: TargetType {
    
    
    var sampleData: Data {
        return Data()
    }
}


private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}

extension Data {
    func map<T: HandyJSON>(_ type: T.Type) -> T? {
        let jsonString = String(data: self, encoding: .utf8)
        let model = T.deserialize(from: jsonString)
        return model
    }
}

extension MoyaProvider {

    
    @discardableResult
    func requestModel<T: BaseModel>(_ target: Target, modelType: T.Type, successCallback: ((_ response: T) -> Void)?, failureCallback: ((_ code: Int, _ errorMessage: String) -> Void)? = nil) -> Moya.Cancellable? {
        return request(target) { (result) in
            switch result {
            case .success(let response):
                if printDebugInfo {
                    print("-----------------------------< ApiService >--------------------------------")
                    print(Date())
                    print("---------------------------------------------------------------------------")
                    print("header: \(target.headers ?? [:])")
                    print("---------------------------------------------------------------------------")
                    print("method: \(target.method.rawValue)")
                    print("---------------------------------------------------------------------------")
                    print("baseUrl: \(target.baseURL)")
                    print("---------------------------------------------------------------------------")
                    print("target: \(target.path)")
                    print("---------------------------------------------------------------------------")
                    print("parameters: \(target.task)")
                    
                }
                
                guard response.statusCode == 200, let model = response.data.map(ApiServiceResponseModel<T>.self) else {
                    failureCallback?(response.statusCode, "error: \(String(data: response.data, encoding: .utf8) ?? "unknown") code: \(response.statusCode)")
                    print("---------------------------------------------------------------------------")
                    print("error: \(String(data: response.data, encoding: .utf8) ?? "unknown")")
                    print("---------------------------------------------------------------------------\n\n")
                    return
                }
                
                if printDebugInfo {
                    print("---------------------------------------------------------------------------")
                    print(model.toJSONString(prettyPrint: true) ?? "")
                    print("---------------------------------------------------------------------------\n\n")
                }

                if model.status == 0 {
                    successCallback?(model.data)
                } else {
                    failureCallback?(model.status, model.reason)
                    if model.status == 2008 || model.status == 2009 { ///　云端登录状态丢失
                        DispatchQueue.main.async {
                            SceneDelegate.shared.window?.makeToast("登录状态丢失".localizedString)
                            AppDelegate.shared.appDependency.authManager.lostLoginState()
                        }
                        
                    }

                }
                
            case .failure(let error):
                let moyaError = error as MoyaError
                let statusCode = moyaError.response?.statusCode ?? -1
                let errorMessage = "error"
                
                if printDebugInfo {
                    print("-----------------------------< ApiService >--------------------------------")
                    print(Date())
                    print("---------------------------------------------------------------------------")
                    print("header: \(target.headers ?? [:])")
                    print("---------------------------------------------------------------------------")
                    print("method: \(target.method.rawValue)")
                    print("---------------------------------------------------------------------------")
                    print("baseUrl: \(target.baseURL)")
                    print("---------------------------------------------------------------------------")
                    print("target: \(target.path)")
                    print("---------------------------------------------------------------------------")
                    print("parameters: \(target.task)")
                    print("---------------------------------------------------------------------------")
                    print("Error: \(error.localizedDescription) ErrorCode: \(statusCode)")
                    print("---------------------------------------------------------------------------\n\n")
                }
               
                failureCallback?(statusCode, errorMessage)
                return
            }

        }
    }
    
}

extension MoyaProvider {
    @discardableResult
    func requestListModel<T: BaseModel>(_ target: Target, modelType: T.Type, successCallback: ((_ response: [T]) -> Void)?, failureCallback: ((_ code: Int, _ errorMessage: String) -> Void)? = nil) -> Moya.Cancellable? {
        return request(target) { (result) in
            switch result {
            case .success(let response):
                if printDebugInfo {
                    print("-----------------------------< ApiService >--------------------------------")
                    print(Date())
                    print("---------------------------------------------------------------------------")
                    print("header: \(target.headers ?? [:])")
                    print("---------------------------------------------------------------------------")
                    print("method: \(target.method.rawValue)")
                    print("---------------------------------------------------------------------------")
                    print("baseUrl: \(target.baseURL)")
                    print("---------------------------------------------------------------------------")
                    print("target: \(target.path)")
                    print("---------------------------------------------------------------------------")
                    print("parameters: \(target.task)")
                    
                }
                
                guard let model = response.data.map(ApiServiceResponseListModel<T>.self) else {
                    failureCallback?(response.statusCode, String(data: response.data, encoding: .utf8) ?? "error")
                    return
                }
                
                if printDebugInfo {
                    print("---------------------------------------------------------------------------")
                    print(model.toJSONString(prettyPrint: true) ?? "")
                    print("---------------------------------------------------------------------------\n\n")
                }

                if model.status == 0 {
                    successCallback?(model.data)
                } else {
                    failureCallback?(model.status, model.reason)
                }
                
            case .failure(let error):
                if printDebugInfo {
                    print("-----------------------------< ApiService >--------------------------------")
                    print(Date())
                    print("---------------------------------------------------------------------------")
                    print("header: \(target.headers ?? [:])")
                    print("---------------------------------------------------------------------------")
                    print("method: \(target.method.rawValue)")
                    print("---------------------------------------------------------------------------")
                    print("baseUrl: \(target.baseURL)")
                    print("---------------------------------------------------------------------------")
                    print("target: \(target.path)")
                    print("---------------------------------------------------------------------------")
                    print("parameters: \(target.task)")
                    print("---------------------------------------------------------------------------")
                    print("Error: \(error)")
                    print("---------------------------------------------------------------------------\n\n")
                }
                let moyaError = error as MoyaError
                let statusCode = moyaError.response?.statusCode ?? -1
                let errorMessage = "error"
                failureCallback?(statusCode, errorMessage)
                return
            }

        }
    }
}

class ApiServiceResponseModel<T: BaseModel>: BaseModel {
    var status = 0
    var reason = ""
    var data = T()
}


class ApiServiceResponseListModel<T: BaseModel>: BaseModel {
    var status = 0
    var reason = ""
    var data = [T]()
}
