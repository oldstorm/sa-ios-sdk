//
//  DiscoverOpModel.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import Foundation


class Operation: BaseModel {
    var domain = ""
    var id = 0
    var service = ""
    var service_data = ServiceData()

    init(domain: String, id: Int, service: String) {
        self.domain = domain
        self.id = id
        self.service = service
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
}


extension Operation {
    class ServiceData: BaseModel {
        var plugin_id: String?
        var device_id: Int?
        var power: String?
    }
}

//class PluginOperation: Operation {
//    var service_data = ServiceData()
//
//    init(domain: String, id: Int, service: String, plugin_id: String) {
//        super.init(domain: domain, id: id, service: service)
//        service_data.plugin_id = plugin_id
//    }
//
//    required init() {
//        fatalError("init() has not been implemented")
//    }
//
//
//
//    class ServiceData: BaseModel {
//        var plugin_id = ""
//    }
//}
//
//
//class DeviceOperation: Operation {
//    var service_data = ServiceData()
//
//    init(domain: String, id: Int, service: String, device_id: Int) {
//        super.init(domain: domain, id: id, service: service)
//        service_data.device_id = device_id
//    }
//
//    required init() {
//        fatalError("init() has not been implemented")
//    }
//
//
//
//    class ServiceData: BaseModel {
//        var device_id: Int = -1
//        var power: String?
//    }
//}


