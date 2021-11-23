//
//  Plugin.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/2.
//

import Foundation

class Plugin: BaseModel {
    /// plugin's id
    var id = ""
    /// plugin's name
    var name = ""
    /// plugin's version
    var version = ""
    /// brand that the plugin belongs to
    var brand = ""
    /// plugin's information
    var info = ""
    /// plugin detail url
    var visit_url = ""
    /// plugin's supported devices
    var support_devices = [Device]()
    /// whether the plugin is installed
    var is_added = false
    /// whether the plugin needs update
    var is_newest = true
    /// 插件build状态（-1build失败,0正在build,1build成功）
    var build_status: Int?
    /// use for view's updating state
    var is_updating = false
    
    /// plugin's download url
    var download_url: String?
    
    /////////////////////
    var logo_url = ""
    
}
