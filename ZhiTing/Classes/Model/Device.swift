//
//  Device.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/2.
//

import Foundation

class Device: BaseModel {
    /// device's id
    var id = -1
    /// device's name
    var name = ""
    /// device's type
    var model = ""
    /// device's brand id
    var brand_id = ""
    /// the associated location 
    var location = Location()
    /// the associated plugin
    var plugin = Plugin()
    /// the associated area
    var area = Area()
    /// device's logo
    var logo_url = ""
    
    var identity = ""
    
    var plugin_id = ""
    
    var area_id = -1
    
    var location_id = -1
    
    var plugin_url: String?
    
    /// If the device is SA
    var is_sa = false
    
    /// smartAssistant's token
    var sa_token = ""
    
    /// 设备所有有权限的控制功能
    var actions = [DeviceAction]()
    
    /// 设备权限
    var permissions = DevicePermission()
    
    /// ---
    
    /// 发送的设备状态指令id
    var status_operation_id: Int?
    /// 发送的设备action指令id
    var action_operation_id: Int?
    /// 设备开关状态
    var isOn: Bool?
    /// 设备在线状态
    var is_online: Bool?
    /// 设备权限
    var is_permit: Bool?
    
    /// 设备域名
    var domain: String?
    
    //switch开关，light灯
    var type: String?
    //房间名
    var location_name: String?

}

class DevicePermission: BaseModel {
    var update_device = false
    var delete_device = false
}

class DeviceAction: BaseModel {
    var name = ""
    var action = ""
    var attr = ""
}


