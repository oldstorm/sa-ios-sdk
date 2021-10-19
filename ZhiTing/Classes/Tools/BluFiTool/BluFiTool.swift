//
//  BluFiTool.swift
//  ZhiTing
//
//  Created by iMac on 2021/9/27.
//

import Foundation
import ESPProvision
import Combine

class BluFiTool: NSObject {
    
    /// 用于局域网扫描设备
    var udpDeviceTool: UDPDeviceTool?

    var cancellables = Set<AnyCancellable>()
    
    /// 连接的设备
    var device: ESPPeripheral?

    /// blufi client
    var blufiClient: BlufiClient?
    
    
    /// 用于扫描Blufi设备
    let bluFiHelper = ESPFBYBLEHelper.share()
    
    /// 已发现的设备
    var discoveredDevices = [ESPPeripheral]()
    
    /// 扫描Blufi时过滤关键词
    var filterContent = "BLUFI"
    
    /// 连接设备回调
    var connectCallback: ((Bool) -> Void)?
    
    /// 配网结果回调
    var provisionCallback: ((Bool) -> Void)?
    
    /// 添加设备回调
    var addDeviceCallback: ((Bool) -> Void)?
    
    /// 置网成功flag
    var provisionFlag = false
    
    /// 硬件设备ID
    var deviceID = ""



    /// 连接设备Blufi设备
    func connect(device: ESPPeripheral) {
        self.device = device
        blufiClient?.close()
        blufiClient = BlufiClient()
        blufiClient?.centralManagerDelete = self
        blufiClient?.peripheralDelegate = self
        blufiClient?.blufiDelegate = self
        blufiClient?.connect(device.uuid.uuidString)
    }
    
    /// 发送配网信息
    /// - Parameters:
    ///   - ssid: wifi名称
    ///   - pwd: wifi密码
    func configWifi(ssid: String, pwd: String) {
        let params = BlufiConfigureParams()
        params.opMode = OpModeSta
        params.staSsid = ssid
        params.staPassword = pwd
        blufiClient?.configure(params)
    }

    /// 扫描blufi蓝牙设备
    /// - Parameters:
    ///   - filterContent: 过滤关键词
    ///   - callback: 发现设备回调
    func scanBlufiDevices(filterContent: String = "BLUFI", callback: ((ESPPeripheral) -> Void)?) {
        self.filterContent = filterContent
        bluFiHelper.startScan { [weak self] blufiDevice in
            guard let self = self else { return }
            if self.shouldAddToSource(device: blufiDevice) {
                self.discoveredDevices.append(blufiDevice)
                callback?(blufiDevice)
            }
        }
    }
    
    /// 扫描并连接设备
    /// - Parameter filterContent: 过滤关键词
    func scanAndConnectDevice(filterContent: String = "BLUFI") {
        self.filterContent = filterContent
        bluFiHelper.startScan { [weak self] blufiDevice in
            guard let self = self else { return }
            if self.shouldAddToSource(device: blufiDevice) {
                self.stopScanDevices()
                self.device = blufiDevice
                self.connect(device: blufiDevice)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.device == nil {
                self.stopScanDevices()
                self.connectCallback?(false)
            }
            
        }

    }

    
    /// 停止扫描blufi蓝牙设备
    func stopScanDevices() {
        bluFiHelper.stopScan()
    }

    /// 判断是否应该将发现的设备添加至发现列表
    /// - Parameter device: 待添加设备
    /// - Returns: 是否添加
    func shouldAddToSource(device: ESPPeripheral) -> Bool {
        if filterContent.count > 0 {
            if device.name.isEmpty || !device.name.hasPrefix(filterContent) {
                return false
            }
        }
        /// 已存在
        if discoveredDevices.contains(where: { $0.uuid == device.uuid }) {
            return false
        }
        return true
    }

}

extension BluFiTool {
    /// 获取设备accessToken
    func getDeviceAccessToken(deviceID: String) {
        guard AuthManager.shared.currentArea.id != nil else {
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
        
        guard let areaId = AuthManager.shared.currentArea.id,
              AuthManager.shared.currentArea.is_bind_sa == false
        else {
            print("家庭id不存在或家庭已有SA，无需设置设备服务器")
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

extension BluFiTool: CBCentralManagerDelegate, CBPeripheralDelegate, BlufiDelegate {
    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Blufi连接成功")
        connectCallback?(true)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Blufi连接失败")
        connectCallback?(false)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Blufi连接断开")
        connectCallback?(false)
    }


    // MARK: - BlufiDelegate
    
    func blufi(_ client: BlufiClient, gattPrepared status: BlufiStatusCode, service: CBService?, writeChar: CBCharacteristic?, notifyChar: CBCharacteristic?) {
        print("Blufi准备就绪")
    }
    
    func blufi(_ client: BlufiClient, didNegotiateSecurity status: BlufiStatusCode) {
        print("Blufi安全校验成功")
    }
    
    func blufi(_ client: BlufiClient, didPostConfigureParams status: BlufiStatusCode) {
        print("Blufi已将发送配网信息至设备")
    }
    
    func blufi(_ client: BlufiClient, didReceiveDeviceStatusResponse response: BlufiStatusResponse?, status: BlufiStatusCode) {
        print("Blufi接受到设备响应")
        if status == StatusSuccess {
            if let isConnect = response?.isStaConnectWiFi(), isConnect == true {
                print("Blufi置网成功")
                provisionCallback?(true)
            } else {
                print("Blufi置网失败")
                provisionCallback?(false)
            }
            
        } else {
            print("Blufi置网失败")
            provisionCallback?(false)
        }
    }
    
    func blufi(_ client: BlufiClient, didReceiveCustomData data: Data, status: BlufiStatusCode) {
        print("Blufi接受到设备自定义响应")
        /// 设备ID
        guard let deviceID = String(data: data, encoding: .utf8) else { return }
        provisionFlag = true
        self.deviceID = deviceID.lowercased()
        print("设备id: \(self.deviceID )")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.getDeviceAccessToken(deviceID: self.deviceID )
        }
        
    }

    func blufi(_ client: BlufiClient, didPostCustomData data: Data, status: BlufiStatusCode) {
        print("Blufi已将自定义信息发送至设备")
    }
    
    func blufi(_ client: BlufiClient, didReceiveError errCode: Int) {
        print("Blufi接受到错误")
    }
    
    
}
