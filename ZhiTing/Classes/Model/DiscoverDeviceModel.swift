//
//  DiscoverDeviceModel.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/29.
//

import Foundation

class DiscoverDeviceModel: BaseModel {
    var address = ""
    var identity = ""
    var manufacturer = ""
    var model = ""
    var name = ""
    var plugin_id = ""
    var sw_version = ""
    var type = ""
    
    
}

class DiscoverSAModel: DiscoverDeviceModel {
    var is_bind = false
}
