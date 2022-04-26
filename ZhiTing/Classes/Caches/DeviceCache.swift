//
//  DeviceCache.swift
//  ZhiTing
//
//  Created by iMac on 2021/12/28.
//

import Foundation
import RealmSwift

// MARK: - DeviceCache
class DeviceCache: Object {
    /// According SA's Token
    @Persisted var sa_user_token = ""
    /// device's id
    @Persisted var id: Int = -1
    /// device's name
    @Persisted var name = ""
    /// device's type
    @Persisted var model = ""
    /// device's brand id
    @Persisted var brand_id = ""
    /// device's logo
    @Persisted var logo_url = ""
    
    @Persisted var identity = ""
    
    @Persisted var plugin_id = ""
    
    @Persisted var area_id: String?
    
    @Persisted var location_id: Int?
    
    @Persisted var department_id: Int?
    
    @Persisted var is_sa = false
    
    func transformToDevice() -> Device {
        let device = Device()
        device.id = id
        device.name = name
        device.model = model
        device.brand_id = brand_id
        device.location_id = location_id
        device.department_id = department_id
        device.area_id = area_id
        device.plugin_id = plugin_id
        device.iid = identity
        device.logo_url = logo_url
        device.sa_user_token = sa_user_token
        device.is_sa = is_sa
        return device
    }
    
    
    /// Cache devices
    /// - Parameter homeDevices: [Device]
    /// - Parameter sa_user_token: String
    static func cacheHomeDevices(homeDevices: [Device], area_id: String?, sa_token: String) {
        let realm = try! Realm()
        let deviceCaches = homeDevices.map { homeDevice -> DeviceCache in
            let device = DeviceCache()
            device.id = homeDevice.id
            device.name = homeDevice.name
            device.logo_url = homeDevice.logo_url
            device.plugin_id = homeDevice.plugin_id
            device.location_id = homeDevice.location_id
            device.department_id = homeDevice.department_id
            device.area_id = area_id
            device.is_sa = homeDevice.is_sa
            device.sa_user_token = sa_token
            
            return device
        }
        
        let areaId: String
        if let area_id = area_id {
            areaId = "'\(area_id)'"
        } else {
            areaId = "nil"
        }
        
        let caches = realm.objects(DeviceCache.self).filter("area_id = \(areaId) AND sa_user_token = '\(sa_token)'")
        
        try? realm.write {
            realm.delete(caches)
            realm.add(deviceCaches)
        }
        
    }
    
    /// Retrieve home devices in the specific area
    /// - Parameters:
    ///   - area_id: area_id
    ///   - sa_token: sa_token
    /// - Returns: [HomeDevice]
    static func getAreaHomeDevices(area_id: String?, sa_token: String) -> [Device] {
        let realm = try! Realm()
        var homeDevices = [Device]()
        
        let areaId: String
        if let area_id = area_id {
            areaId = "'\(area_id)'"
        } else {
            areaId = "nil"
        }

        let caches = realm.objects(DeviceCache.self).filter("area_id = \(areaId) AND sa_user_token = '\(sa_token)'")
        
        caches.forEach {
            let device = Device()
            device.id = $0.id
            device.name = $0.name
            device.logo_url = $0.logo_url
            device.plugin_id = $0.plugin_id
            device.location_id = $0.location_id
            device.area_id = $0.area_id
            device.is_sa = $0.is_sa
            homeDevices.append(device)
        }

        return homeDevices
    }
    



}
