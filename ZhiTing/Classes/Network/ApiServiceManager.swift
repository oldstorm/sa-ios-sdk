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

class ApiServiceManager: NSObject {
    static let shared = ApiServiceManager()
    
    override private init() {
        super.init()
    }
    
    /// 处理证书信任的urlSession
    lazy var mySession: Moya.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        return Session(configuration: configuration, delegate: MySessionDelegate(), startRequestsImmediately: false)
    }()
    
    lazy var apiService = MoyaProvider<ApiService>(requestClosure: requestClosure,session: mySession)
    
}

class MySessionDelegate: SessionDelegate {
    override func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        //        super.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler)
        
        let areaId = "\(AuthManager.shared.currentArea.id ?? "")"
        
        let urlString = task.currentRequest?.url?.absoluteString ?? ""
        
        if let serverTrust = challenge.protectionSpace.serverTrust,
           let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            
            let remoteCertificateData: Data = SecCertificateCopyData(certificate) as Data
            
            //正则获取当前host
            let regulaStr = "^http(s)?://(.*?)/"
            guard let regex = try? NSRegularExpression(pattern: regulaStr, options: []) else {
                return
            }
            
            let results = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count))
            var urls = [String]()
            if results.count > 0 {
                for result in results {
                    let str = (urlString as NSString).substring(with: result.range)
                    urls.append(str)
                }
            }
            
            let url = urls.first ?? ""
            //SC，直接信任
            if url.contains(cloudUrl) {
                let credential = URLCredential(trust: serverTrust)
                challenge.sender?.use(credential, for: challenge)
                // 证书校验通过
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential)
                return
            }
            
            //根据areaID去沙河查找对应证书
            
            let certificateData: Data = UserDefaults.standard.value(forKey: url) as? Data ?? Data()
            if !certificateData.isEmpty {
                //有证书则校验
                // 证书校验：这里直接比较本地证书文件内容 和 服务器返回的证书文件内容
                if remoteCertificateData == certificateData {
                    //检验通过
                    let credential = URLCredential(trust: serverTrust)
                    challenge.sender?.use(credential, for: challenge)
                    
                    // 证书校验通过
                    completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential)
                }else{
                    // 证书校验不通过
                    UserDefaults.standard.removeObject(forKey: areaId)
                    
                    DispatchQueue.main.async {
                        TipsAlertView.show(message: "证书认证失败，是否重新授权？") {
                            print("点击了确定")
                            UserDefaults.standard.setValue(remoteCertificateData, forKey: url)
                            let credential = URLCredential(trust: serverTrust)
                            challenge.sender?.use(credential, for: challenge)
                            completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, credential)
                        } cancelCallback: {
                            print("点击了取消")
                            challenge.sender?.cancel(challenge)
                            completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                        }
                        
                    }
                    
                }
            }else{
                //无证书,存储证书，直接通过
                DispatchQueue.main.async {
                    TipsAlertView.show(message: "是否信任此证书？") {
                        print("点击了确定")
                        UserDefaults.standard.setValue(remoteCertificateData, forKey: url)
                        let credential = URLCredential(trust: serverTrust)
                        challenge.sender?.use(credential, for: challenge)
                        completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, credential)
                    } cancelCallback: {
                        print("点击了取消")
                        challenge.sender?.cancel(challenge)
                        completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                    }
                }
                
            }
            
        }
    }
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
        requestTemporaryIP(area: AuthManager.shared.currentArea) { [weak self] ip in
            guard let self = self else {return}
            //获取临时通道地址
            if ip != "" {
                AuthManager.shared.currentArea.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.sceneList(type: type), modelType: SceneListReponse.self, successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 绑定云
    /// - Parameters:
    ///   - area: 家庭
    ///   - cloud_user_id: 云用户ID
    ///   - cloud_area_id: 要绑定云端家庭id
    ///   - url: 请求的地址（sa地址或者临时通道）
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func bindCloud(area: Area, cloud_user_id: Int, url: String, saId: String? = nil, access_token: String, successCallback: ((BindCloudResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.bindCloud(area: area, cloud_user_id: cloud_user_id, url: url, sa_id: saId, access_token: access_token), modelType: BindCloudResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 家庭细节
    /// - Parameters:
    ///   - area_id: 家庭ID
    ///   - is_bind: 是否绑定
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func areaDetail(area: Area, successCallback: ((AreaDetailResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else {return}
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.areaDetail(area: area), modelType: AreaDetailResponse.self, successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    
    /// 房间列表
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func areaLocationsList(area: Area, successCallback: ((AreaLocationListResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.areaLocationsList(area: area), modelType: AreaLocationListResponse.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 设置房间顺序
    /// - Parameters:
    ///   - area: 家庭
    ///   — location_order： 排列顺序
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func setLocationOrders(area: Area, location_order: [Int], successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.setLocationOrders(area: area, location_order: location_order), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 房间详情
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func locationDetail(area: Area, id: Int, successCallback: ((Location) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.locationDetail(area: area, id: id), modelType: Location.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 更改房间名称
    /// - Parameters:
    ///   - area: 家庭
    ///   — name : 名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func changeLocationName(area: Area, id: Int,name: String, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.changeLocationName(area: area, id: id, name: name), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        }failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 更改家庭名称
    /// - Parameters:
    ///   - area: 家庭
    ///   — name : 名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func changeAreaName(area: Area, name: String, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.changeAreaName(area: area, name: name), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 删除房间
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func deleteLocation(area: Area, id: Int, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.deleteLocation(area: area, id: id ), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 删除家庭
    /// - Parameters:
    ///   - area: 家庭
    ///   - isDeleteDisk: 是否删除云盘数据
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func deleteArea(area: Area, isDeleteDisk: Bool, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.deleteArea(area: area, is_del_cloud_disk: isDeleteDisk), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 退出家庭
    /// - Parameters:
    ///   - area_id: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func quitArea(area: Area, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.quitArea(area: area), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
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
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.deviceList(type: type, area: area), modelType: DeviceListResponseModel.self, successCallback: successCallback, failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 扫描二维码
    /// - Parameters:
    ///   - area_id: 家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func scanQRCode(qr_code: String, url: String, nickname: String, successCallback: ((ScanResponse, _ isSAEnv: Bool, _ saId: String?, _ tempIp: String?) -> ())?, failureCallback: ((Int, String) -> ())?) {
        /// 通过jwt解码获取sa_id
        guard
            let decodedJWT = try? decodeJWT(jwtToken: qr_code),
            let saId = decodedJWT["sa_id"] as? String
        else {
            failureCallback?(-1, "解密jwt失败.")
            return
        }
        
        var token: String?
        
        if let cacheArea = AreaCache.areaList().filter({ $0.sa_id == saId }).last {
            token = cacheArea.sa_user_token
        }
        
        
        /// 检查SA在当前环境是否有响应
        AuthManager.shared.checkIfSAAvailable(addr: url) { [weak self] available in
            guard let self = self else { return }
            
            if available { /// 在SA环境
                /// 在SA环境默认走SA
                self.apiService.requestModel(.scanQRCode(qr_code: qr_code, url: url, nickname: nickname, token: token), modelType: ScanResponse.self, successCallback: { res in
                    successCallback?(res, true, saId, nil)
                    
                }, failureCallback: failureCallback)
            } else { /// 不在SA环境
                /// 家庭绑定了云端且已经登录的情况下走云临时通道
                if AuthManager.shared.isLogin {
                    /// 通过sa_id获取临时通道
                    ApiServiceManager.shared.requestTemporaryIP(sa_id: saId) { [weak self] tmpIp in
                        guard let self = self else { return }
                        /// 获取临时通道成功后请求扫码接口
                        self.apiService.requestModel(.scanQRCode(qr_code: qr_code, url: "\(tmpIp)", nickname: nickname, token: token), modelType: ScanResponse.self, successCallback: { res in
                            successCallback?(res, false, saId, "\(tmpIp)")
                        }, failureCallback: failureCallback)
                        
                    } failure: { code, err in
                        failureCallback?(-1, "获取临时通道失败.")
                    }
                    
                } else {
                    failureCallback?(-2, "请在局域网内扫描或登录后重新扫描.")
                }
            }
        }
        
    }
    
    /// 解密jwt
    /// - Parameter jwt: json web token
    /// - Throws: 解密抛出的错误
    /// - Returns: 解密结果
    private func decodeJWT(jwtToken jwt: String) throws -> [String: Any] {
        enum DecodeErrors: Error {
            case badToken
            case other
        }
        
        func base64Decode(_ base64: String) throws -> Data {
            let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
            guard let decoded = Data(base64Encoded: padded) else {
                throw DecodeErrors.badToken
            }
            return decoded
        }
        
        func decodeJWTPart(_ value: String) throws -> [String: Any] {
            let bodyData = try base64Decode(value)
            let json = try JSONSerialization.jsonObject(with: bodyData, options: [])
            guard let payload = json as? [String: Any] else {
                throw DecodeErrors.other
            }
            return payload
        }
        
        let segments = jwt.components(separatedBy: ".")
        return try decodeJWTPart(segments[1])
    }
    
    /// 获取二维码
    /// - Parameters:
    ///   - area_id: 家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func getInviteQRCode(area: Area, role_ids: [Int], successCallback: ((QRCodeResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else {return}
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.getInviteQRCode(area: area, role_ids: role_ids), modelType: QRCodeResponse.self, successCallback: successCallback, failureCallback: failureCallback)
            
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    
    
    /// 添加SA设备
    /// - Parameters:
    ///   - url: SA Url地址
    ///   - device: 设备信息
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func addSADevice(url: String, device: DiscoverDeviceModel, successCallback: ((AddDeviceResponseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.addSADevice(url: device.address, device: device), modelType: AddDeviceResponseModel.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 添加通过SA发现设备
    /// - Parameters:
    ///   - area: 家庭
    ///   - device: 设备信息
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func addDiscoverDevice(device: DiscoverDeviceModel, area: Area, successCallback: ((AddDeviceResponseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.addDiscoverDevice(device: device, area: area), modelType: AddDeviceResponseModel.self, successCallback: successCallback, failureCallback: failureCallback)
            
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 同步家庭信息
    /// - Parameters:
    ///   - SyncSAModel: 同步SA信息
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func syncArea(syncModel: SyncSAModel, url: String, token: String, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.syncArea(syncModel: syncModel, url: url, token: token), modelType: BaseModel.self, successCallback: successCallback, failureCallback: failureCallback)
        
    }
    
    /// 查看SA绑定情况
    /// - Parameters:
    ///   - url: SA的Url
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func checkSABindState(url: String, successCallback: ((SABindResponse) -> ())?, failureCallback: ((Int, String) -> ())? = nil) {
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
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.deviceDetail(area: area, device_id: device_id), modelType: DeviceInfoResponse.self, successCallback: successCallback, failureCallback: failureCallback)
            
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 删除设备
    /// - Parameters:
    ///   - area: 家庭
    ///   - device_id: 设备ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func deleteDevice(area: Area, device_id: Int, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.deleteDevice(area: area, device_id: device_id), modelType: BaseModel.self, successCallback: successCallback, failureCallback: failureCallback)
            
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
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
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.editDevice(area: area, device_id: device_id, name: name, location_id: location_id), modelType: BaseModel.self, successCallback: successCallback, failureCallback: failureCallback)
            
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    
    /// 添加房间
    /// - Parameters:
    ///   - area: 家庭
    ///   - name: 房间名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func addLocation(area: Area, name: String, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else {return}
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.addLocation(area: area, name: name), modelType: BaseModel.self, successCallback: successCallback, failureCallback: failureCallback)
            
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    func scopeList(area: Area, successCallback: ((ScopesListResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.scopeList(area: area), modelType: ScopesListResponse.self, successCallback: successCallback, failureCallback: failureCallback)
            
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 获取scopeToken
    /// - Parameters:
    ///   - area: 家庭
    ///   - scopes:
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func scopeToken(area: Area, scopes: [String], successCallback: ((ScopeTokenResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.scopeToken(area: area, scopes: scopes), modelType: ScopeTokenResponse.self, successCallback: successCallback, failureCallback: failureCallback)
            
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
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
        requestTemporaryIP(area: AuthManager.shared.currentArea) {[weak self] ip in
            guard let self = self else {return}
            //获取临时通道地址
            if ip != "" {
                AuthManager.shared.currentArea.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.editUser(user_id: user_id, nickname: nickname, account_name: account_name, password: password), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
        
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
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.userDetail(area: area, id: id), modelType: User.self, successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
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
        requestTemporaryIP(area: AuthManager.shared.currentArea) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                AuthManager.shared.currentArea.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.brands(name: name), modelType: BrandListResponseModel.self , successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 插件列表
    /// - Parameters:
    ///   - list_type: 0所有已添加插件 1开发者添加的插件（创作）
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    func plugins(list_type: Int, successCallback: ((PluginListResponseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: AuthManager.shared.currentArea) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                AuthManager.shared.currentArea.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.plugins(list_type: list_type), modelType: PluginListResponseModel.self , successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 插件详情
    /// - Parameters:
    ///   - id: 插件id
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调  
    func pluginDetail(id: String, successCallback: ((PluginDetailResponseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: AuthManager.shared.currentArea) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                AuthManager.shared.currentArea.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.pluginDetail(plugin_id: id, area: AuthManager.shared.currentArea), modelType: PluginDetailResponseModel.self , successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 通过id删除插件
    /// - Parameters:
    ///   - id: 插件id
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    func deletePluginById(id: String, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: AuthManager.shared.currentArea) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                AuthManager.shared.currentArea.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.deletePluginById(id: id), modelType: BaseModel.self , successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
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
        requestTemporaryIP(area: AuthManager.shared.currentArea) {[weak self] ip in
            guard let self = self else {return}
            //获取临时通道地址
            if ip != "" {
                AuthManager.shared.currentArea.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.brandDetail(name:name), modelType: BrandDetailResponse.self , successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 安装/更新插件
    /// - Parameters:
    ///   - name: 品牌名称
    ///   - plugins: 插件id数组
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    func installPlugin(name: String, plugins: [String], successCallback: ((PluginOperationResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: AuthManager.shared.currentArea) { [weak self] ip in
            guard let self = self else {return}
            //获取临时通道地址
            if ip != "" {
                AuthManager.shared.currentArea.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.installPlugin(area: AuthManager.shared.currentArea, name: name, plugins: plugins), modelType: PluginOperationResponse.self , successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 删除插件
    /// - Parameters:
    ///   - name: 品牌名称
    ///   - plugins: 插件id数组
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    func deletePlugin(name: String, plugins: [String], successCallback: ((PluginOperationResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: AuthManager.shared.currentArea) { [weak self] ip in
            guard let self = self else {return}
            //获取临时通道地址
            if ip != "" {
                AuthManager.shared.currentArea.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.deletePlugin(area: AuthManager.shared.currentArea, name: name, plugins: plugins), modelType: PluginOperationResponse.self , successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 用户权限
    /// - Parameters:
    ///   - area: 家庭
    ///   - user_id: 用户ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func rolesPermissions(area: Area, user_id: Int, successCallback: ((RolePermissionsResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.rolesPermissions(area: area, user_id: user_id), modelType: RolePermissionsResponse.self , successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 成员列表
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func memberList(area: Area, successCallback: ((MembersResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.memberList(area: area), modelType: MembersResponse.self , successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 角色列表
    /// - Parameters:
    ///   - area: 家庭
    ///   - user_id: 用户ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func rolesList(area: Area, successCallback: ((RoleListResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.rolesList(area: area), modelType: RoleListResponse.self ,successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    
    /// 删除成员
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func deleteMember(area: Area, id: Int, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.deleteMember(area: area, id: id), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 编辑成员
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func editMember(area: Area, id: Int, role_ids: [Int], successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.editMember(area: area, id: id, role_ids: role_ids), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    
    /// 转移拥有者
    /// - Parameters:
    ///   - area_id: 家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func transferOwner(area: Area, id: Int, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.transferOwner(area: area, id: id), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
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
    func sceneExecute(scene_id: Int, is_execute: Bool, area: Area = AuthManager.shared.currentArea, successCallback: ((isSuccessModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else {return}
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.sceneExecute(scene_id: scene_id, is_execute: is_execute, area: area), modelType: isSuccessModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 创建场景
    /// - Parameters:
    ///   - scene: 场景模型
    ///    - area_id：家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func createScene(scene: SceneDetailModel, area: Area = AuthManager.shared.currentArea, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else {return}
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.createScene(scene: scene, area: area), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 场景详情
    /// - Parameters:
    ///   - id: 场景ID
    ///    - area_id：家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func sceneDetail(id: Int, area: Area = AuthManager.shared.currentArea, successCallback: ((SceneDetailModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.sceneDetail(id: id, area: area), modelType: SceneDetailModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 删除场景
    /// - Parameters:
    ///   - id: 场景ID
    ///    - area_id：家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func deleteScene(id: Int, area: Area = AuthManager.shared.currentArea, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else {return}
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.deleteScene(id: id, area: area), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 编辑场景
    /// - Parameters:
    ///   - id: 场景ID
    ///   - scene: 场景模型
    ///    - area_id：家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func editScene(id: Int, scene: SceneDetailModel, area: Area = AuthManager.shared.currentArea, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.editScene(id: id, scene: scene, area: area), modelType: BaseModel.self, successCallback: successCallback,failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    /// 场景日志
    /// - Parameters:
    ///   - id: 场景ID
    ///   - scene: 场景模型
    ///    - area_id：家庭ID
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func sceneLogs(start: Int = 0, size: Int = 20, area: Area = AuthManager.shared.currentArea, successCallback: (([SceneHistoryMonthModel]) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestListModel(.sceneLogs(start: start, size: size, area: area), modelType: SceneHistoryMonthModel.self, successCallback: successCallback, failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        
    }
    
    //通过SC找回SA凭证
    func getSAToken(area:Area = AuthManager.shared.currentArea, successCallback: ((SATokenResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.getSAToken(area: area), modelType: SATokenResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 发现设备 - 通用设备类型
    /// - Parameters:
    ///   - page: 页码 不传默认查全部
    ///   - page_size: 每页记录数 不传默认全部
    ///   - pid: pid为0表示查询一级分类，填写一级分类id查询所属的二级分类
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    //    func commonDeviceTypeList(page: Int? = nil, page_size: Int? = nil, pid: Int = 0, successCallback: ((CommonDeviceTypeListResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
    //        apiService.requestModel(.commonDeviceTypeList(page: page, page_size: page_size, pid: pid), modelType: CommonDeviceTypeListResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    //    }
    
    /// 发现设备 - 通用设备类型
    /// - Parameters:
    ///   - page: 页码 不传默认查全部
    ///   - page_size: 每页记录数 不传默认全部
    ///   - pid: pid为0表示查询一级分类，填写一级分类id查询所属的二级分类
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    ///   - area: 当前家庭
    /// - Returns: nil
    func commonDeviceList(area: Area = AuthManager.shared.currentArea, successCallback: ((CommonDeviceTypeListResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.commonDeviceList(area: area), modelType: CommonDeviceTypeListResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 检测插件包更新
    /// - Parameters:
    ///   - id: 设备id
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    ///   - area: 当前家庭
    /// - Returns: nil
    func checkPluginUpdate(area: Area = AuthManager.shared.currentArea, id: String, successCallback: ((pluginResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        apiService.requestModel(.checkPluginUpdate(id: id, area: area), modelType: pluginResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// 获取设备accessToken
    func getDeviceAccessToken(successCallback: ((DeviceAccessTokenResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        self.apiService.requestModel(.getDeviceAccessToken, modelType: DeviceAccessTokenResponse.self, successCallback: successCallback, failureCallback: failureCallback)
            
        
    }
    
    /// 生成验证码
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func getCaptcha(area: Area, successCallback: ((captchaResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.getCaptcha(area: area), modelType: captchaResponse.self, successCallback: successCallback, failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 设置是否允许找回凭证
    /// - Parameters:
    ///   - area: 家庭
    ///   - tokenModel : token模型
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: nil
    func settingTokenAuth(area: Area,tokenModel: TokenAuthSettingModel, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            
            self.apiService.requestModel(.settingTokenAuth(area: area, tokenModel: tokenModel), modelType: BaseModel.self, successCallback: successCallback, failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }

    /// 检测当前软件版本
    ///   - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    func checkSoftwareUpdate(area: Area, successCallback: ((SoftwareUpdateResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
        guard let self = self else { return }
        //获取临时通道地址
        if ip != "" {
            area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
        }
        //请求结果
            self.apiService.requestModel(.checkSoftwareUpdate(area: area), modelType: SoftwareUpdateResponse.self, successCallback: successCallback, failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 升级软件到指定版本
    ///   - Parameters:
    ///   - area: 家庭
    ///   - version： 指定版本
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    func updateSoftware(area: Area, version: String, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
        guard let self = self else { return }
        //获取临时通道地址
        if ip != "" {
            area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
        }
        //请求结果
            self.apiService.requestModel(.updateSoftware(area: area, version: version), modelType: BaseModel.self, successCallback: successCallback, failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }

    /// 获取家庭迁移地址
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    func getMigrationUrl(area: Area,  successCallback: ((AreaMigrationResponse) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.migrationAddr(area: area), modelType: AreaMigrationResponse.self, successCallback: successCallback, failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }

    
    /// 迁移云端家庭到本地
    /// - Parameters:
    ///   - area: 本地家庭
    ///   - migration_url: 云端家庭迁移地址
    ///   - backup_file: 云端家庭的备份文件名
    ///   - sum: 备份文件的校验值
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    func migrateCloudToLocal(area: Area, migration_url: String, backup_file: String, sum: String, successCallback: ((BaseModel) -> ())?, failureCallback: ((Int, String) -> ())?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "\(temporarySchemeMode)://" + ip + "/api"
            }
            //请求结果
            self.apiService.requestModel(.migrationCloudToLocal(area: area, migration_url: migration_url, backup_file: backup_file, sum: sum), modelType: BaseModel.self, successCallback: successCallback, failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
        
}

/// 临时通道scheme
fileprivate var temporarySchemeMode: String { return "http" }

extension ApiServiceManager{
    
    
    //获取临时通道地址
    func requestTemporaryIP(area: Area, scheme: String = temporarySchemeMode, complete:( (String)->())?, failureCallback: ((Int, String) -> ())?) {
        //在局域网内则直接连接局域网
        if area.bssid == NetworkStateManager.shared.getWifiBSSID() && area.bssid != nil || !AuthManager.shared.isLogin {
            complete?("")
            return
        }
        //获取本地存储的临时通道地址
        let key = area.sa_user_token
        let temporaryJsonStr:String = UserDefaults.standard.value(forKey: key) as? String ?? ""
        let temporary = TemporaryResponse.deserialize(from: temporaryJsonStr)
        //验证是否过期，直接返回IP地址
        if let temporary = temporary {//有存储信息
            if timeInterval(fromTime: temporary.saveTime , second: temporary.expires_time) {
                //地址并未过期
                complete?(temporary.host)
                return
            }
        }
        
        //过期，请求服务器获取临时通道地址
        apiService.requestModel(.temporaryIP(area: area, scheme: scheme), modelType: TemporaryResponse.self) { response in
            //获取临时通道地址及有效时间,存储在本地
            //更新时间和密码
            let temporaryModel = TemporaryResponse()
            temporaryModel.host = response.host
            temporaryModel.expires_time = response.expires_time
            //当前时间
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            temporaryModel.saveTime = dateFormatter.string(from: Date())
            UserDefaults.standard.setValue(temporaryModel.toJSONString(prettyPrint:true), forKey: key)
            
            //返回ip地址
            complete?(response.host)
            
        } failureCallback: { code, error in
            failureCallback?(code,error)
        }
        
    }
    
    // 时间间隔
    private func timeInterval(fromTime: String , second: Int) -> Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //当前时间
        let time = dateFormatter.string(from: Date())
        //计算时间差
        let timeNumber = Int(dateFormatter.date(from: time)!.timeIntervalSince1970-dateFormatter.date(from: fromTime)!.timeIntervalSince1970)
        
        //        let timeInterval:CGFloat = CGFloat(timeNumber)/3600.0
        
        return second > timeNumber
    }
    
    
    //通过sa_id获取临时通道地址
    func requestTemporaryIP(sa_id: String, scheme: String = temporarySchemeMode, success: ((String) -> ())?, failure: ((Int, String) -> ())?) {

        /// 通过sa_id获取临时通道
        self.apiService.requestModel(.temporaryIPBySAID(sa_id: sa_id, scheme: temporarySchemeMode), modelType: TemporaryResponse.self) { response in
            success?("\(temporarySchemeMode)://\(response.host)")
            
        } failureCallback: { code, err in
            failure?(-1, "获取临时通道失败.")
        }
        
    }
    
}


