//
//  Location.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/17.
//

import Foundation

class Location: BaseModel {
    /// Location's id
    var id = 1
    /// Location's name
    var name = ""
    /// Location's devices
    var devices = [Device]()
    /// Location's order
    var sort = 0
    
    /// involved area's id
    var area_id = 0
    /// smartAssistant's token
    var sa_token = ""
    /// if chosen
    var chosen = true
}
