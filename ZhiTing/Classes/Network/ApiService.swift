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
    /// 注册验证码
    case register
    /// 忘记密码验证码
    case forget_password
    /// 注销账号验证码
    case unregister
    /// 登录验证码
    case login
}

enum FileUploadAuth: String {
    /// 公有服务
    case local = "1"
    /// 私有服务
    case `private` = "2"
}

enum FileUploadServer: String {
    /// 公有服务
    case local = "1"
    /// 私有服务
    case cloud = "2"
}

enum FileUploadType {
    /// 图片文件
    case img
    /// 问题反馈附件
    case feedback(FeedbackSubType)
    
    var type: String {
        switch self {
        case .img:
            return "img"
        case .feedback:
            return "feedback"
        }
    }

    enum FeedbackSubType {
        case image
        case video(String)
        
        var mimeType: String {
            switch self {
            case .image:
                return "image/jpeg"
            case .video(let string):
                return "video/\(string.lowercased())"
            }
        }
    }
}

/// if print the debug info
fileprivate let printDebugInfo = true

#if DEBUG
/// 测试服sc地址
var cloudUrl = "https://scgz.zhitingtech.com"
/// k8s测试服
//var cloudUrl = "https://testsc.zhitingtech.com"
#else
/// 正式服sc地址
var cloudUrl = "https://gz.sc.zhitingtech.com"
#endif

/// 临时通道scheme
var temporarySchemeMode: String { return "https" }

/// 当前App支持的Api版本
var apiVersion = "2.0.0"



/// 接口枚举
enum ApiService {
    // login & register
    /// 注册
    case register(country_code: String = "86", phone: String, password: String, captcha: String, captcha_id: String)
    /// 登录
    case login(phone: String, password: String, login_type: Int = 0, country_code: String = "86", captcha: String, captcha_id: String)
    /// 退出登录
    case logout
    /// 注销账号
    case unregister(user_id: Int, captcha: String, captcha_id: String)
    /// 注销账号的注销家庭列表
    case unregisterList(user_id: Int)
    /// 获取验证码
    case captcha(type: CaptchaType, target: String, country_code: String = "86")
    /// 编辑SA用户
    case editSAUser(area: Area = AuthManager.shared.currentArea, user_id: Int = 0, nickname: String? = nil, account_name: String? = nil, password: String? = nil, old_password: String? = nil, avatar_id: Int?)
    /// SA绑定云端
    case bindCloud(area: Area, cloud_user_id: Int, url: String, sa_id: String? = nil, access_token: String)
    /// 云端账号信息
    case cloudUserDetail(id: Int)
    /// 编辑云端账号信息
    case editCloudUser(user_id: Int, nickname: String?, avatar_id: Int? = nil)
    /// sc上传文件(头像等)
    case scUploadFile(file_upload: Data, file_auth: FileUploadAuth, file_server: FileUploadServer, file_type: FileUploadType)
    /// 获取SA状态
    case getSAStatus(area: Area)
    /// 第三方云绑定列表 （SC）
    case thirdPartyCloudListSC(area: Area)
    /// 第三方云绑定列表（SA）
    case thirdPartyCloudListSA(area: Area)
    /// 解绑第三方云(SA)
    case unbindThirdPartyCloud(area: Area, app_id: Int)
    /// 问题反馈列表
    case feedbackList(user_id: Int)
    /// 问题反馈详情
    case feedbackDetail(user_id: Int, feedback_id: Int)
    /// 新增问题反馈
    case createFeedback(user_id: Int, feedback_type: Int, type: Int, description: String,
                        file_ids: [Int]? = nil, contact_information: String? = nil,
                        is_auth: Bool = false, api_version: String? = nil, app_version: String? = nil,
                        phone_model: String? = nil, phone_system: String? = nil, sa_id: String? = nil)

