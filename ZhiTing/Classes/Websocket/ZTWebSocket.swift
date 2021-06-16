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
    
    /// publishers
    lazy var socketDidConnectedPublisher = PassthroughSubject<Void, Never>()
    lazy var discoverDevicePublisher = PassthroughSubject<DiscoverDeviceModel, Never>()
    lazy var deviceStatusPublisher = PassthroughSubject<( operation_id: Int, is_online: Bool, power: Bool), Never>()
    lazy var deviceStatusChangedPublisher = PassthroughSubject<(device_id: Int, is_online: Bool?, power: Bool?), Never>()
    lazy var installPluginPublisher = PassthroughSubject<(plugin_id: String, success: Bool), Never>()
    lazy var deviceActionsPublisher = PassthroughSubject<(operation_id: Int, response: DeviceActionResponse), Never>()

    
    init(urlString: String = "ws://192.168.0.84:8088/ws") {
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
    enum OperationType {
        case discoverDevice(domain: String)
        case installPlugin(plugin_id: String)
        case updatePlugin(plugin_id: String)
        case removePlugin(plugin_id: String)
        case deviceStatus(domain: String, device_id: Int)
        case turnOnDevice(domain: String, device_id: Int)
        case turnOffDevice(domain: String, device_id: Int)
        case getDeviceActions(domain: String, device_id: Int)
    }

    enum EventType: String {
        case state_changed
    }
    
}



// MARK: - ExcueteOperations
extension ZTWebSocket {
    /// execute operation
    /// - Parameter operation: operation type
    /// - Returns: nil
    func executeOperation(operation: OperationType) {
        var op: Operation!
        var opType: OperationType!
        switch operation {
        case .discoverDevice(let domain):
            op = Operation(domain: domain, id: id, service: "discover")
            opType = .discoverDevice(domain: domain)
        case .installPlugin(let plugin_id):
            op = Operation(domain: "plugin", id: id, service: "install")
            op.service_data.plugin_id = plugin_id
            opType = .installPlugin(plugin_id: plugin_id)
        case .updatePlugin(let plugin_id):
            op = Operation(domain: "plugin", id: id, service: "install")
            op.service_data.plugin_id = plugin_id
            opType = .updatePlugin(plugin_id: plugin_id)
        case .removePlugin(let plugin_id):
            op = Operation(domain: "plugin", id: id, service: "remove")
            op.service_data.plugin_id = plugin_id
            opType = .removePlugin(plugin_id: plugin_id)
        case .deviceStatus(let domain, let device_id):
            op = Operation(domain: domain, id: id, service: "state")
            op.service_data.device_id = device_id
            opType = .deviceStatus(domain: domain, device_id: device_id)
        case .turnOnDevice(let domain, let device_id):
            op = Operation(domain: domain, id: id, service: "switch")
            op.service_data.device_id = device_id
            op.service_data.power = "on"
            opType = .turnOnDevice(domain: domain, device_id: device_id)
        case .turnOffDevice(domain: let domain, device_id: let device_id):
            op = Operation(domain: domain, id: id, service: "switch")
            op.service_data.device_id = device_id
            op.service_data.power = "off"
            opType = .turnOffDevice(domain: domain, device_id: device_id)
        case .getDeviceActions(let domain, let device_id):
            op = Operation(domain: domain, id: id, service: "get_actions")
            op.service_data.device_id = device_id
            opType = .getDeviceActions(domain: domain, device_id: device_id)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            if self.status == .disconnected && AppDelegate.shared.appDependency.authManager.isSAEnviroment {
                self.socket.connect()
            }
        }
    }
    
    private func handleError(_ error: Error?) {
        if let e = error as? WSError {
            wsLog("websocket encountered an error: \(e.message)")
        } else {
            wsLog("websocket encountered an error")
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
            
            if let pluginId = operation.service_data.plugin_id {
                installPluginPublisher.send((plugin_id: pluginId, success: response.success))
            }
            
        case .updatePlugin:
            guard
                let response = WSOperationResponse<EmptyResultResponse>.deserialize(from: jsonString)
            else { return }
            
            if let pluginId = operation.service_data.plugin_id {
                installPluginPublisher.send((plugin_id: pluginId, success: response.success))
            }
        case .removePlugin:
            break
        case .deviceStatus:
            guard
                let response = WSOperationResponse<DeviceStatusResponse>.deserialize(from: jsonString),
                let status = response.result?.state
            else { return }
            let power = status.power
            deviceStatusPublisher.send((operation_id: operation.id, is_online: status.is_online, power: power == "on"))

        case .turnOnDevice:
            break
        case .turnOffDevice:
            break
        case .getDeviceActions:
            guard
                let response = WSOperationResponse<DeviceActionResponse>.deserialize(from: jsonString),
                let result = response.result
            else { return }
            
            deviceActionsPublisher.send((operation_id: operation.id, response: result))
            

        }
    }
    
    
    
    private func handleEventResponse(type: EventType, jsonString: String) {
        switch type {
        case .state_changed:
            guard
                let response = WSEventResponse<DeviceStatusEventResponse>.deserialize(from: jsonString),
                let status = response.data
            else { return }
            
            let power = status.state.power ?? ""
            deviceStatusChangedPublisher.send((device_id: status.device_id, is_online: status.state.is_online, power: power == "on"))
            
        }
    }
    
}


// MARK: - Helper
extension ZTWebSocket {
    private func wsLog(_ item: Any) {
        print("------------------------< WebSocketLog >-----------------------------------")
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


