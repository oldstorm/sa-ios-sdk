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
    var filterContent = "ZT"
    
    /// 连接设备回调
    var connectCallback: ((Bool) -> Void)?
    
    /// 配网结果回调
    var provisionCallback: ((Bool) -> Void)?
    
    /// 注册设备回调
    var registerDeviceCallback: ((Bool, Int?, String?) -> Void)?
    

    
    /// 置网成功flag
    var provisionFlag = false
    
    /// 硬件设备ID
    var deviceID = ""
    
    /// 搜索发现的设备(用于配网成功后 调用添加设备接口)
    var discoverDeviceModel: DiscoverDeviceModel? = {
        let model = DiscoverDeviceModel()
        model.name = "ZT-SW3ZLW001W"
        model.type = "switch"
        model.manufacturer = "zhiting"
        model.sw_version = "1.0.4"
        model.model = "ZT-SW3ZLW001W"
        model.plugin_id = "zhiting"
        return model
        
    }()

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
    // 注册设备
    func registerDevice() {
        if AuthManager.shared.currentArea.id != nil
            && !AuthManager.shared.currentArea.is_bind_sa
            && AuthManager.shared.isLogin { // 云端虚拟SA家庭 配网后局域网搜索到设备,先注册到云端再添加设备
            getDeviceAccessToken(deviceID: deviceID)
            
        } else if AuthManager.shared.currentArea.id != nil
                    && AuthManager.shared.currentArea.is_bind_sa { // 真实SA家庭 配网后搜索到设备然后调添加设备
            
            UDPDeviceTool.stopUpdateAreaSAAddress()
            udpDeviceTool = UDPDeviceTool()

            /// 局域网内搜索到设备
            udpDeviceTool?.deviceSearchedPubliser
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] device in
                    guard let self = self else { return }
                    self.discoverDeviceModel?.identity = device.id
                    self.discoverDeviceModel?.sw_version = device.info?.sw_ver ?? ""
                    self.addDevice()
                })
                .store(in: &cancellables)
            
            try? udpDeviceTool?.beginScan(notifyDeviceID: deviceID)

        } else {
            registerDeviceCallback?(false, nil, nil)
        }


    }

}


extension BluFiTool {
    /// 添加配网成功后的设备
    func addDevice() {
        guard let discoverDeviceModel = discoverDeviceModel else {
            registerDeviceCallback?(false, nil, nil)
            return
        }
        
        ApiServiceManager.shared.addDiscoverDevice(device: discoverDeviceModel, area: AuthManager.shared.currentArea) { [weak self] response in
            guard let self = self else { return }
            self.registerDeviceCallback?(true, response.device_id, response.plugin_url)

            // 跳转设备详情
            
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.registerDeviceCallback?(false, nil, nil)
            
        }
    }
    

    /// 获取设备accessToken
    func getDeviceAccessToken(deviceID: String) {
        ApiServiceManager.shared.getDeviceAccessToken { [weak self] resp in
            guard let self = self else { return }
            self.connectDeviceToServer(deviceID: deviceID, accessToken: resp.access_token)
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.registerDeviceCallback?(false, nil, nil)
            print(err)
        }

    }

    
    /// 将设备连接服务器
    /// - Parameter deviceID: 设备id
    func connectDeviceToServer(deviceID: String, accessToken: String) {
        UDPDeviceTool.stopUpdateAreaSAAddress()
        udpDeviceTool = UDPDeviceTool()
        
        guard let areaId = AuthManager.shared.currentArea.id,
              AuthManager.shared.currentArea.is_bind_sa == false
        else {
            print("家庭id不存在或家庭已有SA，无需设置设备服务器")
            registerDeviceCallback?(false, nil, nil)
            return
        }

        /// 局域网内搜索到设备
        udpDeviceTool?.deviceSearchedPubliser
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] device in
                guard let self = self else { return }
                self.discoverDeviceModel?.identity = device.id
                self.udpDeviceTool?.connectDeviceToSC(device: device, areaId: areaId, accessToken: accessToken)
            })
            .store(in: &cancellables)
        
        /// 设备连接服务器
        udpDeviceTool?.deviceSetServerPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.addDevice()
                } else {
                    self.registerDeviceCallback?(false, nil, nil)
                }

                
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
        provisionFlag = false
        connectCallback?(true)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Blufi连接失败")
        connectCallback?(false)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Blufi连接断开")
        if !provisionFlag {
            connectCallback?(false)
        }
        
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.provisionCallback?(true)
                }
                
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
        
        
    }

    func blufi(_ client: BlufiClient, didPostCustomData data: Data, status: BlufiStatusCode) {
        print("Blufi已将自定义信息发送至设备")
    }
    
    func blufi(_ client: BlufiClient, didReceiveError errCode: Int) {
        print("Blufi接受到错误")
    }
    
    
}