    // SA
    /// 同步家庭到SA
    case syncArea(syncModel: SyncSAModel, url: String, token: String)
    /// 设置SA找回凭证权限
    case settingTokenAuth(area: Area, tokenModel: TokenAuthSettingModel)
    /// 获取SA软件最新版本信息
    case getSoftwareLatestVersion(area: Area)
    /// SA软件升级
    case updateSoftware(area: Area, version: String)
    /// 获取SA软件版本
    case getSoftwareVersion(area: Area)
    /// 检测sa绑定状态
    case checkSABindState(url: String)
    /// 获取SA固件最新版本信息
    case getFirmwareLatestVersion(area: Area)
    /// SA固件升级
    case updateFirmware(area: Area, version: String)
    /// 获取SA固件版本
    case getFirmwareVersion(area: Area)
    /// 获取家庭迁移地址
    case migrationAddr(area: Area)
    /// 迁移云端家庭到本地
    case migrationCloudToLocal(area: Area, migration_url: String, backup_file: String, sum: String)
    /// 获取SA扩展服务列表
    case getSAExtensions(area: Area)
    /// 删除SA设备
    case deleteSA(area: Area, is_migration_sa: Bool, is_del_cloud_disk: Bool, cloud_area_id: String?, cloud_access_token: String?)
    /// sa上传文件(头像等)
    case saUploadFile(area: Area = AuthManager.shared.currentArea, file_upload: Data, file_type: FileUploadType)

    // device
    /// 设备列表
    case deviceList(type: Int = 0, area: Area)
    /// 添加SA
    case addSADevice(url: String, device: DiscoverDeviceModel)
    /// 设备详情
    case deviceDetail(area: Area, device_id: Int, type: Int)
    /// 编辑设备信息
    case editDevice(area: Area, device_id: Int, name: String? = nil, location_id: Int = 0, department_id: Int = 0, logo_type: Int? = nil)
    /// 删除设备
    case deleteDevice(area: Area, device_id: Int)
    /// 获取SA设备AccessToken
    case getDeviceAccessToken
    /// 获取设备图标列表
    case deviceLogoList(area: Area, device_id: Int)
    
    // scene
    /// 场景列表
    case sceneList(type: Int = 0, area: Area = AuthManager.shared.currentArea)
    /// 创建场景
    case createScene(scene: SceneDetailModel, area: Area = AuthManager.shared.currentArea)
    /// 场景详情
    case sceneDetail(id: Int, area: Area = AuthManager.shared.currentArea)
    /// 编辑场景
    case editScene(id: Int, scene: SceneDetailModel, area: Area = AuthManager.shared.currentArea)
    /// 删除场景
    case deleteScene(id: Int, area: Area = AuthManager.shared.currentArea)
    /// 执行场景
    case sceneExecute(scene_id: Int, is_execute: Bool, area: Area = AuthManager.shared.currentArea)
    /// 场景日志
    case sceneLogs(start: Int = 0, size: Int = 20, area: Area = AuthManager.shared.currentArea)
    
    
    // brand
    /// 品牌列表
    case brands(name: String, area: Area = AuthManager.shared.currentArea)
    /// 品牌详情
    case brandDetail(name: String, area: Area = AuthManager.shared.currentArea)
    
    // plugin
    /// 插件列表
    case plugins(area: Area = AuthManager.shared.currentArea, list_type: Int)
    /// 插件详情
    case pluginDetail(plugin_id: String, area: Area = AuthManager.shared.currentArea)
    /// 安装插件
    case installPlugin(area: Area = AuthManager.shared.currentArea, name: String, plugins: [String])
    /// 删除插件
    case deletePlugin(area: Area = AuthManager.shared.currentArea, name: String, plugins: [String])
    /// 通过插件id删除插件
    case deletePluginById(area: Area = AuthManager.shared.currentArea, id: String)
    /// 下载插件包
    case downloadPlugin(area: Area = AuthManager.shared.currentArea, url: String, destination: DownloadRequest.Destination)
    
    // area
    /// 创建房间时默认房间列表
    case defaultLocationList
    /// 家庭/公司列表
    case areaList
    /// 创建家庭/公司
    case createArea(name: String, location_names: [String], department_names: [String], area_type: Int)
    /// 家庭/公司详情
    case areaDetail(area: Area)
    /// 更改家庭/公司名称
    case changeAreaName(area: Area, name: String)
    /// 删除家庭/公司
    case deleteArea(area: Area, is_del_cloud_disk: Bool)
    /// 退出家庭/公司
    case quitArea(area: Area)
    /// 获取家庭/公司邀请码
    case getInviteQRCode(area: Area, role_ids: [Int], department_ids: [Int])
    /// 扫描家庭/公司二维码
    case scanQRCode(qr_code: String, url: String, nickname: String, avatar_url: String? = nil, token: String?)
    
