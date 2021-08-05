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
    var identity: String?
    var service_data: ServiceData?

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
        var attributes: [DeviceAttribute]?
    }
}



