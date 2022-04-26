//
//  DeviceLogoModel.swift
//  ZhiTing
//
//  Created by iMac on 2022/2/24.
//

import Foundation

class DeviceLogoModel: BaseModel, Equatable {
    var type = 0
    var name = ""
    var url = ""
    
    static func == (lhs: DeviceLogoModel, rhs: DeviceLogoModel) -> Bool {
        lhs.type == rhs.type
    }
}


