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

enum ApiService {
    // login & register
    case register(country_code: String = "86", phone: String, password: String, captcha: String, captcha_id: String)
    case login(phone: String, password: String)
    case logout
    case captcha(type: CaptchaType, target: String, country_code: String = "86")
    case editUser(user_id: Int, nickname: String = "", account_name: String, password: String)

    //sa
    case syncArea(syncModel: SyncSAModel)
    case checkSABindState(url: String)

    // device
    case deviceList(type: Int = 0)
    case addDiscoverDevice(device: DiscoverDeviceModel)
    case addSADevice(url: String, device: DiscoverDeviceModel)
    case deviceDetail(device_id: Int)
    case editDevice(device_id: Int, name: String = "", location_id: Int = -1)
    case deleteDevice(device_id: Int)
    
    // scene
    
    case sceneList(type: Int = 0)
    case createScene(scene: SceneDetailModel)
    case sceneDetail(id: Int)
    case editScene(id: Int, scene: SceneDetailModel)
    case deleteScene(id: Int)
    case sceneExecute(scene_id: Int, is_execute: Bool)
    case sceneLogs(start: Int = 0, size: Int = 20)

    
    // brand
    case brands(name: String)
    case brandDetail(name: String)
    
    // plugin
    case pluginDetail(plugin_id: String)
    
    // area
    case defaultLocationList
    case areaList
    case createArea(name: String, locations_name: [String])
    case areaDetail(area_id: Int)
    case changeAreaName(area_id: Int, name: String)
    case deleteArea(area_id: Int)
    case quitArea(area_id: Int, user_id: Int)
    case getInviteQRCode(token: String, user_id: Int, area_id: Int, role_ids: [Int])
    case scanQRCode(qr_code: String, url: String, nickname: String, token: String?)
    
    // members
    case memberList
    case userDetail(id: Int)
    case deleteMember(id: Int)
    case editMember(id: Int, role_ids: [Int])
    
    // roles
    case rolesList
    case rolesPermissions(user_id: Int)
    
    // location
    case areaLocationsList
    case LocationDetail(id: Int)
    case addLocation(name: String)
    case changeLocationName(id: Int, name: String)
    case deleteLocation(id: Int)
    case setLocationOrders(location_order: [Int])
    
}

/// if print the debug info
fileprivate let printDebugInfo = false

var baseUrl = ""

var cloudUrl = ""

extension ApiService: TargetType {
   

    var baseURL: URL {
        switch self {
        case .logout, .login, .register, .captcha:
            return URL(string: cloudUrl)!
        case .scanQRCode(_, let url, _, _):
            return URL(string: url)!
        case .addSADevice(let url, _):
            return URL(string: "http://\(url)")!
        case .checkSABindState(let url):
            return URL(string: "http://\(url)")!
        default:
//            return URL(string: baseUrl)!
            return URL(string: "http://\(AppDelegate.shared.appDependency.authManager.currentSA.ip_address)")!
        }
        
    }
    