    // members
    /// 家庭/公司成员列表
    case memberList(area: Area)
    /// 家庭/公司成员详情
    case userDetail(area: Area, id: Int)
    /// 删除家庭/公司成员
    case deleteMember(area: Area, id: Int)
    /// 编辑家庭/公司成员
    case editMember(area: Area, id: Int, role_ids: [Int], department_ids: [Int])
    
    // roles
    /// 家庭/公司 角色列表
    case rolesList(area: Area)
    /// 获取用户角色权限
    case rolesPermissions(area: Area, user_id: Int)
    
    // location
    /// 房间列表
    case locationsList(area: Area)
    /// 房间详情
    case locationDetail(area: Area, id: Int)
    /// 添加房间
    case addLocation(area: Area, name: String)
    /// 编辑房间名称
    case changeLocationName(area: Area, id: Int, name: String)
    /// 删除房间
    case deleteLocation(area: Area, id: Int)
    /// 设置房间顺序
    case setLocationOrders(area: Area, location_order: [Int])
    
    // department
    /// 部门列表
    case departmentList(area: Area)
    /// 添加部门
    case addDepartment(area: Area, name: String)
    /// 设置部门顺序
    case setDepartmentOrders(area: Area, department_order: [Int])
    /// 部门详情
    case departmentDetail(area: Area, id: Int)
    /// 添加部门成员
    case addDepartmentMember(area: Area, id: Int, users: [Int])
    /// 更新部门信息
    case updateDepartment(area: Area, id: Int, name: String, manager_id: Int?)
    /// 删除部门
    case deleteDepartment(area: Area, id: Int)
    
    // diskAuth
    /// 网盘授权项列表
    case scopeList(area: Area)
    /// 网盘授权
    case scopeToken(area: Area, scopes: [String])
    
    /// 转移拥有者
    case transferOwner(area: Area,id: Int)
    
    /// 获取临时通道
    case temporaryIP(area: Area, scheme: String = "http")
    
    /// 获取临时通道
    case temporaryIPBySAID(sa_id: String, scheme: String = "http")
    
    /// SC获取SAtoken
    case getSAToken(area: Area)
    
    /// 发现设备 - 设备列表
    case commonDeviceList(area: Area)
    
    /// 发现设备 - 设备一级分类列表
    case commonDeviceMajorList(area: Area)
    
    /// 发现设备 - 设备二级分类列表
    case commonDeviceMinorList(area: Area, type: String)

    /// 插件包 —— 检测更新
    case checkPluginUpdate(id: String, area: Area)
    
    /// 获取验证码
    case getCaptcha(area: Area)

    /// 修改密码
    case changePWD(area:Area, old_password: String, new_password: String)
    
    /// 忘记密码
    case forgetPwd(country_code: String = "86", phone: String, new_password: String, captcha: String, captcha_id: String)

    /// 获取App最新版本和支持的最低版本
    case getAppVersions
    
    /// 获取App支持的最低Api版本
    case getAppSupportApiVersion(version: String)
    /// 获取SA支持的最低Api版本
    case getSASupportApiVersion(version: String)
    /// 设置场景排序
    case setSceneSort(area: Area, sceneIds: [Int])
}


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

fileprivate var _callbackQueue = DispatchQueue(label: "MoyaRequestQueue")

extension MoyaProvider {
    
