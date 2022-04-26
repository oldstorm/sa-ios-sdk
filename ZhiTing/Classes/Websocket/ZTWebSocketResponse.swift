//
//  WSResponse.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/4.
//

import Foundation




// MARK: - WSOperationResponse
class WSOperationResponse<T: BaseModel>: BaseModel {
    var id = 0
    var success = false
    var type = ""
    var error: WSOperationError?
    var data: T?
    
    required init() {}
}

class WSOperationError: BaseModel {
    var code = 0
    var message = ""
}

class EmptyResultResponse: BaseModel {
    
}

class SearchDeviceResponse: BaseModel {
    var device = DiscoverDeviceModel()
}




class DeviceStatusModel: BaseModel {
    var iid = ""
    var instances = [DeviceInstance]()
    var device: Device?
}


class DeviceInstance: BaseModel {
    var iid = ""
    var services = [DeviceService]()
    
}

class DeviceService: BaseModel {
    var instance_iid: String?
    var type = ""
    var attributes = [DeviceAttribute]()
}



// MARK: - WSEventResponse
class WSEventResponse<T: BaseModel>: BaseModel {
    var type = ""
    var event = ""
    var domain: String?
    var data: T?
    
    
    required init() {}
}

class DeviceStateChangeResponse: BaseModel {
    var plugin_id = ""
    var attr = DeviceAttribute()
}



