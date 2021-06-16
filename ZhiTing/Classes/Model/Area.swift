//
//  Area.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/17.
//

import Foundation

class Area: BaseModel {
    /// Area's id
    var id = 1
    /// Area's name
    var name = ""
    
    /// smartAssistant's token
    var sa_token = ""
    
    func toAreaCache() -> AreaCache {
        let cache = AreaCache()
        cache.id = id
        cache.name = name
        cache.sa_token = sa_token
        return cache
    }
}


/// Use for syncing area to Smart Assistant
class SyncSAModel: BaseModel {
    var nickname = ""
    var area = AreaSyncModel()
    
    
    
    
    class LocationSyncModel: BaseModel {
        var name = ""
        var sort = 1
    }
    
    class AreaSyncModel: BaseModel {
        var name = ""
        var locations = [LocationSyncModel]()
    }
}