    @discardableResult
    func requestModel<T: BaseModel>(_ target: Target, modelType: T.Type, successCallback: ((_ response: T) -> Void)?, failureCallback: ((_ code: Int, _ errorMessage: String) -> Void)? = nil) -> Moya.Cancellable? {
        return request(target, callbackQueue: _callbackQueue) { (result) in
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
                    DispatchQueue.main.async {
                        failureCallback?(response.statusCode, "error: \(String(data: response.data, encoding: .utf8) ?? "unknown") ")
                        print("---------------------------------------------------------------------------")
                        print("error: \(String(data: response.data, encoding: .utf8) ?? "unknown") errorCode:\(response.statusCode)")
                        print("---------------------------------------------------------------------------\n\n")
                    }
                    return
                }
                
                if printDebugInfo {
                    print("---------------------------------------------------------------------------")
                    print(String(data: response.data, encoding: .utf8) ?? "")
                    print("---------------------------------------------------------------------------\n\n")
                }
                DispatchQueue.main.async {
                    if model.status == 0 {
                        successCallback?(model.data)
                    } else {
                        failureCallback?(model.status, model.reason)
                        if model.status == 2008 || model.status == 2009 { ///　云端登录状态丢失
                            SceneDelegate.shared.window?.makeToast("登录状态丢失".localizedString)
                            AuthManager.shared.lostLoginState()
                            
                            
                        } else if model.status == 2014 { /// 云端账号密码已更改
                            WarningAlert.show(message: "密码已更改，请重新登陆",sureTitle: "确定",iconImage: .assets(.icon_warning_light)) {
                                AuthManager.shared.logOut {
                                    
                                }
                            }
                        } else if model.status == 2015 { ///　云端账号已被注销
                            AreaCache.removeAllCloudArea()
                            UserManager.shared.currentUser.user_id = 0
                            UserManager.shared.currentUser.phone = ""
                            UserManager.shared.isLogin = false
                            
                            if AreaCache.areaList().count == 0 {
                                AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family)
                            }
                            
                            if let area = AreaCache.areaList().first {
                                AuthManager.shared.currentArea = area
                            }
                            AppDelegate.shared.appDependency.tabbarController.homeVC?.navigationController?.popToRootViewController(animated: false)
                            AppDelegate.shared.appDependency.tabbarController.sceneVC?.navigationController?.popToRootViewController(animated: false)
                            AppDelegate.shared.appDependency.tabbarController.mineVC?.navigationController?.popToRootViewController(animated: false)
                            AppDelegate.shared.appDependency.tabbarController.selectedIndex = 0

                            SceneDelegate.shared.window?.makeToast("云端账号已被注销".localizedString)
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
                    if statusCode == NSURLErrorNotConnectedToInternet || statusCode == NSURLErrorCannotConnectToHost || statusCode == NSURLErrorBadURL {
                        DispatchQueue.main.async {
                            UDPDeviceTool.updateAreaSAAddress()
                        }
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
                DispatchQueue.main.async {
                    failureCallback?(statusCode, errorMessage)
                }
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
                    DispatchQueue.main.async {
                        failureCallback?(response.statusCode, String(data: response.data, encoding: .utf8) ?? "error")
                    }
                    return
                }
                
                if printDebugInfo {
                    print("---------------------------------------------------------------------------")
                    print(String(data: response.data, encoding: .utf8) ?? "")
                    print("---------------------------------------------------------------------------\n\n")
                }
                DispatchQueue.main.async {
                    if model.status == 0 {
                        successCallback?(model.data)
                    } else {
                        failureCallback?(model.status, model.reason)
                        if model.status == 2008 || model.status == 2009 { ///　云端登录状态丢失
                            SceneDelegate.shared.window?.makeToast("登录状态丢失".localizedString)
                            AuthManager.shared.lostLoginState()
                        } else if model.status == 2014 { /// 云端账号密码已更改
                            WarningAlert.show(message: "密码已更改，请重新登陆",sureTitle: "确定",iconImage: .assets(.icon_warning_light)) {
                                AuthManager.shared.logOut {
                                    
                                }
                            }
                        } else if model.status == 2015 { ///　云端账号已被注销
                            AreaCache.removeAllCloudArea()
                            UserManager.shared.currentUser.user_id = 0
                            UserManager.shared.currentUser.phone = ""
                            UserManager.shared.isLogin = false
                            
                            if AreaCache.areaList().count == 0 {
                                AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family)
                            }
                            
                            if let area = AreaCache.areaList().first {
                                AuthManager.shared.currentArea = area
                            }
                            
                            AppDelegate.shared.appDependency.tabbarController.homeVC?.navigationController?.popToRootViewController(animated: false)
                            AppDelegate.shared.appDependency.tabbarController.sceneVC?.navigationController?.popToRootViewController(animated: false)
                            AppDelegate.shared.appDependency.tabbarController.mineVC?.navigationController?.popToRootViewController(animated: false)
                            AppDelegate.shared.appDependency.tabbarController.selectedIndex = 0
                            SceneDelegate.shared.window?.makeToast("云端账号已被注销".localizedString)
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
                    if statusCode == NSURLErrorNotConnectedToInternet || statusCode == NSURLErrorCannotConnectToHost || statusCode == NSURLErrorBadURL {
                        DispatchQueue.main.async {
                            UDPDeviceTool.updateAreaSAAddress()
                        }
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
                DispatchQueue.main.async {
                    failureCallback?(statusCode, errorMessage)
                }
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
