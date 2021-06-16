//
//  DiscoverOpModel.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import Foundation


struct Operation: Codable {
    var domain = "yeelight"
    var id = 1
    var service = "discover"
}




extension Operation {
    func toData() -> Data? {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(self)
        return data
    }
}
