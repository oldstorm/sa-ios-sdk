//
//  DiscoverOpModel.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import Foundation


class Operation<T: BaseModel>: BaseModel {
    var domain: String?
    var id = 0
    var service = ""
    var identity: String?
    var data: T?

    init(domain: String? = nil, id: Int, service: String, data: T? = nil) {
        self.domain = domain
        self.id = id
        self.service = service
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
}


extension Operation {
    class PluginServiceData: BaseModel {
        var plugin_id: String?
    }
    
    class AttributesServiceData: BaseModel {
        var iid: String?
        var attributes: [DeviceAttribute]?
    }
    
    class HomekitServiceData: BaseModel {
        var pin: String?
    }
    
    class ConnectDeviceServiceData: BaseModel {
        var iid: String?
        var auth_params = [String: Any]()
    }
    
}



