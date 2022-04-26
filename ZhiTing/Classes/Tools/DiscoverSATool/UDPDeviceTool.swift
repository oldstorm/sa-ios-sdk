//
//  ScanSATool.swift
//
//  Created by iMac on 2021/7/23.
//

import UIKit
import CocoaAsyncSocket
import Combine


final class UDPDeviceTool: NSObject {
    /// 发送的包类型
    enum OperationType {
        /// 获取设备信息
        case getDeviceInfo
        /// 设置设备服务器
        case setServer(_ server: String, _ port: Int)
    }
    
    var identifier = "default"

    /// sa的发布者
    var saPubliser = PassthroughSubject<DiscoverSAModel, Never>()

    /// 默认端口
    private var portNumber: UInt16 = 54321
    
    /// GCDAsyncUdpSocket
    private var udpSocket: GCDAsyncUdpSocket?
    
    /// 发现的设备 [设备id: 设备]
    private var devices = [String: UDPDevice]()
    
    /// 正在搜索的设备ID
    var searchingDeviceID: String?
    
    /// 搜索到指定id设备的发布者
    var deviceSearchedPubliser = PassthroughSubject<UDPDevice, Never>()
    
    /// 设备设置服务器结果发布者
    var deviceSetServerPublisher = PassthroughSubject<Bool, Never>()

    /// 消息id
    lazy var id = 0
    
    /// id: OperationType
    lazy var operationDict = [Int: OperationType]()
    
    override init() {
        super.init()
        setupUDPSocket(port: portNumber)
    }

    convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
    }

    deinit {
        udpSocket?.close()
        print("ScanSATool deinit.")
    }
    
    /// 建立UDPSocket
    /// - Parameter port: 绑定的端口号
    private func setupUDPSocket(port: UInt16) {
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: .main)
        do {
            try udpSocket?.enableReusePort(true)
            try udpSocket?.enableBroadcast(true)
            try udpSocket?.bind(toPort: port)
            
            portNumber = port
        } catch {
            
            print("error happens when setting up UDPSocket")
            print("\(error.localizedDescription)")
        }

    }
    
    
    /// 开始扫描发现
    /// - Parameter notifyDeviceID: 扫描到指定ID的设备会通知订阅者
    func beginScan(notifyDeviceID: String? = nil) throws {
        searchingDeviceID = notifyDeviceID
        print("开始UDP扫描")
        cleanDevices()
        try udpSocket?.beginReceiving()
        sendHello()
    }
    
    /// 停止扫描发现
    func stopScan() {
        print("停止UDP扫描")
        udpSocket?.pauseReceiving()
        cleanDevices()
    }
    
    /// 发送hello包
    private func sendHello() {
        let helloDatagram: [UInt8] = [0x21, 0x31, 0x00, 0x20, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
        
        let data = Data(helloDatagram)
        
        udpSocket?.send(data, toHost: "255.255.255.255", port: portNumber, withTimeout: -1, tag: 0)
    }
    
    /// 发送点对点包请求设备token
    /// - Parameter device: 设备
    private func requestDeviceToken(device: UDPDevice) {
        /// header - 包头
        let headBytes: [UInt8] = [0x21, 0x31]
        
        /// header - key部分
        let keyData: Data
        if let key = device.key { /// 如果设备已有key
            guard let data = key.data(using: .utf8) else { return }
            keyData = data
        } else { /// 如果设备没有key,随机生成16位key
            
            let key = randomString(length: 16)
            guard let data = key.data(using: .utf8) else { return }
            keyData = data
            device.key = key
            
        }
        
        
        /// header - 序列号部分
        let serialData: [UInt8] = [0x00, 0x00, 0x00, 0x00]
        
        /// header - 预留部分
        let reserveBytes: [UInt8] = [0xff, 0xfe]
        
        /// header - 设备ID
        let deviceidBytes = device.id.hexaBytes

        /// header - 包长度
        let lengthBytes = withUnsafeBytes(of: Int16(32).bigEndian) {
            Data($0)
        }
        
        /// 包头    包长    预留    设备ID    序列号    MD5校验(key)    body
        
        let data1 = Data(headBytes + lengthBytes + reserveBytes)
        let data2 = Data(deviceidBytes + serialData)
        let headerData = data1 + data2 + keyData

        
        udpSocket?.send(headerData, toHost: device.host, port: device.port, withTimeout: -1, tag: 0)
    }
    
    
    
    /// 获取设备信息
    /// - Parameter device: 设备
    private func getDeviceInfo(device: UDPDevice) {
        /// 要有设备token才能进行操作
        guard let token = device.token else { return }

        /// header - 包头
        let headBytes: [UInt8] = [0x21, 0x31]
        
        /// header - key部分
        let keyBytes: [UInt8]
        if let key = device.key { /// 如果设备已有key
            guard let keyData = key.data(using: .utf8) else { return }
            keyBytes = Array(keyData)
        } else { /// 如果设备没有key,随机生成16位key
            return
        }
        
        
        /// header - 序列号部分
        let serialData: [UInt8] = [0x00, 0x00, 0x00, 0x00]
        
        /// header - 预留部分
        let reserveBytes: [UInt8] = [0x00, 0x00]
        
        /// header - 设备ID
        let deviceidBytes = device.id.hexaBytes

        /// body部分
        let bodyJSON = """
            {"method":"get_prop.info","params":[],"id":\(id)}
            """
        
        operationDict[id] = .getDeviceInfo
        id += 1
        
        /// 利用设备token加密数据
        guard let bodyData = bodyJSON.data(using: .utf8),
              let encryptedBodyData = UDPAesUtil.encrypt(bodyData, by: token)
        else {
            return
        }
        
        
        
        /// header - 包长度
        let lengthBytes = withUnsafeBytes(of: Int16(32 + encryptedBodyData.count).bigEndian) {
            Data($0)
        }
        
        /// 包头    包长    预留    设备ID    序列号    MD5校验(key)    body
        
        let data1 = Data(headBytes + lengthBytes + reserveBytes)
        let data2 = Data(deviceidBytes + serialData + keyBytes)
        let headerData = data1 + data2
        
        
        let data = headerData + encryptedBodyData
        
        udpSocket?.send(data, toHost: device.host, port: device.port, withTimeout: -1, tag: 0)
    }
    
    
    /// 将设备连接至SC
    /// - Parameter device: 设备
    /// - Parameter areaId: sc家庭id
    /// - Parameter accessToken: 家庭入网信息返回的token
    /// - Parameter server: 接入的云端服务器地址
    /// - Parameter port: 接入的云端服务器端口
    /// - Parameter protocol: 设备连接云端时使用的协议
    func connectDeviceToSC(device: UDPDevice, areaId: String, accessToken: String, server: String = cloudUrl, port: Int = 54321, protocol: String? = nil) {
        /// 设备要有token才能继续操作
        guard let token = device.token else { return }
        /// 设备要有key才能继续操作
        guard let key = device.key, let keyData = key.data(using: .utf8) else { return }
        
        guard let server = server.components(separatedBy: "https://").last else { return }

        /// header - 包头
        let headBytes: [UInt8] = [0x21, 0x31]
        
        /// header - key部分
        let keyBytes = Array(keyData)
        
        
        /// header - 序列号部分
        let serialData: [UInt8] = [0x00, 0x00, 0x00, 0x00]
        
        /// header - 预留部分
        let reserveBytes: [UInt8] = [0x00, 0x00]
        
        /// header - 设备ID
        let deviceidBytes = device.id.hexaBytes

        /// body部分
        var bodyJSON = """
            {"method":"set_prop.server","params":{"server":"\(server)","port":\(port),"access_token":"\(accessToken)","area_id": \"\(areaId)\"
            },"id": \(id)}
            """
        
        if `protocol` == "mqtt" {
            /// scgz.zhitingtech.com:1883
            let mqtt_server = (server.components(separatedBy: "//").last ?? server) + ":1883"

            bodyJSON = """
                {"method":"set_prop.server","params":{"server":"\(server)","port":\(port),"access_token":"\(accessToken)","area_id": \"\(areaId)\","mode":"cloud","mqtt_server":"\(mqtt_server)","mqtt_password":""
                },"id": \(id)}
                """
        }
        
        /// 利用设备token加密数据
        guard let bodyData = bodyJSON.data(using: .utf8),
              let encryptedBodyData = UDPAesUtil.encrypt(bodyData, by: token)
        else {
            return
        }
        
        
        
        /// header - 包长度
        let lengthBytes = withUnsafeBytes(of: Int16(32 + encryptedBodyData.count).bigEndian) {
            Data($0)
        }
        
        /// 包头    包长    预留    设备ID    序列号    MD5校验(key)    body
        
        let data1 = Data(headBytes + lengthBytes + reserveBytes)
        let data2 = Data(deviceidBytes + serialData + keyBytes)
        let headerData = data1 + data2
        
        
        let data = headerData + encryptedBodyData
        
        operationDict[id] = .setServer(server, port)
        id += 1
        
        udpSocket?.send(data, toHost: device.host, port: device.port, withTimeout: -1, tag: 0)
    }


    
    /// 生成指导长度随机字符串
    /// - Parameter length: 长度
    /// - Returns: 随机字符串
    private func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    
    /// 清除所有已发现设备
    private func cleanDevices() {
        id = 0
        devices.removeAll()
    }
    

}

extension UDPDeviceTool: GCDAsyncUdpSocketDelegate {

