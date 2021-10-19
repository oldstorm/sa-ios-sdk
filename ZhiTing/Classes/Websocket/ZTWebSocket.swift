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
    
    /// publishers
    /// Socket连接成功publisher
    lazy var socketDidConnectedPublisher = PassthroughSubject<Void, Never>()
    /// SA发现设备publisher
    lazy var discoverDevicePublisher = PassthroughSubject<DiscoverDeviceModel, Never>()
    /// 设备状态\属性publisher
    lazy var deviceStatusPublisher = PassthroughSubject<DeviceStatusResponse, Never>()
    /// 设备状态改变publisher
    lazy var deviceStatusChangedPublisher = PassthroughSubject<DeviceStateChangeResponse, Never>()
    /// 插件安装回调publisher
    lazy var installPluginPublisher = PassthroughSubject<(plugin_id: String, success: Bool), Never>()
    /// 设备开关操作成功 publisher
    lazy var devicePowerPublisher = PassthroughSubject<(power: Bool, identity: String), Never>()
    /// 设置homekit设备pin码响应 publisher
    lazy var setHomekitCodePublisher = PassthroughSubject<(identity: String, success: Bool), Never>()

    init(urlString: String = "ws://") {
        var request = URLRequest(url: URL(string: urlString)!)
        request.timeoutInterval = 30
        socket = WebSocket(request: request)
        socket.delegate = self
        
    }

    

}

extension ZTWebSocket {
    func connect() {
        socket.connect()
    }

    func setUrl(urlString: String, token: String) {
        var request = URLRequest(url: URL(string: urlString)!)
        request.timeoutInterval = 30
        request.setValue(token, forHTTPHeaderField: "smart-assistant-token")
        
        /// 云端时websocket请求头带上对应家庭的id
        if AuthManager.shared.isLogin {
            request.setValue(AuthManager.shared.currentArea.id ?? "", forHTTPHeaderField: "Area-ID")
        }
        
        let pinner = FoundationSecurity(allowSelfSigned: true) // don't validate SSL certificates
        socket = WebSocket(request: request, certPinner: pinner)
        socket.delegate = self
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
        case discoverDevice(domain: String)
        
        /// 安装插件
        case installPlugin(plugin_id: String)
        
        /// 升级插件
        case updatePlugin(plugin_id: String)
        
        /// 移除插件
        case removePlugin(plugin_id: String)
        
        /// 获取设备属性
        case getDeviceAttributes(domain: String, identity: String)
        
        /// 控制设备开关
        case controlDevicePower(domain: String, identity: String, instance_id: Int, power: Bool)
        
        /// 设置设备homekit码
        case setDeviceHomeKitCode(domain: String, identity: String, instance_id: Int, code: String)

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
        let op: Operation
        let opType: OperationType
        switch operation {
        case .discoverDevice(let domain):
            op = Operation(domain: domain, id: id, service: "discover")
            opType = .discoverDevice(domain: domain)
            
        case .installPlugin(let plugin_id):
            op = Operation(domain: "plugin", id: id, service: "install")
            op.service_data = Operation.ServiceData()
            op.service_data?.plugin_id = plugin_id
            opType = .installPlugin(plugin_id: plugin_id)
            
        case .updatePlugin(let plugin_id):
            op = Operation(domain: "plugin", id: id, service: "install")
            op.service_data = Operation.ServiceData()
            op.service_data?.plugin_id = plugin_id
            opType = .updatePlugin(plugin_id: plugin_id)
            
        case .removePlugin(let plugin_id):
            op = Operation(domain: "plugin", id: id, service: "remove")
            op.service_data = Operation.ServiceData()
            op.service_data?.plugin_id = plugin_id
            opType = .removePlugin(plugin_id: plugin_id)
            
        case .getDeviceAttributes(let domain, let identity):
            op = Operation(domain: domain, id: id, service: "get_attributes")
            op.identity = identity
            opType = .getDeviceAttributes(domain: domain, identity: identity)
            

        case .controlDevicePower(let domain, let identity, let instance_id, let power):
            op = Operation(domain: domain, id: id, service: "set_attributes")
            op.identity = identity
            let attr = DeviceAttribute()
            attr.attribute = "power"
            attr.val = power ? "on" : "off"
            attr.instance_id = instance_id
            op.service_data = Operation.ServiceData()
            op.service_data?.attributes = [attr]
            
            opType = .controlDevicePower(domain: domain, identity: identity, instance_id: instance_id, power: power)

        case .setDeviceHomeKitCode(let domain, let identity, let instance_id, let code):
            op = Operation(domain: domain, id: id, service: "set_attributes")
            op.identity = identity
            let attr = DeviceAttribute()
            attr.attribute = "pin"
            attr.val = code
            attr.instance_id = instance_id
            op.service_data = Operation.ServiceData()
            op.service_data?.attributes = [attr]
            
            opType = .setDeviceHomeKitCode(domain: domain, identity: identity, instance_id: instance_id, code: code)
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
            socketDidConnectedPublisher.send()
        case .disconnected(let reason, let code):
            status = .disconnected
            wsLog("websocket is disconnected: \(reason) with code: \(code)")
            reconnect()
        case .text(let string):
            handleReceived(string: string)
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
    
    private func handleOperationResponse(jsonString: String, operationType: OperationType, operation: Operation) {
        switch operationType {
        case .discoverDevice:
            guard
                let response = WSOperationResponse<SearchDeviceResponse>.deserialize(from: jsonString),
                let device = response.result?.device
            else { return }
            
            discoverDevicePublisher.send(device)
            
        case .installPlugin:
            guard
                let response = WSOperationResponse<EmptyResultResponse>.deserialize(from: jsonString)
            else { return }
            
            if let pluginId = operation.service_data?.plugin_id {
                installPluginPublisher.send((plugin_id: pluginId, success: response.success))
            }
            
        case .updatePlugin:
            guard
                let response = WSOperationResponse<EmptyResultResponse>.deserialize(from: jsonString)
            else { return }
            
            if let pluginId = operation.service_data?.plugin_id {
                installPluginPublisher.send((plugin_id: pluginId, success: response.success))
            }
            
        case .removePlugin:
            break
            
        case .getDeviceAttributes:
            guard
                let response = WSOperationResponse<DeviceStatusResponse>.deserialize(from: jsonString),
                let result = response.result
            else { return }
            deviceStatusPublisher.send(result)

        case .controlDevicePower:
            guard
                let response = WSOperationResponse<BaseModel>.deserialize(from: jsonString),
                let powerStatus = operation.service_data?.attributes?.first?.val as? String,
                let identity = operation.identity
            else { return }
            if response.success == true {
                let power = powerStatus == "on"
                devicePowerPublisher.send((power, identity))
            }
            
            
            

        case .setDeviceHomeKitCode:
            guard
                let response = WSOperationResponse<BaseModel>.deserialize(from: jsonString),
                let identity = operation.identity
            else { return }
            setHomekitCodePublisher.send((identity, response.success))
        
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
            
            deviceStatusChangedPublisher.send(data)
            
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


