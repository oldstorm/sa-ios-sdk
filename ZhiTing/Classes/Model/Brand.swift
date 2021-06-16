//
//  Brand.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/25.
//

import Foundation

class Brand: BaseModel {
    /// brand's id
    var id = ""
    /// brand's logo
    var logo_url = ""
    /// brand's name
    var name = ""
    /// whether the brand is installed
    var is_added = false
    /// whether the brand's plugins need update
    var is_newest = true
    /// brand's plugin amount
    var plugin_amount = 0
    /// brand's plguins
    var plugins = [Plugin]()
    /// brand's supported devices
    var support_devices = [Device]()
    
    
    /// use for view's updating status
    var is_updating = false
}