    /// 接收到数据包
    /// - Parameters:
    ///   - sock: GCDAsyncUdpSocket
    ///   - data: 数据包
    ///   - address: 地址
    ///   - filterContext: 用于过滤的上下文
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        var addrStr: NSString? = nil
        var port: UInt16 = 0

        GCDAsyncUdpSocket.getHost(&addrStr, port: &port, fromAddress: address)
        guard let addStr = addrStr,
              let addr = addStr.components(separatedBy: ":").last,
              port == portNumber // 过滤无关端口响应的数据包
        else {
            return
        }
        
        print("------- UDPDeviceTool identifier -------")
        print("\(identifier)")
        print("------- data from -------")
        print("\(addr):\(port)")

        
        print("-------receive udp data-------")
        let receive = Array(data)
            .map { "0x\(String($0, radix: 16, uppercase: true))"}
            .joined(separator: ", ")
            .replacingOccurrences(of: "\"", with: "")
        
        print("\(receive)")
        

        
        /// 字节数组
        let dataArray = Array(data)
        /// 至少32个字节
        guard dataArray.count >= 32 else {
            return
        }

        
        /// 数据包解包
        /// -------
        /// 包头部分
        
        /// 包头：（2个字节）
        /// 其内容固定为0x21 0x31
        if dataArray[0] != 0x21 || dataArray[1] != 0x31 {
            return
        }
        
        /// 包长：（2个字节）
        /// 包长包含整个数据包内容，包括数据前导
        let lengthData = Data(dataArray[2...3])
        /// 字节转Int16
        let int16Length = lengthData.withUnsafeBytes { ptr in
            ptr.load(as: Int16.self)
        }
        /// Int16大端字节流转Int
        let length = Int(int16Length.bigEndian)
        print("包长度: \(length)")
        guard length >= 32 else {
            print("数据包长度小于32")
            return
        }
        
        
        
        /// 预留：（2个字节）
        /// 此值一直为0，对于hello数据包则其数据填充为0Xffff。下发TOKEN加密钥，其值为0Xfffe
        let reserveData = Data(dataArray[4...5])
        print("预留字节: \(reserveData.toHexString())")
//        if reserveData.toHexString() == "ffff" { /// 过滤掉hello包
//            print("数据包为设备hello响应包")
//            return
//        }
//
        /// 设备ID：（4个字节）
        /// 设备唯一序列号，用与硬件设备相关唯一信息做绑定。如MAC; 对于”Hello”广播数据包则内容填充0Xffffffffffff，点对点则填充相应设备ID
        let deviceIdData = Data(dataArray[6...11])
        let deviceId = deviceIdData.toHexString()
        print("设备ID: \(deviceId)")
        
        if searchingDeviceID != nil && searchingDeviceID != deviceId { // 搜索设备时直接过滤无关设备
            return
        }
        
        /// 若是新设备则加入到发现设备列表中
        if devices[deviceId] == nil {
            let device = UDPDevice(id: deviceId, host: addr, port: port)
            devices[deviceId] = device
            /// 获取设备token
            requestDeviceToken(device: device)
            return
        }

        /// 序列号：（4个字节）
        /// 序列号，由发送一方生成（每包数据的序列不同），接收一方回复时，消息需与收到信息的序列号一致
        
        /// MD5校验：（16个字节）
        /// 计算整个数据包，包括MD5 字段本身，必须用 0 初始化。TOKEN密钥则填充其上报密钥内容
        
        
        /// -------
        /// body部分
        /// 有效数据 ：（包长-32个字节）
        /// 此数据采用AES-128加密方式。可变大小的数据负载使用高级加密进行加密标准 (AES)。 128 位密钥和初始化向量均来自令牌如下：
        ///
        /// 密钥 = MD5（令牌）
        ///
        /// IV = MD5(密钥 + 令牌)
        ///
        /// 在加密之前使用 PKCS#7 填充。操作模式是密码块链（CBC）。
        ///
        /// 此字段采用CJSON格式，如：
        ///
        /// {
        ///      "id": XXX,
        ///       "method": "prop.config_router",
        ///       "params": {
        ///         "ssid": "WiFi network",
        ///         "passwd": "WiFi password",
        ///         "uid": "YYY"
        ///       }
        /// }
        

        guard dataArray.count > 32 else {
            print("数据包body: nil")
            return
        }
        
        guard let device = devices[deviceId] else { return }
        
        /// 获取设备token
        guard let key = device.key else {
            requestDeviceToken(device: device)
            return
        }

