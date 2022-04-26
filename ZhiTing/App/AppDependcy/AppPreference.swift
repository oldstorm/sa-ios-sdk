//
//  AppPreference.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/1.
//

import Foundation
import Combine

/// 管理App相关喜好设置
class AppPreference {
    /// 设备列表展示模式(列表、流式)
    var deviceListStyle: DeviceListStyle? {
        set {
            @UserDefaultWrapper(key: .deviceListStyle)
            var style: String?
            
            style = newValue?.rawValue
            deviceListStyleSubject.send(deviceListStyle ?? .flow)
        }
        
        get {
            @UserDefaultWrapper(key: .deviceListStyle)
            var style: String?
            
            return DeviceListStyle(rawValue: style ?? "flow")
                
        }
    }
    
    private lazy var deviceListStyleSubject = CurrentValueSubject<DeviceListStyle, Never>(deviceListStyle ?? .flow)
    
    var deviceListStylePublisher: AnyPublisher<DeviceListStyle, Never> {
        deviceListStyleSubject.eraseToAnyPublisher()
    }
    

    

}
