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
    var type = ""
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



class DeviceStatusResponse: BaseModel {
    
    var device = DeviceStatusModel()

    
    class DeviceStatusModel: BaseModel {
        var identity = ""
        var type = ""
        var instances = [DeviceInstance]()
    }

}



class DeviceInstance: HandyJSON {
    var type = ""
    var instance_id = 0
    var attributes = [DeviceAttribute]()
    
    
    required init() {}
}




// MARK: - WSEventResponse
class WSEventResponse<T: HandyJSON>: HandyJSON {
    var event_type = ""
    var data: T?
    var origin = ""
    
    required init() {}
}

class DeviceStateChangeResponse: BaseModel {
    var identity = ""
    var instance_id = 0
    var attr = DeviceAttribute()
}



