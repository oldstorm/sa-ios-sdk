//
//  LaunchViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/30.
//

import UIKit
import RealmSwift

class LaunchViewController: BaseViewController {
    lazy var image = ImageView().then {
        $0.image = .assets(.icon_launch)
    }
    
    lazy var label = Label().then {
        $0.text = "你的智能生活助手"
        $0.font = .font(size: 30, type: .light)
        $0.numberOfLines = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(getAddress(for: .wifi) ?? "")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfExistAccordingLocalSA()
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(image)
        view.addSubview(label)
        
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(27.5)
        }
        
        image.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16.5 - Screen.bottomSafeAreaHeight)
            $0.width.equalTo(40)
            $0.height.equalTo(65)
            $0.centerX.equalToSuperview()
        }
    }
}


extension LaunchViewController {
    

    func checkIfExistAccordingLocalSA() {
        let ip = getCurrentIpAddress()
        let sas = SmartAssistantCache.getSmartAssistantsFromCache()
        AppDelegate.shared.appDependency.networkManager.currentWifiSSID = AppDelegate.shared.appDependency.networkManager.getWiFiName()

        if let currentSA = sas.first(where: { $0.ip_address == ip }) {
            AppDelegate.shared.appDependency.authManager.currentSA = currentSA
            if let area = AreaCache.areaList().first(where: { $0.sa_token == currentSA.token }) {
                AppDelegate.shared.appDependency.currentAreaManager.currentArea = area
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                SceneDelegate.shared.window?.rootViewController = AppDelegate.shared.appDependency.tabbarController
                
            }
            
            
        } else {
            if sas.count == 0 {
                setupNewLocalSAandUser()
            }
            
            if let currentSA = SmartAssistantCache.getSmartAssistantsFromCache().first {
                AppDelegate.shared.appDependency.authManager.currentSA = currentSA
                if let area = AreaCache.areaList().first(where: { $0.sa_token == currentSA.token }) {
                    AppDelegate.shared.appDependency.currentAreaManager.currentArea = area
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    SceneDelegate.shared.window?.rootViewController = AppDelegate.shared.appDependency.tabbarController
                   
                }
            }
            
        }
    }
    
    func getCurrentIpAddress() -> String {
        #if DEBUG
        return "sa.zhitingtech.com"//测试服务器
//        return "192.168.0.112:8088"
//        return "192.168.0.159:8088"//力宏
//        return "192.168.0.110:8088"//马健
        #else
        //获取当前网络端口
        //        let NetworkPort =
        // 匹配当前本地库是否存在SA
//                let allTokens = SmartAssistantCache.getSmartAssistantsFromCache()
//                guard let currentToken = allTokens.filter("ip_address = '\(NetworkPort)'").first else {return}//
//                let area = AreaCache.areaList().first(where: {$0.sa_token == currentToken.token})
        
        //        self.switchAreaView.selectedArea = area
        return "192.168.0.112:8088"
        #endif
        

    }
    
    
    
    func setupNewLocalSAandUser() {
        let sa = SmartAssistantCache()
        sa.ip_address = ""
        sa.nickname = "User_" + UUID().uuidString.prefix(6)
        sa.ssid = ""
        sa.token = ""
        SmartAssistantCache.cacheSmartAssistants(sa: sa)
        
        
        AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)")

        AppDelegate.shared.appDependency.authManager.currentSA = sa.transformToSAModel()
        
    }
    
    
    
    
    
    
}

extension LaunchViewController {
    private func getAddress(for network: NetworkENV) -> String? {
        var address: String?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == network.rawValue {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }



    private enum NetworkENV: String {
        case wifi = "en0"
        case cellular = "pdp_ip0"
        case ipv4 = "ipv4"
        case ipv6 = "ipv6"
    }
}
