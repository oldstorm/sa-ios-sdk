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
    var sa_user_token = ""
    /// if chosen
    var chosen = true
}


extension Location: Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return (lhs.id == rhs.id && lhs.sa_user_token == rhs.sa_user_token && lhs.name == rhs.name)
    }
    
    
}


extension Array where Element: Location {
    func isDifferentFrom(another: [Location]) -> Bool {
        var flag = false
        if self.count != another.count {
            return true
        }

        self.forEach { location in
            if !another.contains(where: { $0 == location }) {
                flag = true
                return
            }
        }
        
        return flag
    }
}
