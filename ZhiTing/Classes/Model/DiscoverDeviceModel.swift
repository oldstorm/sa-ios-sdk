//
//  DiscoverDeviceModel.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/29.
//

import Foundation

class DiscoverDeviceModel: BaseModel {
    var address = ""
    var iid = ""
    var logo_url = ""
    /// 厂商
    var manufacturer = ""
    /// 设备model
    var model = ""
    /// 设备名称
    var name = ""
    /// 插件id
    var plugin_id = ""
    /// 软件版本
    var sw_version = ""
    /// 设备类型
    var type = ""
    /// 设备是否需要认证(homekit设备等需要认证)
    var auth_required: Bool?
    /// 设备是否需要认证
    var auth_params: [DiscoverDeviceAuthParams]?
    
    var area_type: Int?
    
    /// 设备连接云端时使用的协议
    var `protocol`: String?
}

/// 设备认证属性
class DiscoverDeviceAuthParams: BaseModel {
    /// 属性名称
    var name = ""
    /// 属性类型
    var type = ""
    /// 是否必填
    var required = false
    /// 默认值
    var `default`: Any?
    /// 最小值
    var min: Any?
    /// 最大值
    var max: Any?
    /// 选项
    var options: [[String: Any]]?
}

class DiscoverSAModel: DiscoverDeviceModel {
    var is_bind = false
    var version = ""
    var sa_id: String?
}
