//
//  WSResponse.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/4.
//

import Foundation




// MARK: - WSOperationResponse
class WSOperationResponse<T: HandyJSON>: HandyJSON {
    var id = 0
    var success = false
    var result: T?
    
    required init() {}
}

class EmptyResultResponse: HandyJSON {
    required init() {}
}

class SearchDeviceResponse: HandyJSON {
    var device = DiscoverDeviceModel()
    required init() {}
}



class DeviceStatusResponse: HandyJSON {
    var state = DeviceStatus()
    required init() {}
    
    class DeviceStatus: HandyJSON {
        var device_id = ""
        var power = "off"
        var is_online = false
        var brightness = 0
        var color_temp = 0
        
        required init() {}
    }
    
}

class DeviceActionResponse: HandyJSON {
    required init() {}
    var actions = DeviceAction()
    
    
    class DeviceDetailAction: HandyJSON {
        required init() {}
        var cmd = ""
        var name = ""
        var is_permit = false
    }
    
    class DeviceAction: HandyJSON {
        required init() {}
        var `switch`: DeviceDetailAction?
        var set_color_temp: DeviceDetailAction?
        var set_bright: DeviceDetailAction?
    }
    
}






// MARK: - WSEventResponse
class WSEventResponse<T: HandyJSON>: HandyJSON {
    var event_type = ""
    var data: T?
    var origin = ""
    
    required init() {}
}

class DeviceStatusEventResponse: HandyJSON {
    var device_id: Int = -1
    var state = DeviceStatus()
    required init() {}
    
    class DeviceStatus: HandyJSON {
        var power: String?
        var is_online: Bool?
        
        
        required init() {}
    }
    
}
