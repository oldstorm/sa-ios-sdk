//
//  ESPProvisionHelper.swift
//  ZhiTing
//
//  Created by iMac on 2021/9/17.
//

import Foundation
import ESPProvision
import Combine
import NetworkExtension

class SoftAPTool {
    /// 用于局域网扫描设备
    var udpDeviceTool: UDPDeviceTool?

    var cancellables = Set<AnyCancellable>()
    
    /// 置网成功flag
    var provisionFlag = false
    
    /// 置网之前的bssid
    var beforeBSSID: String?

    /// 硬件设备ID
    var deviceID = ""

    /// ESP设备
    var device: ESPDevice?
    
    /// 设备拥有权 默认abcd1234
    var devicePop = "abcd1234"
    
    init() {
        NetworkStateManager.shared.networkStatusPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                if state == .reachable
                    && self.provisionFlag
                    && self.deviceID != ""
                    && NetworkStateManager.shared.getWifiBSSID() == self.beforeBSSID {
                    /// 置网成功后回到局域网 将设备连接至服务器
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.getDeviceAccessToken(deviceID: self.deviceID)
                    }
                    
                    
                }
            }
            .store(in: &cancellables)
    }


    /// 创建ESP设备
    /// - Parameters:
    ///   - deviceName: 设备名称(热点名称) e.g. "PROV_E2CF5C"
    ///   - proofOfPossession: 设备pop(设备拥有权) e.g. "abcd1234"
    func createESPDevice(deviceName: String, proofOfPossession: String = "abcd1234", completeHandler: ((ESPDevice?) -> Void)? = nil) {
        devicePop = proofOfPossession
        ESPProvisionManager.shared.createESPDevice(deviceName: deviceName, transport: .softap, proofOfPossession: proofOfPossession) { [weak self] device, err in
            guard let self = self else { return }
            completeHandler?(device)
            self.device = device
        }
    }
    
    /// 连接设备
    /// - Parameters:
    ///   - device: 需要连接的esp设备
    ///   - connectHandler: 连接回调
    func connectESPDevice(connectHandler: ((ESPSessionStatus) -> Void)?) {
        guard let device = device else {
            connectHandler?(.disconnected)
            return
        }
        device.connect(delegate: self, completionHandler: { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .connected:
                let deviceID = NetworkStateManager.shared.getWifiBSSID()?
                    .components(separatedBy: ":")
                    .compactMap { $0 }
                    .map { element -> String in
                        if element.count == 1 {
                            return "0\(element)"
                        } else {
                            return element
                        }
                    }
                    .joined()
                    
                
                self.deviceID = deviceID ?? ""
            default:
                break
            }
            connectHandler?(status)
        })
    }

    
    /// 置网ESP设备
    /// - Parameters:
    ///   - ssid: 置网ssid
    ///   - passphrase: 密码
    func provisionDevice(ssid: String, passphrase: String = "", completeHandler: ((ESPProvisionStatus) -> Void)?) {
        guard let device = device else {
            completeHandler?(.failure(.unknownError))
            return
        }
        
        device.provision(ssid: ssid, passPhrase: passphrase) { [weak self] status in
            switch status {
            case .success:
                self?.provisionFlag = true
            default:
                break
            }
            
           completeHandler?(status)
        }
    }
    
    /// 通过ESP设备扫描发现可置网的设备
    /// - Parameter device: ESP设备
    func scanWifiList() {
        device?.scanWifiList(completionHandler: { wifiList, err in
            if let err = err {
                print("\(err.localizedDescription)")
                return
            }
            print("发现可置网的wifi列表")

        })
    }

}

extension SoftAPTool {
    /// 获取设备accessToken
    func getDeviceAccessToken(deviceID: String) {
        guard AuthManager.shared.currentArea.id != nil && !AuthManager.shared.currentArea.is_bind_sa else {
            print("家庭id不存在")
            return
        }
        
        ApiServiceManager.shared.getDeviceAccessToken(area: AuthManager.shared.currentArea) { [weak self] resp in
            guard let self = self else { return }
            self.connectDeviceToServer(deviceID: deviceID, accessToken: resp.access_token)
        } failureCallback: { code, err in
            print(err)
        }

    }

    
    /// 将设备连接服务器
    /// - Parameter deviceID: 设备id
    func connectDeviceToServer(deviceID: String, accessToken: String) {
        udpDeviceTool = UDPDeviceTool()
        
        guard let areaId = AuthManager.shared.currentArea.id else {
            print("家庭id不存在")
            return
        }

        /// 局域网内搜索到设备
        udpDeviceTool?.deviceSearchedPubliser
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] device in
                guard let self = self else { return }
                self.udpDeviceTool?.connectDeviceToSC(device: device, areaId: areaId, accessToken: accessToken)
            })
            .store(in: &cancellables)
        
        /// 设备连接服务器
        udpDeviceTool?.deviceSetServerPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] success in
                guard let self = self else { return }
                
            })
            .store(in: &cancellables)
        
        try? udpDeviceTool?.beginScan(notifyDeviceID: deviceID)

    }
    
}

extension SoftAPTool: ESPDeviceConnectionDelegate {
    func getProofOfPossesion(forDevice: ESPDevice, completionHandler: @escaping (String) -> Void) {
        completionHandler(devicePop)
    }
}




extension SoftAPTool {
    
    /// 移除热点信息
    /// - Parameter ssid: 需要移除的热点的ssid
    func removeConfiguration(ssid: String) {
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
    }
    
    
    /// 连接指定热点
    /// - Parameters:
    ///   - ssid: 热点ssid
    ///   - pwd: 热点密码
    ///   - callback: 连接结果回调
    func applyConfiguration(ssid: String, pwd: String, callback: ((_ success: Bool) -> Void)? = nil) {
        beforeBSSID = NetworkStateManager.shared.getWifiBSSID()
        let config = NEHotspotConfiguration(ssid: ssid, passphrase: pwd, isWEP: false)
        config.joinOnce = true
        
        NEHotspotConfigurationManager.shared.apply(config) { (error) in
            if NetworkStateManager.shared.getWifiSSID() == ssid {
                callback?(true)
            } else {
                callback?(false)
            }

        }
    }
    
    /// 连接指定无密码热点
    /// - Parameters:
    ///   - ssid: 热点ssid
    ///   - callback: 连接结果回调
    func applyConfiguration(ssid: String, pwd: String? = nil, callback: ((_ success: Bool) -> Void)? = nil) {
        beforeBSSID = NetworkStateManager.shared.getWifiBSSID()
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)

        let config: NEHotspotConfiguration
        if let pwd = pwd {
            config = NEHotspotConfiguration(ssid: ssid, passphrase: pwd, isWEP: false)
        } else {
            config = NEHotspotConfiguration(ssid: ssid)
        }
        
        config.joinOnce = true
        
        NEHotspotConfigurationManager.shared.apply(config) { (error) in
            if NetworkStateManager.shared.getWifiSSID() == ssid && NetworkStateManager.shared.getWifiSSID() != nil {
                callback?(true)
            } else {
                callback?(false)
            }

        }
    }
}
