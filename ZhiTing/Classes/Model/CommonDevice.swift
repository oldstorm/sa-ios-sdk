//
//  CommonDevice.swift
//  ZhiTing
//
//  Created by iMac on 2021/9/8.
//

import Foundation

/// common设备
class CommonDeviceDetail: BaseModel {
    /// 设备id
    var id = 0

    /// 设备图片
    var img_url = ""

    /// 设备名称
    var name = ""
    
    /// 操作介绍
    var operate_intro = ""
    
}

/// common设备类型
class CommonDeviceType: BaseModel {
    /// 设备类型id
    var id = 0

    /// 设备类型名称
    var name = ""
    
}
