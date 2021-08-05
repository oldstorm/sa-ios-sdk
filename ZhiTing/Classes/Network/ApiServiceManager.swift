//
//  ApiServiceManager.swift
//  ZhiTing
//
//  Created by iMac on 2021/6/18.
//

import Alamofire
import Moya
import Foundation

fileprivate let requestClosure = { (endpoint: Endpoint, closure: (Result<URLRequest, MoyaError>) -> Void)  -> Void in
    do {
        var  urlRequest = try endpoint.urlRequest()
        urlRequest.timeoutInterval = 15
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlRequest.httpShouldHandleCookies = true
        closure(.success(urlRequest))
    } catch MoyaError.requestMapping(let url) {
        closure(.failure(MoyaError.requestMapping(url)))
    } catch MoyaError.parameterEncoding(let error) {
        closure(.failure(MoyaError.parameterEncoding(error)))
    } catch {
        closure(.failure(MoyaError.underlying(error, nil)))
    }
    
}

class ApiServiceManager {
    static let shared = ApiServiceManager()
    
    private init() {}
    let apiService = MoyaProvider<ApiService>(requestClosure: requestClosure)
}


extension ApiServiceManager {
    /// 获取验证码
    /// - Parameters:
    ///   - type: 验证码类型
    ///   - target: 目标
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func getCaptcha(type: CaptchaType, target: String, successCallback: ((CaptchaResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.captcha(type: type, target: target), modelType: CaptchaResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    
    /// 注册
    /// - Parameters:
    ///   - phone: 手机号
    ///   - password: 密码
    ///   - captcha: 验证码
    ///   - captchaId: 验证码id
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func register(phone: String, password: String, captcha: String, captchaId: String, successCallback: ((RegisterResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.register(phone: phone, password: password, captcha: captcha, captcha_id: captchaId), modelType: RegisterResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 家庭列表
    /// - Parameters:
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func areaList(successCallback: ((AreaListReponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
         apiService.requestModel(.areaList, modelType: AreaListReponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 场景列表
    /// - Parameters:
    ///   - type: 0为全部场景;1为有控制权限的场景
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func sceneList(type: Int, successCallback: ((SceneListReponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.sceneList(type: type), modelType: SceneListReponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 绑定云
    /// - Parameters:
    ///   - area: 家庭
    ///   - cloud_user_id: 云用户ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func bindCloud(area: Area, cloud_user_id: Int, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.bindCloud(area: area, cloud_user_id: cloud_user_id), modelType: BaseModel.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 家庭细节
    /// - Parameters:
    ///   - area_id: 家庭ID
    ///   - is_bind: 是否绑定
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func areaDetail(area: Area, successCallback: ((AreaDetailResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.areaDetail(area: area), modelType: AreaDetailResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    

    /// 房间列表
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func areaLocationsList(area: Area, successCallback: ((AreaLocationListResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.areaLocationsList(area: area), modelType: AreaLocationListResponse.self, successCallback: successCallback,failureCallback: failureCallback)
    }
    
    /// 设置房间顺序
    /// - Parameters:
    ///   - area: 家庭
    ///   — location_order： 排列顺序
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func setLocationOrders(area: Area, location_order: [Int], successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.setLocationOrders(area: area, location_order: location_order), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }
    
    /// 房间详情
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func locationDetail(area: Area, id: Int, successCallback: ((Location) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.locationDetail(area: area, id: id), modelType: Location.self, successCallback: successCallback,failureCallback: failureCallback)
    }
    
    /// 更改房间名称
    /// - Parameters:
    ///   - area: 家庭
    ///   — name : 名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func changeLocationName(area: Area, id: Int,name: String, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.changeLocationName(area: area, id: id, name: name), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }
    
    /// 更改家庭名称
    /// - Parameters:
    ///   - area: 家庭
    ///   — name : 名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func changeAreaName(area: Area, name: String, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.changeAreaName(area: area, name: name), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }
    
    /// 删除房间
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func deleteLocation(area: Area, id: Int, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.deleteLocation(area: area, id: id ), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }

    /// 删除家庭
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func deleteArea(area: Area , successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.deleteArea(area: area), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }
    
    /// 退出家庭
    /// - Parameters:
    ///   - area_id: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func quitArea(area: Area, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.quitArea(area: area), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }


    
    /// 创建家庭
    /// - Parameters:
    ///   - name: 家庭名称
    ///   - locations_name： 房间
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func createArea(name: String, locations_name: [String], successCallback: ((CreateAreaResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.createArea(name: name, locations_name: locations_name), modelType: CreateAreaResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }

    /// 设备列表
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func deviceList(type: Int = 0, area: Area, successCallback: ((DeviceListResponseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.deviceList(type: type, area: area), modelType: DeviceListResponseModel.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 扫描二维码
    /// - Parameters:
    ///   - area_id: 家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func scanQRCode(qr_code: String, url: String, nickname: String, token: String?, area_id: Int = 0, successCallback: ((ScanResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.scanQRCode(qr_code: qr_code, url: url, nickname: nickname, token: token, area_id: area_id), modelType: ScanResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 获取二维码
    /// - Parameters:
    ///   - area_id: 家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func getInviteQRCode(area: Area, role_ids: [Int], successCallback: ((QRCodeResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.getInviteQRCode(area: area, role_ids: role_ids), modelType: QRCodeResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }

    

    /// 添加SA设备
    /// - Parameters:
    ///   - url: SA Url地址
    ///   - device: 设备信息
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func addSADevice(url: String, device: DiscoverDeviceModel, successCallback: ((ResponseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.addSADevice(url: device.address, device: device), modelType: ResponseModel.self, successCallback: successCallback, failureCallback: failureCallback)
    }

    /// 添加通过SA发现设备
    /// - Parameters:
    ///   - area: 家庭
    ///   - device: 设备信息
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func addDiscoverDevice(device: DiscoverDeviceModel, area: Area, successCallback: ((ResponseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.addDiscoverDevice(device: device, area: area), modelType: ResponseModel.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 同步家庭信息
    /// - Parameters:
    ///   - SyncSAModel: 同步SA信息
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func syncArea(syncModel: SyncSAModel, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.syncArea(syncModel: syncModel), modelType: BaseModel.self, successCallback: successCallback, failureCallback: failureCallback)
    }

    /// 查看SA绑定情况
    /// - Parameters:
    ///   - url: SA的Url
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func checkSABindState(url: String, successCallback: ((SABindResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.checkSABindState(url: url), modelType: SABindResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }

    /// 设备详情
    /// - Parameters:
    ///   - area: 家庭
    ///   - device_id: 设备ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func deviceDetail(area: Area, device_id: Int, successCallback: ((DeviceInfoResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.deviceDetail(area: area, device_id: device_id), modelType: DeviceInfoResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 删除设备
    /// - Parameters:
    ///   - area: 家庭
    ///   - device_id: 设备ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func deleteDevice(area: Area, device_id: Int, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.deleteDevice(area: area, device_id: device_id), modelType: BaseModel.self, successCallback: successCallback, failureCallback: failureCallback)
    }

    /// 修改设备名称
    /// - Parameters:
    ///   - area: 家庭
    ///   - device_id: 设备ID
    ///   - name: 设备名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func editDevice(area: Area, device_id: Int, name: String, location_id: Int = -1, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.editDevice(area: area, device_id: device_id, name: name, location_id: location_id), modelType: BaseModel.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    
    /// 添加房间
    /// - Parameters:
    ///   - area: 家庭
    ///   - name: 房间名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func addLocation(area: Area, name: String, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.addLocation(area: area, name: name), modelType: BaseModel.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 获取scopeToken
    /// - Parameters:
    ///   - area: 家庭
    ///   - scopes:
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func scopeToken(area: Area, scopes: [String], successCallback: ((ScopeTokenResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.scopeToken(area: area, scopes: scopes), modelType: ScopeTokenResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }


    /// 更改用户信息
    /// - Parameters:
    ///   - user_id: 用户id
    ///   - nickname:
    ///   - account_name:
    ///   - password:
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func editUser(user_id: Int, nickname: String = "", account_name: String, password: String, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        
        apiService.requestModel(.editUser(user_id: user_id, nickname: nickname, account_name: account_name, password: password), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
        
    }
    
    /// 更改云端账号信息
    /// - Parameters:
    ///   - nickname: 昵称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func editCloudUser(user_id: Int, nickname: String = "", successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        
        apiService.requestModel(.editCloudUser(user_id: user_id, nickname: nickname), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
        
    }

    /// 用户详情
    /// - Parameters:
    ///   - area: 家庭
    ///   - id: 用户ID
    ///   — withHeader：是否带header参数
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func userDetail(area: Area, id: Int, successCallback: ((User) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.userDetail(area: area, id: id), modelType: User.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 云端用户详情
    /// - Parameters:
    ///   - id: 用户ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func cloudUserDetail(id: Int, successCallback: ((InfoResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.cloudUserDetail(id: id), modelType: InfoResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }

    /// 品牌
    /// - Parameters:
    ///   - name: 名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func brands(name: String, successCallback: ((BrandListResponseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.brands(name: name), modelType: BrandListResponseModel.self , successCallback: successCallback, failureCallback: failureCallback)
    }

    /// 品牌详情
    /// - Parameters:
    ///   - name: 名称
    ///   - id: 用户ID
    ///   — withHeader：是否带header参数
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func brandDetail(name: String, successCallback: ((BrandDetailResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.brandDetail(name:name), modelType: BrandDetailResponse.self , successCallback: successCallback, failureCallback: failureCallback)
    }

    /// 用户权限
    /// - Parameters:
    ///   - area: 家庭
    ///   - user_id: 用户ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func rolesPermissions(area: Area, user_id: Int, successCallback: ((RolePermissionsResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        
        apiService.requestModel(.rolesPermissions(area: area, user_id: user_id), modelType: RolePermissionsResponse.self , successCallback: successCallback, failureCallback: failureCallback)
    }

    /// 成员列表
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func memberList(area: Area, successCallback: ((MembersResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        
        apiService.requestModel(.memberList(area: area), modelType: MembersResponse.self , successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 角色列表
    /// - Parameters:
    ///   - area: 家庭
    ///   - user_id: 用户ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func rolesList(area: Area, successCallback: ((RoleListResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.rolesList(area: area), modelType: RoleListResponse.self ,successCallback: successCallback, failureCallback: failureCallback)
    }

    
    /// 删除成员
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func deleteMember(area: Area, id: Int, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.deleteMember(area: area, id: id), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }

    /// 编辑成员
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func editMember(area: Area, id: Int, role_ids: [Int], successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.editMember(area: area, id: id, role_ids: role_ids), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }

    
    /// 转移拥有者
    /// - Parameters:
    ///   - area_id: 家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func transferOwner(area: Area, id: Int, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.transferOwner(area: area, id: id), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }

    /// 登陆
    /// - Parameters:
    ///   - phone: 手机号码
    ///    - password：密码
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func login(phone: String, password: String, successCallback: ((ResponseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.login(phone: phone, password: password), modelType: ResponseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }
    
    /// 退出登录
    /// - Parameters:
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func logout(successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.logout, modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }
    

    /// 场景执行
    /// - Parameters:
    ///   - scene_id: 场景ID
    ///    - is_execute：执行开关
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func sceneExecute(scene_id: Int, is_execute: Bool, area: Area = AppDelegate.shared.appDependency.authManager.currentArea, successCallback: ((isSuccessModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.sceneExecute(scene_id: scene_id, is_execute: is_execute, area: area), modelType: isSuccessModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }

    /// 创建场景
    /// - Parameters:
    ///   - scene: 场景模型
    ///    - area_id：家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func createScene(scene: SceneDetailModel, area: Area = AppDelegate.shared.appDependency.authManager.currentArea, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.createScene(scene: scene, area: area), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }

    /// 场景详情
    /// - Parameters:
    ///   - id: 场景ID
    ///    - area_id：家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func sceneDetail(id: Int, area: Area = AppDelegate.shared.appDependency.authManager.currentArea, successCallback: ((SceneDetailModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.sceneDetail(id: id, area: area), modelType: SceneDetailModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }

    /// 删除场景
    /// - Parameters:
    ///   - id: 场景ID
    ///    - area_id：家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func deleteScene(id: Int, area: Area = AppDelegate.shared.appDependency.authManager.currentArea, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.deleteScene(id: id, area: area), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }
    
    /// 编辑场景
    /// - Parameters:
    ///   - id: 场景ID
    ///   - scene: 场景模型
    ///    - area_id：家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func editScene(id: Int, scene: SceneDetailModel, area: Area = AppDelegate.shared.appDependency.authManager.currentArea, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.editScene(id: id, scene: scene, area: area), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
    }

    /// 场景日志
    /// - Parameters:
    ///   - id: 场景ID
    ///   - scene: 场景模型
    ///    - area_id：家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func sceneLogs(start: Int = 0, size: Int = 20, area: Area = AppDelegate.shared.appDependency.authManager.currentArea, successCallback: (([SceneHistoryMonthModel]) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestListModel(.sceneLogs(start: start, size: size, area: area), modelType: SceneHistoryMonthModel.self, successCallback: successCallback, failureCallback: failureCallback)
    }

    
}




// MARK: - ResposneModel
 class CaptchaResponse: BaseModel {
    var captcha_id = ""
}

 class RegisterResponse: BaseModel {
    var user_info = User()
}

 class AreaListReponse: BaseModel {
    var areas = [Area]()
}

class SceneListReponse: BaseModel {
    //手动场景列表
    var manual = [SceneTypeModel]()
    //自动场景列表
    var auto_run = [SceneTypeModel]()
    
}

class AreaDetailResponse: BaseModel {
        var name = ""
        var location_count = 0
}

class AreaLocationListResponse: BaseModel {
    var locations = [Location]()
}

class CreateAreaResponse: BaseModel {
   var id = 1
}

class DeviceListResponseModel: BaseModel {
    var devices = [Device]()
}

class ScanResponse: BaseModel {
    var user_info = User()
    var area_id: Int?
}

class QRCodeResponse: BaseModel {
    var qr_code = ""
    
}

class ResponseModel: BaseModel {
    var device_id: Int = -1
    var user_info = User()
    var plugin_url = ""
}

class SABindResponse: BaseModel {
    var is_bind = false
}

class DeviceInfoResponse: BaseModel {
    var device_info = Device()
}

class ScopeTokenModel: BaseModel {
    var token = ""
    var expires_in = 0
}

class ScopeTokenResponse: BaseModel {
    var scope_token = ScopeTokenModel()
}

class InfoResponse: BaseModel {
    var user_info = User()
}

class BrandListResponseModel: BaseModel {
    var brands = [Brand]()
}

class BrandDetailResponse: BaseModel {
    var brand = Brand()
}

class RolePermissionsResponse: BaseModel {
    var permissions = RolePermission()
}

class MembersResponse: BaseModel {
    var self_id = 0
    var is_creator = false
    var users = [User]()
}

class RoleListResponse: BaseModel {
    var roles = [Role]()
}
