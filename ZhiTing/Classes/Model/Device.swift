//
//  Device.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/2.
//

import Foundation

class Device: BaseModel {
    /// 设备id
    var id = -1
    /// 设备名称
    var name = ""
    /// 设备型号
    var model = ""
    /// 设备品牌id
    var brand_id = ""
    /// 设备关联的房间
    var location: Location?
    /// 设备关联的部门
    var department: Location?
    /// 关联插件信息
    var plugin: Plugin?
    /// 设备logo
    var logo_url = ""
    /// 设备唯一标识
    var iid = ""
    /// 插件id (domain)
    var plugin_id = ""
    /// 控制页相对路径
    var control = ""
    /// 设备关联的家庭/公司id
    var area_id: String?
    /// 设备关联的房间id
    var location_id: Int?
    /// 设备关联的部门id
    var department_id: Int?
    /// 设备详情插件地址
    var plugin_url: String?
    /// 设备是否为SA设备
    var is_sa = false
    /// SA的token
    var sa_user_token = ""
    /// 设备所有有权限的控制功能
    var attributes = [DeviceAttribute]()
    /// 设备权限
    var permissions = DevicePermission()
    /// 所属房间名
    var location_name: String?
    /// 所属部门名
    var department_name: String?
    /// 从websocket获取到的设备状态
    var device_status: DeviceStatusModel?
    /// 设备logo信息
    var logo: DeviceLogoModel?

}

class DevicePermission: BaseModel {
    var update_device = false
    var delete_device = false
}

class DeviceAttribute: BaseModel {
    /// 属性id
    var aid: Int?

    /// 属性名
    var type = ""
    
    /// val_type为数字是表示该值最小值
    var min: Any?
    
    /// val_type为数字是表示该值最大值
    var max: Any?
    
    /// 动态类型
    var val: Any?
    
    /// bool,int,string,float64
    var val_type: String?
    
    var iid: String?
    
    /// 控制权限 1可读 2可写 4通知 (类似linux权限)
    /// 没有通知权限，无法作为场景条件
    /// 没有读权限，无法作为场景定时条件
    /// 没有写权限，无法作为场景任务
    var permission: Int?
    
   

}


