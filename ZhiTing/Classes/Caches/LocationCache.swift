//
//  LocationCache.swift
//  ZhiTing
//
//  Created by iMac on 2021/12/28.
//

import Foundation
import RealmSwift

// MARK: - LocationCache
class LocationCache: Object {
    /// According SA's Token
    @Persisted var sa_user_token = ""
    
    /// Area's id
    @Persisted var id: Int = 1
    
    /// Area's name
    @Persisted var name = ""
    
    /// 人员数量
    @Persisted var user_count = 0
    
    /// involved area's id
    @Persisted var area_id: String?
    
    /// Area's order_index
    @Persisted var sort = 0
    
    
    func increasePrimaryKey() {
        let realm = try! Realm()
        let currentMaxId = realm.objects(LocationCache.self).sorted(byKeyPath: "id", ascending: true).last?.id ?? 0
        id = currentMaxId + 1
    }
    
    func transformToLocation() -> Location {
        let location = Location()
        location.id = id
        location.name = name
        location.user_count = user_count
        location.sa_user_token = sa_user_token
        location.area_id = area_id
        return location
    }
    
    static func cacheLocations(locations: [Location], token: String) {
        let realm = try! Realm()
        
        try? realm.write {
            let caches = realm.objects(LocationCache.self).filter("sa_user_token = '\(token)'")
            realm.delete(caches)
            
            
            locations.forEach { location in
                let cache = LocationCache()
                cache.area_id = location.area_id
                cache.name = location.name
                cache.id = location.id
                cache.user_count = location.user_count
                cache.sa_user_token = location.sa_user_token
                realm.add(cache)
            }
        }
        
    }

    /// Retrieve area's location
    /// - Parameter area_id: area's id
    /// - Returns: areas's locations
    static func areaLocationList(area_id: String?, sa_token: String) -> [Location] {
        let realm = try! Realm()
        var areasArray = [Location]()
        let areaId: String
        
        if let area_id = area_id {
            areaId = "'\(area_id)'"
        } else {
            areaId = "nil"
        }
        let result = realm.objects(LocationCache.self).filter("area_id = \(areaId) AND sa_user_token = '\(sa_token)'").sorted(byKeyPath: "sort")
        
        result.forEach {
            areasArray.append($0.transformToLocation())
        }
        
        return areasArray
    }
    
    /// Retrieve the device
    /// - Parameter location_id: location_id
    /// - Returns: Area?
    static func locationDetail(location_id: Int, sa_token: String) -> Location? {
        let realm = try! Realm()
        if let result = realm.objects(LocationCache.self).filter("id = \(location_id) AND sa_user_token = '\(sa_token)'").first {
            return result.transformToLocation()
        }
        return nil
    }
    
    /// AddLocationToArea
    /// - Parameters:
    ///   - area_id: id
    ///   - name: name
    static func addLocationToArea(area_id: String?, name: String, sa_token: String) {
        let realm = try! Realm()
        let location = LocationCache()
        location.name = name
        location.area_id = area_id
        location.sa_user_token = sa_token
        if let cacheLocationMaxId = realm.objects(LocationCache.self).filter("sa_user_token = '\(sa_token)'").sorted(byKeyPath: "id").last?.id {
            location.id = cacheLocationMaxId + 1
        }
        
        try? realm.write {
            realm.add(location)
        }
        
    }
    
    /// Change the location's name
    /// - Parameters:
    ///   - location_id: location's id
    ///   - name: new name
    static func changeLocationName(location_id: Int, name: String, sa_token: String) {
        let realm = try! Realm()
        if let result = realm.objects(LocationCache.self).filter("id = \(location_id) AND sa_user_token = '\(sa_token)'").first {
            try? realm.write {
                result.name = name
            }
        }
    }
    
    /// Delete the location
    /// - Parameter location_id: location_id
    static func deleteLocation(location_id: Int, sa_token: String) {
        let realm = try! Realm()
        if let result = realm.objects(LocationCache.self).filter("id = \(location_id) AND sa_user_token = '\(sa_token)'").first {
            let devices = realm.objects(DeviceCache.self).filter("location_id = \(location_id) AND sa_user_token = '\(sa_token)'")
            try? realm.write {
                realm.delete(result)
                realm.delete(devices)
            }
        }
    }
    
    static func setLocationOrder(area_id: String?, orderArray: [Int], sa_token: String) {
        let realm = try! Realm()
        let areaId: String
        if let area_id = area_id {
            areaId = "'\(area_id)'"
        } else {
            areaId = "nil"
        }
        for (idx, location_id) in orderArray.enumerated() {
            if let location = realm.objects(LocationCache.self).filter("area_id = \(areaId) AND id = \(location_id) AND sa_user_token = '\(sa_token)'").first {
                try! realm.write {
                    location.sort = idx
                }
            }
        }

    }
    
}
