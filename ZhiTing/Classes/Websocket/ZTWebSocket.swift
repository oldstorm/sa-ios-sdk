//
//  ZTWebSocket.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit
import Starscream
import Combine


/// Websocket connect status
enum WebsocketConnectStatus {
    case connected
    case disconnected
}


class ZTWebSocket {
    /// websocket
    private var socket: WebSocket!
    /// 当前连接的地址
    var currentAddress: String?

    /// connectStatus
    var status: WebsocketConnectStatus = .disconnected
    /// autoInrecement id (use for record operations)
    lazy var id = 0
    /// id: (Operation, OperationType)
    lazy var operationDict = [Int: (op: Operation, opType: OperationType)]()
    /// 重连次数
    lazy var reconnectCount = 0
    /// 最大重连次数
    let maxReconnectCount = 6
    /// 是否打印日志
    var printDebugInfo = true
    
    /// 提供给h5调用的websocket相关回调
    /// 监听 WebSocket 连接打开事件
    var h5_onSocketOpenCallback: (() -> ())?
    /// 监听 WebSocket 接受到服务器的消息事件
    var h5_onSocketMessageCallback: ((String) -> ())?
    /// 监听 WebSocket 错误事件
    var h5_onSocketErrorCallback: ((String) -> ())?
    /// 监听 WebSocket 连接关闭事件
    var h5_onSocketCloseCallback: ((String) -> ())?
    
    /// publishers
    /// Socket连接成功publisher
    private lazy var _socketDidConnectedPublisher = PassthroughSubject<Void, Never>()
    /// SA发现设备publisher
    private lazy var _discoverDevicePublisher = PassthroughSubject<DiscoverDeviceModel, Never>()
    /// 设备状态\属性publisher
    private lazy var _deviceStatusPublisher = PassthroughSubject<(status: DeviceStatusModel, success: Bool), Never>()
    /// 设备状态改变publisher
    private lazy var _deviceStatusChangedPublisher = PassthroughSubject<DeviceStateChangeResponse, Never>()
    /// 插件安装回调publisher
    private lazy var _installPluginPublisher = PassthroughSubject<(plugin_id: String, success: Bool), Never>()
    /// 添加设备响应 publiser
    private lazy var _connectDevicePublisher = PassthroughSubject<(iid: String, response: WSOperationResponse<DeviceStatusModel>), Never>()
    /// 删除设备响应 publiser
    private lazy var _disconnectDevicePublisher = PassthroughSubject<(iid: String, success: Bool, error: WSOperationError?), Never>()


    init(urlString: String = "ws://") {
        var request = URLRequest(url: URL(string: urlString)!)
        request.timeoutInterval = 30
        socket = WebSocket(request: request)
        socket.delegate = self
        
    }
    
    deinit {
        debugPrint("ztwebsocket deinit.")
    }

    

}

/// 对外暴露的publishers
extension ZTWebSocket {
    var socketDidConnectedPublisher: AnyPublisher<Void, Never> {
        _socketDidConnectedPublisher.eraseToAnyPublisher()
    }
    
    var discoverDevicePublisher: AnyPublisher<DiscoverDeviceModel, Never> {
        _discoverDevicePublisher.eraseToAnyPublisher()
    }
    
    var deviceStatusPublisher: AnyPublisher<(status: DeviceStatusModel, success: Bool), Never> {
        _deviceStatusPublisher.eraseToAnyPublisher()
    }
    
    var deviceStatusChangedPublisher: AnyPublisher<DeviceStateChangeResponse, Never> {
        _deviceStatusChangedPublisher.eraseToAnyPublisher()
    }
    
    var installPluginPublisher: AnyPublisher<(plugin_id: String, success: Bool), Never> {
        _installPluginPublisher.eraseToAnyPublisher()
    }
    
    var connectDevicePublisher: AnyPublisher<(iid: String, response: WSOperationResponse<DeviceStatusModel>), Never> {
        _connectDevicePublisher.eraseToAnyPublisher()
    }
    
    var disconnectDevicePublisher: AnyPublisher<(iid: String, success: Bool, error: WSOperationError?), Never> {
        _disconnectDevicePublisher.eraseToAnyPublisher()
    }
}

extension ZTWebSocket {
    func connect() {
        socket.connect()
    }
    
    /// 设置websocket连接
    /// - Parameters:
    ///   - urlString: 地址
    ///   - token: 家庭token
    func setUrl(urlString: String, token: String) {
        var request = URLRequest(url: URL(string: urlString)!)
        request.timeoutInterval = 30
        request.setValue(token, forHTTPHeaderField: "smart-assistant-token")
        
        currentAddress = urlString
        
        /// 云端时websocket请求头带上对应家庭的id
        if UserManager.shared.isLogin {
            request.setValue(AuthManager.shared.currentArea.id ?? "", forHTTPHeaderField: "Area-ID")
        }
        
        let pinner = FoundationSecurity(allowSelfSigned: true) // don't validate SSL certificates
        socket = WebSocket(request: request, certPinner: pinner)
        socket.delegate = self
    }
    
