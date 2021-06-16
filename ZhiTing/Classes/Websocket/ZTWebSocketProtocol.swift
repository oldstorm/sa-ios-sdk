//
//  ZTWebSocketProtocol.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/1.
//

import Foundation

protocol ZTWebSocketProtocol: class {
    func didDiscoverDevice(device: Device)
    func didReceiveDeviceStatus(domain: String, power: Bool)
}

extension ZTWebSocketProtocol {
    func didDiscoverDevice(device: Device) {}
    func didReceiveDeviceStatus(domain: String, power: Bool) {}
}
