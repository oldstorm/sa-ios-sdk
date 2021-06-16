//
//  WSResponse.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/4.
//

import Foundation


class WSOperationResponse<T: HandyJSON>: HandyJSON {
    var id = 0
    var success = false
    var result: T?
    
    required init() {}
}

class SearchDeviceResponse: HandyJSON {
    var device = Device()
    required init() {}
}



class DeviceStatusResponse: HandyJSON {
    var state = Status()
    required init() {}
    
    
    class Status: HandyJSON {
        var power = false
        var is_online = false
        var brightness = 0
        var color_temp = 0
        
        required init() {}
    }
}