    /// 设置websocket连接
    /// - Parameters:
    ///   - urlString: 地址
    ///   - headers: headers
    func setUrl(urlString: String, headers: [String: Any]) {
        var request = URLRequest(url: URL(string: urlString)!)
        request.timeoutInterval = 30
        headers.keys.forEach { key in
            request.setValue("\(headers[key] ?? "")", forHTTPHeaderField: key)
        }
        currentAddress = urlString
        
        
        let pinner = FoundationSecurity(allowSelfSigned: true) // don't validate SSL certificates
        socket = WebSocket(request: request, certPinner: pinner)
        socket.delegate = self
    }
    
    func writeString(str: String) {
        socket.write(string: str, completion: nil)
    }

    func disconnect() {
        socket.disconnect()
    }
}

// MARK: - OperationType & EventType
extension ZTWebSocket {
    /// 操作指令
    enum OperationType {
        /// SA发现设备
        case discoverDevice
        
        /// 连接设备
        case connectDevice(domain: String, iid: String, auth_params: [String: Any]? = nil)

        /// 断开连接/删除设备
        case disconnectDevice(domain: String, iid: String)

        /// 安装插件
        case installPlugin(plugin_id: String)
        
        /// 升级插件
        case updatePlugin(plugin_id: String)
        
        /// 移除插件
        case removePlugin(plugin_id: String)
        
        /// 获取设备属性
        case getDeviceAttributes(domain: String, iid: String)
        
        /// 控制设备开关
        case controlDevicePower(domain: String, iid: String?, aid: Int?, power: Bool)
        

    }

    enum EventType: String {
        /// 收到设备状态变化
        case attribute_change
        
    }
    
}



// MARK: - ExcueteOperations
extension ZTWebSocket {
    /// execute operation
    /// - Parameter operation: operation type
    /// - Returns: nil
    func executeOperation(operation: OperationType) {
        let op: Operation<BaseModel>
        let opType: OperationType
        switch operation {
        case .discoverDevice:
            op = Operation(id: id, service: "discover")
            opType = .discoverDevice
            
        case .connectDevice(let domain, let iid, let auth_params):
            op = Operation(domain: domain, id: id, service: "connect")
            opType = .connectDevice(domain: domain, iid: iid, auth_params: auth_params)
            let data = Operation.ConnectDeviceServiceData()
            data.iid = iid
            if let auth_params = auth_params {
                data.auth_params = auth_params
            }
            op.data = data
            
        case .disconnectDevice(let domain, let iid):
            op = Operation(domain: domain, id: id, service: "disconnect")
            opType = .disconnectDevice(domain: domain, iid: iid)
            let data = Operation.AttributesServiceData()
            data.iid = iid
            op.data = data

        case .installPlugin(let plugin_id):
            op = Operation(domain: "plugin", id: id, service: "install")
            let data = Operation.PluginServiceData()
            data.plugin_id = plugin_id
            op.data = data
            opType = .installPlugin(plugin_id: plugin_id)
            
        case .updatePlugin(let plugin_id):
            op = Operation(domain: "plugin", id: id, service: "install")
            let data = Operation.PluginServiceData()
            data.plugin_id = plugin_id
            op.data = data
            opType = .updatePlugin(plugin_id: plugin_id)
            
        case .removePlugin(let plugin_id):
            op = Operation(domain: "plugin", id: id, service: "remove")
            let data = Operation.PluginServiceData()
            data.plugin_id = plugin_id
            op.data = data
            opType = .removePlugin(plugin_id: plugin_id)
            
        case .getDeviceAttributes(let domain, let iid):
            op = Operation(domain: domain, id: id, service: "get_instances")
            let data = Operation.AttributesServiceData()
            data.iid = iid
            op.data = data
            opType = .getDeviceAttributes(domain: domain, iid: iid)
            

        case .controlDevicePower(let domain, let iid, let aid, let power):
            op = Operation(domain: domain, id: id, service: "set_attributes")
            let attr = DeviceAttribute()
            attr.val = power ? "on" : "off"
            attr.iid = iid
            attr.aid = aid
            
            let data = Operation.AttributesServiceData()
            data.attributes = [attr]
            op.data = data
            
            opType = .controlDevicePower(domain: domain, iid: iid, aid: aid, power: power)
        }
        
        
        if let data = op.toData() {
            operationDict[id] = (op, opType)
            id += 1
            
            socket.write(data: data)
            wsLog("operation executed.\n\(op.toJSONString(prettyPrint: true) ?? "")")
        }
    }


    
}

