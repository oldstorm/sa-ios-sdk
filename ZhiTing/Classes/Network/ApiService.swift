//
//  ApiService.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/4.
//

import Moya
import Foundation
import Alamofire

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
    case editUser(area: Area = AuthManager.shared.currentArea, user_id: Int, nickname: String = "", account_name: String, password: String)
    case bindCloud(area: Area, cloud_user_id: Int, url: String, sa_id: String? = nil, access_token: String)
    /// 云端账号信息
    case cloudUserDetail(id: Int)
    /// 编辑云端账号信息
    case editCloudUser(user_id: Int, nickname: String = "")
    
    //sa
    case syncArea(syncModel: SyncSAModel, url: String, token: String)
    case checkSABindState(url: String)
    /// 获取家庭迁移地址
    case migrationAddr(area: Area)
    /// 迁移云端家庭到本地
    case migrationCloudToLocal(area: Area, migration_url: String, backup_file: String, sum: String)
    
    
    // device
    case deviceList(type: Int = 0, area: Area)
    case addDiscoverDevice(device: DiscoverDeviceModel, area: Area)
    case addSADevice(url: String, device: DiscoverDeviceModel)
    case deviceDetail(area: Area, device_id: Int)
    case editDevice(area: Area, device_id: Int, name: String = "", location_id: Int = -1)
    case deleteDevice(area: Area, device_id: Int)
    
    case getDeviceAccessToken
    
    // scene
    
    case sceneList(type: Int = 0, area: Area = AuthManager.shared.currentArea)
    case createScene(scene: SceneDetailModel, area: Area = AuthManager.shared.currentArea)
    case sceneDetail(id: Int, area: Area = AuthManager.shared.currentArea)
    case editScene(id: Int, scene: SceneDetailModel, area: Area = AuthManager.shared.currentArea)
    case deleteScene(id: Int, area: Area = AuthManager.shared.currentArea)
    case sceneExecute(scene_id: Int, is_execute: Bool, area: Area = AuthManager.shared.currentArea)
    case sceneLogs(start: Int = 0, size: Int = 20, area: Area = AuthManager.shared.currentArea)
    
    
    // brand
    case brands(name: String, area: Area = AuthManager.shared.currentArea)
    case brandDetail(name: String, area: Area = AuthManager.shared.currentArea)
    
    // plugin
    case plugins(area: Area = AuthManager.shared.currentArea, list_type: Int)
    case pluginDetail(plugin_id: String, area: Area = AuthManager.shared.currentArea)
    case installPlugin(area: Area = AuthManager.shared.currentArea, name: String, plugins: [String])
    case deletePlugin(area: Area = AuthManager.shared.currentArea, name: String, plugins: [String])
    case deletePluginById(area: Area = AuthManager.shared.currentArea, id: String)
    case downloadPlugin(area: Area = AuthManager.shared.currentArea, url: String, destination: DownloadRequest.Destination)
    
    // area
    case defaultLocationList
    case areaList
    case createArea(name: String, locations_name: [String])
    case areaDetail(area: Area)
    case changeAreaName(area: Area, name: String)
    case deleteArea(area: Area, is_del_cloud_disk: Bool)
    case quitArea(area: Area)
    case getInviteQRCode(area: Area, role_ids: [Int])
    case scanQRCode(qr_code: String, url: String, nickname: String, token: String?)
    
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
    
    //获取数据通道
    case temporaryIP(area: Area, scheme: String = "http")
    
    //获取数据通道
    case temporaryIPBySAID(sa_id: String, scheme: String = "http")
    
    //SC获取SAtoken
    case getSAToken(area: Area)
    
    //发现设备 - 设备列表
    case commonDeviceList(area: Area)
    //插件包 —— 检测更新
    case checkPluginUpdate(id: String, area: Area)
    //获取验证码
    case getCaptcha(area: Area)
    //设置找回凭证权限
    case settingTokenAuth(area: Area, tokenModel: TokenAuthSettingModel)
    //检测软件版本更新
    case checkSoftwareUpdate(area: Area)
    //软件升级
    case updateSoftware(area: Area, version: String)
}

/// if print the debug info
fileprivate let printDebugInfo = true


var cloudUrl = "https://scgz.zhitingtech.com"

//var cloudUrl = "http://192.168.22.110:9097"



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
                    failureCallback?(response.statusCode, "error: \(String(data: response.data, encoding: .utf8) ?? "unknown") ")
                    print("---------------------------------------------------------------------------")
                    print("error: \(String(data: response.data, encoding: .utf8) ?? "unknown") errorCode:\(response.statusCode)")
                    print("---------------------------------------------------------------------------\n\n")
                    return
                }
                
                if printDebugInfo {
                    print("---------------------------------------------------------------------------")
                    print(String(data: response.data, encoding: .utf8) ?? "")
                    print("---------------------------------------------------------------------------\n\n")
                }
                
                if model.status == 0 {
                    successCallback?(model.data)
                } else {
                    failureCallback?(model.status, model.reason)
                    if model.status == 2008 || model.status == 2009 { ///　云端登录状态丢失
                        DispatchQueue.main.async {
                            SceneDelegate.shared.window?.makeToast("登录状态丢失".localizedString)
                            AuthManager.shared.lostLoginState()
                        }
                        
                    }
                    
                }
                
            case .failure(let error):
                var statusCode = -1
                let moyaError = error as MoyaError
                let errorMessage = "error"
                
                if let afError = moyaError.errorUserInfo["NSUnderlyingError"] as? Alamofire.AFError,
                   let underlyingError = afError.underlyingError {
                    statusCode = (underlyingError as NSError).code
                    
                    
                    /// 可能是SA地址发生了改变 尝试搜索发现SA
                    if statusCode == NSURLErrorNotConnectedToInternet || statusCode == NSURLErrorCannotConnectToHost {
                        UDPDeviceTool.updateAreaSAAddress()
                    }
                }
                
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
                    print(String(data: response.data, encoding: .utf8) ?? "")
                    print("---------------------------------------------------------------------------\n\n")
                }
                
                if model.status == 0 {
                    successCallback?(model.data)
                } else {
                    failureCallback?(model.status, model.reason)
                    if model.status == 2008 || model.status == 2009 { ///　云端登录状态丢失
                        DispatchQueue.main.async {
                            SceneDelegate.shared.window?.makeToast("登录状态丢失".localizedString)
                            AuthManager.shared.lostLoginState()
                        }
                        
                    }
                    
                }
                
            case .failure(let error):
                var statusCode = -1
                let moyaError = error as MoyaError
                let errorMessage = "error"
                
                if let afError = moyaError.errorUserInfo["NSUnderlyingError"] as? Alamofire.AFError,
                   let underlyingError = afError.underlyingError {
                    statusCode = (underlyingError as NSError).code
                    /// 可能是SA地址发生了改变 尝试搜索发现SA
                    if statusCode == NSURLErrorNotConnectedToInternet || statusCode == NSURLErrorCannotConnectToHost {
                        UDPDeviceTool.updateAreaSAAddress()
                    }
                       
                }
                
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