        let bodyLength = length - 32
        /// 数据包body部分
        let bodyData = Data(dataArray[32..<(32 + bodyLength)])
        
        
        /// 如果设备token为空,默认收到的数据包为加密后的设备token
        if device.token == nil {
            /// 解密后的设备token
            guard let decryptedToken = UDPAesUtil.decryptToken(bodyData, key: key) else { return }
            device.token = decryptedToken
            /// 获取设备信息
            getDeviceInfo(device: device)
            return
        }

        /// 通过设备token解密body数据
        guard
            let token = device.token,
            let decryptedBodyData = UDPAesUtil.decrypt(bodyData, by: token),
            let jsonStr = String(data: decryptedBodyData, encoding: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: decryptedBodyData, options: .mutableContainers) as? [String: Any],
            let msgId = dict["id"] as? Int
        else {
            print(bodyData.toHexString())
            print("failed to unwrap json string.")
            return
        }
        

        print("数据包解密后body: ")

        guard let type = operationDict[msgId] else { return }
        
        switch type {
        /// 获取设备信息
        case .getDeviceInfo:
            guard let response = UDPDeviceResponse<UDPDeviceInfo>.deserialize(from: jsonStr) else {
                print("获取设备信息json解析错误")
                return
            }
            print(response.toJSONString() ?? "")
            device.info = response.result
            /// 如果发现的设备是SA，通过saPubliser发布给订阅者
            if let info = device.info, info.model.hasPrefix("MH-SA") {
                let sa = DiscoverSAModel()
                let name = "SA " + (info.sa_id ?? "")
                sa.name = name
                sa.model = info.model
                let saPort = info.port ?? "37965"
                /// SA请求地址
                sa.address = "http://\(device.host):\(saPort)"
                sa.sw_version = info.sw_ver ?? ""
                sa.sa_id = info.sa_id
                saPubliser.send(sa)
                
                /// 更新本地sa家庭的sa地址
                let areas = AreaCache.areaList()
                areas.forEach { area in
                    /// 如果本地对应的sa家庭的地址发生改变 则更新本地sa家庭的地址
                    if area.sa_id == info.sa_id
                        && info.sa_id != nil
                        && (area.sa_lan_address != sa.address || area.bssid != NetworkStateManager.shared.getWifiBSSID()) {
                    
                        /// 更新家庭的sa地址
                        area.sa_lan_address = sa.address
                        area.ssid = NetworkStateManager.shared.getWifiSSID()
                        area.bssid = NetworkStateManager.shared.getWifiBSSID()
                        AreaCache.cacheArea(areaCache: area.toAreaCache())

                        /// 如果更新的家庭是当前家庭,更新后触发一下切换到当前家庭
                        if AuthManager.shared.currentArea.sa_id == area.sa_id {
                            AuthManager.shared.currentArea = area
                        }
                        
                        let obj = area.toJSONString()
                        NotificationCenter.default.post(name: .init(rawValue: "AreaUpdate"), object: obj)
                        print("更新了家庭sa地址")
                    }
                }

            }
            
            /// 如果发现的设备是 搜索指定ID的设备, 通过deviceSearchedPubliser发布给订阅者
            if deviceId == searchingDeviceID {
                if let searched = devices[deviceId] {
                    deviceSearchedPubliser.send(searched)
                }
            }
            
        /// 设置设备服务器
        case .setServer(let server, let port):
            guard let response = UDPDeviceResponse<UDPDeviceServerResult>.deserialize(from: jsonStr) else {
                print("设置设备服务器json解析错误")
                return
            }
            print(response.toJSONString() ?? "")
            
            guard let resultServer = response.result?.server, let resultPort = response.result?.port else {
                print("设置设备服务器失败")
                deviceSetServerPublisher.send(false)
                return
            }
            
            /// 判断设置的服务器和返回的服务器是否一致（是否设置成功）

            if server == resultServer && port == resultPort {
                print("设置设备服务器成功")
                deviceSetServerPublisher.send(true)
                
            } else {
                print("设置设备服务器失败")
                deviceSetServerPublisher.send(false)
                
            }
            
            
        }

        
            
        
        
        
    }
    
}


/// 用于特定时刻触发 发现SA设备流程(更新家庭SA地址)
fileprivate var scanSATool: UDPDeviceTool?
extension UDPDeviceTool {
    static func updateAreaSAAddress(force: Bool = false) {
        if scanSATool != nil || (NetworkStateManager.shared.getWifiBSSID() == nil && !force) { // 如果对象已存在直接返回(说明可能正在扫描中) 或 不在局域网内
            return
        }
        scanSATool = UDPDeviceTool(identifier: "updateSA_Address")
        print("尝试搜索发现SA")
        
        DispatchQueue.global().async {
            try? scanSATool?.beginScan()
            /// 扫描5s后销毁对象
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                scanSATool = nil
            }
        }
        
        

    }
    
    static func stopUpdateAreaSAAddress() {
        scanSATool = nil
    }
    
    
}