// MARK: - WebSocketDelegate
extension ZTWebSocket: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            status = .connected
            wsLog("websocket is connected: \(headers)")
            reconnectCount = 0
            _socketDidConnectedPublisher.send()
            h5_onSocketOpenCallback?()
        case .disconnected(let reason, let code):
            status = .disconnected
            wsLog("websocket is disconnected: \(reason) with code: \(code)")
            reconnect()
            h5_onSocketCloseCallback?(reason)
        case .text(let string):
            handleReceived(string: string)
            h5_onSocketMessageCallback?(string)
        case .binary(let data):
            wsLog("Received data: \(data.count) \n \(String(data: data, encoding: .utf8) ?? "")")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            reconnect()
        case .cancelled:
            break
        case .error(let error):
            status = .disconnected
            h5_onSocketErrorCallback?(error?.localizedDescription ?? "unkown error")
            handleError(error)
            reconnect()
        }
    }
    
    private func reconnect() {
        id = 0
        operationDict.removeAll()
        
        if reconnectCount > maxReconnectCount {
            return
        }
        
        reconnectCount += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            if self.status == .disconnected && AuthManager.shared.isSAEnviroment {
                self.socket.connect()
            }
        }
    }
    
    private func handleError(_ error: Error?) {
        if let e = error as? WSError {
            wsLog("websocket encountered an error: \(e.message)")
        } else {
            wsLog("websocket encountered an error \(String(describing: error?.localizedDescription))")
        }
    }
    

    
}

// MARK: - Response Handler
extension ZTWebSocket {
    private func handleReceived(string: String) {
        wsLog("\(string)")
        
        guard
            let data = string.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
        else {
            wsLog("failed to transform operation data to json.")
            return
        }
        
        /// operation response
        if let id = dict["id"] as? Int,
           let opType = operationDict[id]?.opType,
           let op = operationDict[id]?.op {
            handleOperationResponse(jsonString: string, operationType: opType, operation: op)
        }
        
        /// event response
        if let eventType = dict["event_type"] as? String, let type = EventType(rawValue: eventType) {
            handleEventResponse(type: type, jsonString: string)
        }
        
    }
    
    private func handleOperationResponse(jsonString: String, operationType: OperationType, operation: Operation<BaseModel>) {
        switch operationType {
        case .discoverDevice:
            guard
                let response = WSOperationResponse<SearchDeviceResponse>.deserialize(from: jsonString),
                let device = response.data?.device
            else { return }
            
            _discoverDevicePublisher.send(device)
            
        case .connectDevice(_, let iid, _):
            guard
                let response = WSOperationResponse<DeviceStatusModel>.deserialize(from: jsonString)
            else { return }
            
            _connectDevicePublisher.send((iid, response: response))
            
        case .disconnectDevice(_, let iid):
            guard
                let response = WSOperationResponse<BaseModel>.deserialize(from: jsonString)
            else { return }
            
            _disconnectDevicePublisher.send((iid, response.success, response.error))
            
        case .installPlugin:
            guard
                let response = WSOperationResponse<EmptyResultResponse>.deserialize(from: jsonString)
            else { return }
            
            if let operation = operation.data as? Operation.PluginServiceData, let pluginId = operation.plugin_id {
                _installPluginPublisher.send((plugin_id: pluginId, success: response.success))
            }
            
        case .updatePlugin:
            guard
                let response = WSOperationResponse<EmptyResultResponse>.deserialize(from: jsonString)
            else { return }
            
            if let operation = operation.data as? Operation.PluginServiceData, let pluginId = operation.plugin_id {
                _installPluginPublisher.send((plugin_id: pluginId, success: response.success))
            }
            
        case .removePlugin:
            break
            
        case .getDeviceAttributes(_, let iid):
            guard
                let response = WSOperationResponse<DeviceStatusModel>.deserialize(from: jsonString),
                let result = response.data
            else { return }
            
            response.data?.iid = iid
            _deviceStatusPublisher.send((status: result, success: response.success))

        case .controlDevicePower:
            break
            
        }
    }
    
    
    
    private func handleEventResponse(type: EventType, jsonString: String) {
        switch type {
        case .attribute_change:
            guard
                let response = WSEventResponse<DeviceStateChangeResponse>.deserialize(from: jsonString),
                let data = response.data
            else {
                return
                
            }
            
            _deviceStatusChangedPublisher.send(data)
            
        }
    }
    
}


// MARK: - Helper
extension ZTWebSocket {
    private func wsLog(_ item: Any) {
        if !printDebugInfo {
            return
        }
        print("------------------------< WebSocketLog >-----------------------------------")
        print("[\(socket.request.url?.absoluteString ?? "")]")
        print("---------------------------------------------------------------------------")
        print(Date())
        print("---------------------------------------------------------------------------")
        print(item)
        print("---------------------------------------------------------------------------\n\n")
        
    }
    
    private func mapDataToModel<T: HandyJSON>(data: Data, type: T.Type) -> WSOperationResponse<T>? {
        let jsonString = String(data: data, encoding: .utf8)
        let model = WSOperationResponse<T>.deserialize(from: jsonString)
        return model
    }
}