    var path: String {
        switch self {
        case .brands:
            return "/brands"
        case .brandDetail(let name):
            return "/brands/\(name)"
        case .pluginDetail(let plugin_id):
            return "/plugin/\(plugin_id)"
        case .addDiscoverDevice:
            return "/devices"
        case .defaultLocationList:
            return "/location_tmpl"
        case .createArea:
            return "/areas"
        case .areaList:
            return "/areas"
        case .areaDetail(let id):
            return "/areas/\(id)"
        case .changeAreaName(let id, _):
            return "/areas/\(id)"
        case .deleteArea(let id):
            return "/areas/\(id)"
        case .LocationDetail(let id):
            return "/locations/\(id)"
        case .changeLocationName(let id, _):
            return "/locations/\(id)"
        case .deleteLocation(let id):
            return "/locations/\(id)"
        case .addLocation:
            return "/locations"
        case .setLocationOrders:
            return "/locations"
        case .deviceDetail(let device_id):
            return "/devices/\(device_id)"
        case .editDevice(let device_id, _, _):
            return "devices/\(device_id)"
        case .areaLocationsList:
            return "/locations"
        case .deleteDevice(let device_id):
            return "/devices/\(device_id)"
        case .deviceList:
            return "/devices"
        case .sceneList:
            return "/scenes"
        case .createScene:
            return "/scenes"
        case .deleteScene(let scene_id):
            return "/scenes/\(scene_id)"
        case .editScene(let scene_id, _):
            return "/scenes/\(scene_id)"
        case .sceneExecute(let scene_id,_):
            return "/scenes/\(scene_id)/execute"  
        case .sceneDetail(let scene_id):
            return "/scenes/\(scene_id)"
        case .sceneLogs:
            return "/scene_logs"
        case .register:
            return "/users"
        case .login:
            return "/users/login"
        case .logout:
            return "/users/logout"
        case .captcha:
            return "/users/captcha"
        case .getInviteQRCode(_, let user_id, _, _):
            return "/users/\(user_id)/invitation/code"
        case .userDetail(let id):
            return "/users/\(id)"
        case .memberList:
            return "/users/"
        case .deleteMember(let id):
            return "/users/\(id)"
        case .editMember(let id, _):
            return "/users/\(id)"
        case .rolesList:
            return "/roles"
        case .quitArea(let area_id, let user_id):
            return "/areas/\(area_id)/users/\(user_id)"
        case .scanQRCode:
            return "/invitation/check"
        case .rolesPermissions(let role_id):
            return "/users/\(role_id)/permissions"
        case .syncArea:
            return "/sync"
        case .addSADevice:
            return "/devices"
        case .editUser(let user_id, _, _, _):
            return "/users/\(user_id)"
        case .checkSABindState:
            return "/check"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .brands:
            return .get
        case .brandDetail:
            return .get
        case .pluginDetail:
            return .get
        case .addDiscoverDevice:
            return .post
        case .defaultLocationList:
            return .get
        case .createArea:
            return .post
        case .areaList:
            return .get
        case .areaDetail:
            return .get
        case .changeAreaName:
            return .put
        case .deleteArea:
            return .delete
        case .LocationDetail:
            return .get
        case .changeLocationName:
            return .put
        case .deleteLocation:
            return .delete
        case .addLocation:
            return .post
        case .setLocationOrders:
            return .put
        case .deviceDetail:
            return .get
        case .editDevice:
            return .put
        case .areaLocationsList:
            return .get
        case .deleteDevice:
            return .delete
        case .deviceList:
            return .get
        case .sceneList:
            return .get
        case .createScene:
            return .post
        case .deleteScene:
            return .delete
        case .sceneExecute:
            return .post
        case .sceneDetail:
            return .get
        case .editScene:
            return .put
        case .sceneLogs:
            return .get
        case .register:
            return .post
        case .login:
            return .post
        case .logout:
            return .post
        case .captcha:
            return .get
        case .getInviteQRCode:
            return .post
        case .userDetail:
            return .get
        case .memberList:
            return .get
        case .deleteMember:
            return .delete
        case .editMember:
            return .put
        case .rolesList:
            return .get
        case .quitArea:
            return .delete
        case .scanQRCode:
            return .post
        case .rolesPermissions:
            return .get
        case .syncArea:
            return .post
        case .addSADevice:
            return .post
        case .editUser:
            return .put
        case .checkSABindState:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .brands(let name):
            return .requestParameters(parameters: ["name": name], encoding: URLEncoding.default)
        case .brandDetail(_):
            return .requestPlain
        case .pluginDetail:
            return .requestPlain
        case .addDiscoverDevice(let device):
            let deviceDict = device.toJSON() ?? [:]
            return .requestParameters(parameters: ["device": deviceDict], encoding: JSONEncoding.default)
        case .defaultLocationList:
            return .requestPlain
        case .createArea(let name, let locations_name):
            return .requestParameters(parameters: ["name" : name, "locations_name": locations_name], encoding: JSONEncoding.default)
        case .areaList:
            return .requestPlain
        case .areaDetail:
            return .requestPlain
        case .changeAreaName(_, let name):
            return .requestParameters(parameters: ["name": name], encoding: JSONEncoding.default)
        case .deleteArea(_):
            return .requestPlain
        case .LocationDetail(_):
            return .requestPlain
        case .changeLocationName(_, let name):
            return .requestParameters(parameters: ["name" : name], encoding: JSONEncoding.default)
        case .deleteLocation(_):
            return .requestPlain
        case .addLocation(let name):
            return .requestParameters(parameters: ["name": name], encoding: JSONEncoding.default)
        case .setLocationOrders(let location_order):
            return .requestParameters(parameters: ["locations_id": location_order], encoding: JSONEncoding.default)
        case .deviceDetail(_):
            return .requestPlain
        case .editDevice(_, let name, let location_id):
            var parameters = [String: Any]()
            if name != "" { parameters["name"] = name }
            if location_id > 0 { parameters["location_id"] = location_id }
            if location_id == -1 { parameters["location_id"] = 0 }

            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .sceneList(let type):
            return .requestParameters(parameters: ["type": type], encoding: URLEncoding.default)


        case .sceneLogs(let start, let size):
        return .requestParameters(parameters: ["start": start, "size": size], encoding: URLEncoding.default)
        case .sceneDetail(_):
            return .requestPlain
        case .createScene(let scene):
            let json = scene.toJSON() ?? [:]
            return .requestParameters(parameters: json, encoding: JSONEncoding.default)
        case .deleteScene(_):
            return .requestPlain

        case .editScene(_, let scene):
            let json = scene.toJSON() ?? [:]
            return .requestParameters(parameters: json, encoding: JSONEncoding.default)
        case .sceneExecute(_,let is_execute):
            return .requestParameters(parameters: ["is_execute": is_execute], encoding: JSONEncoding.default)

        case .areaLocationsList:
            return .requestPlain
        case .deleteDevice:
            return .requestPlain
        case .deviceList(let type):
            return .requestParameters(parameters: ["type": type], encoding: URLEncoding.default)
        case .register(let country_code, let phone, let password, let captcha, let captcha_id):
            return .requestParameters(
                parameters:
                    [
                        "country_code": country_code,
                        "phone": phone,
                        "password": password,
                        "captcha": captcha,
                        "captcha_id": captcha_id
                    ],
                encoding: JSONEncoding.default
            )
        case .login(let phone, let password):
            return .requestParameters(
                parameters:
                    [
                        "phone": phone,
                        "password": password
                    ],
                encoding: JSONEncoding.default
            )
        case .logout:
            return .requestPlain
        case .captcha(let type, let target, let country_code):
            return .requestParameters(
                parameters:
                    [
                        "type": type.rawValue,
                        "target": target,
                        "country_code": country_code
                    ],
                encoding: URLEncoding.default
            )
        case .getInviteQRCode(_, _, let area_id, let role_ids):
            return .requestParameters(
                parameters: [
                    "area_id": area_id,
                    "role_ids": role_ids
                ],
                encoding: JSONEncoding.default
            )
        case .userDetail:
            return .requestPlain
        case .memberList:
            return .requestPlain
        case .deleteMember:
            return .requestPlain
        case .editMember(_, let role_ids):
            return .requestParameters(parameters: ["role_ids" : role_ids], encoding: JSONEncoding.default)
        case .rolesList:
            return .requestPlain
        case .quitArea:
            return .requestPlain
        case .scanQRCode(let qr_code, _, let nickname, _):
            return .requestParameters(parameters: ["qr_code": qr_code, "nickname": nickname], encoding: JSONEncoding.default)
        case .rolesPermissions:
            return .requestPlain
        case .syncArea(let syncModel):
            let syncModelDict = syncModel.toJSON() ?? [:]
            return .requestParameters(parameters: syncModelDict, encoding: JSONEncoding.default)
        case .addSADevice(_, let device):
            let deviceDict = device.toJSON() ?? [:]
            return .requestParameters(parameters: ["device": deviceDict], encoding: JSONEncoding.default)
        case .editUser(_, let nickname, let account_name, let password):
            if nickname == "" {
                return .requestParameters(parameters: [ "account_name": account_name, "password": password], encoding: JSONEncoding.default)
            } else {
                return .requestParameters(parameters: [ "nickname": nickname], encoding: JSONEncoding.default)
            }
            
        case .checkSABindState:
            return .requestPlain
        }
        
    }
    
    var headers: [String : String]? {
        var headers = [String : String]()
        headers["Content-type"] = "application/json"
        switch self {
        case .scanQRCode(_, _, _, let token):
            if let token = token {
                headers["smart-assistant-token"] = token
            }
        case .addSADevice:
            break
            
        default:
            headers["smart-assistant-token"] = AppDelegate.shared.appDependency.authManager.currentSA.token
        }
        

        return headers
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
                
                guard let model = response.data.map(ApiServiceResponseModel<T>.self) else {
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
