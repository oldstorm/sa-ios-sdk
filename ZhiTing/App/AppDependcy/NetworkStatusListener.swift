//
//  NetworkStatusListener.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/22.
//

import Foundation
import Alamofire
import Combine
import CoreLocation
import SystemConfiguration.CaptiveNetwork

// MARK: - NetworkStatusListener
class NetworkManager: NSObject {
    enum NetworkStatus {
        case reachable
        case noNetwork
    }
    
    var locationManager = CLLocationManager()
    
    var status: NetworkStatus = .reachable
    
    private lazy var networkStatus = NetworkReachabilityManager()
    
    lazy var networkStatusPublisher = PassthroughSubject<NetworkStatus, Never>()

    override init() {
        super.init()
        
        networkStatus?.startListening(onUpdatePerforming: { [weak self] status in
            switch status {
            case .notReachable, .unknown:
                self?.status = .noNetwork
                self?.networkStatusPublisher.send(.noNetwork)
            case .reachable:
                self?.status = .reachable
                self?.switchBaseUrl()
                AppDelegate.shared.appDependency.websocket.connect()
                self?.networkStatusPublisher.send(.reachable)
            }
        })
    }
    
    
    /// get the current wifi ssid
    /// - Returns: ssid: string?
    func getWiFiSSID() -> String? {
        var ssid: String?
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            ssid = getWiFi_ssid()
        } else {
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            
        }
        
        return ssid
    }
    
    func getWiFi_ssid() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
    func switchBaseUrl() {
        if status == .reachable {
            if let ssid = getWiFiSSID() {
                baseUrl = "http://192.168.0.110:8088"
                AppDelegate.shared.appDependency.websocket.setUrl(urlString: "ws://192.168.0.110:8088/ws")
            } else {
                baseUrl = "http://192.168.0.84:8088"
                AppDelegate.shared.appDependency.websocket.setUrl(urlString: "ws://192.168.0.84:8088/ws")
            }
        } else {
            baseUrl = "http://192.168.0.84:8088"
            AppDelegate.shared.appDependency.websocket.setUrl(urlString: "ws://192.168.0.84:8088/ws")
        }
        
    }

    
}

extension NetworkManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            switchBaseUrl()
        }
    }
}



