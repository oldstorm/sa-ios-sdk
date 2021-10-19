//
//  TestVC.swift
//  ZhiTing
//
//  Created by iMac on 2021/9/28.
//

import UIKit
import ESPProvision

class TestVC: BaseViewController {
    
    let blufiTool = BluFiTool()
    
    lazy var deviceSSID = "ZTSW3ZL001W"
    let sofAPTool = SoftAPTool()
    
    override func setupViews() {
        navigationItem.title = "测试一下咯"
        
        let btn1 = Button()
        btn1.backgroundColor = .custom(.oringe_f6ae1e)
        btn1.setTitle("test blufi", for: .normal)
        btn1.setTitleColor(.custom(.white_ffffff), for: .normal)
        btn1.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.test()
        }
        view.addSubview(btn1)
        
        btn1.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.equalTo(200)
        }
        
        let btn2 = Button()
        btn2.backgroundColor = .custom(.oringe_f6ae1e)
        btn2.setTitle("test softAP", for: .normal)
        btn2.setTitleColor(.custom(.white_ffffff), for: .normal)
        btn2.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.test2()
        }
        view.addSubview(btn2)
        
        btn2.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(btn1.snp.bottom).offset(50)
            $0.height.equalTo(50)
            $0.width.equalTo(200)
        }
        
        let string = "7CDFA1A44900"
        let bytes = string.hexaBytes
        let data = Data(bytes).toHexString()
        print(bytes)
        print(data)
        
//        ApiServiceManager.shared.getDeviceAccessToken(area: AuthManager.shared.currentArea) { resp in
//            print(resp.access_token)
//        } failureCallback: { code, err in
//            print(err)
//        }

        blufiTool.scanAndConnectDevice(filterContent: "ZTSW")
    }

}

extension TestVC {
    func test() {
//        blufiTool.scanBlufiDevices { [weak self] device in
//            guard let self = self else { return }
//            self.blufiTool.stopScanDevices()
//            self.blufiTool.connect(device: device)
//            self.blufiTool.configWifi(ssid: "zhiting", pwd: "zhiting888!!!")
//        }
        
        
        
        blufiTool.configWifi(ssid: "zhiting", pwd: "zhiting888!!!")
    }
}

extension TestVC {
    func test2() {
        /// 需要添加的设备
        var device: ESPDevice?
        /// 设备bssid
        var deviceBSSID: String?
        /// 队列信号量
        let sema = DispatchSemaphore(value: 1)
        
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            sema.wait()
            /// 创建对应ESP设备
            self.sofAPTool.createESPDevice(deviceName: self.deviceSSID) { [weak self] espDevice in
                guard let self = self,
                      let espDevice = espDevice
                else {
                    print("创建设备失败")
                    sema.signal()
                    return
                }
                
                print("创建设备成功")
                device = espDevice
                sema.signal()
            }
            
            sema.wait()
            
            /// 设备创建成功
            guard let device = device else {
                return
            }

            /// 是否连接成功
            var isConnected = false
            
            
            /// 连接设备
            self.sofAPTool.connectESPDevice { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .connected:
                    print("连接成功")
                    isConnected = true
                    deviceBSSID = NetworkStateManager.shared.getWifiBSSID()
                    print("获取bssid: \(deviceBSSID)")
                    sema.signal()
                    

                case .disconnected:
                    print("断开连接")
                    sema.signal()
                    
                case .failedToConnect(let error):
                    print("连接失败\(error.localizedDescription)")
                    sema.signal()
                }
                   
            }
            
            
            sema.wait()
            
            if !isConnected {
                return
            }

            /// 是否置网成功
            var isSuccess = false
            
            
            /// 设备置网
            self.sofAPTool.provisionDevice(ssid: "zhiting", passphrase: "zhiting888!!!") { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .success:
                    print("置网成功")
                    isSuccess = true
                    sema.signal()
                    
                case .configApplied:
                    print("设备已接收置网信息")
                    
                case .failure(let err):
                    print("置网失败\(err.localizedDescription)")
                    sema.signal()
                }

            }
            
            sema.wait()
            
            if !isSuccess {
                return
            }
            
            

        }

    }
}
