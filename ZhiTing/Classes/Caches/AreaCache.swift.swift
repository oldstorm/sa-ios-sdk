//
//  AreaCache.swift.swift
//  ZhiTing
//
//  Created by iMac on 2021/12/28.
//

import Foundation
import RealmSwift

// MARK: - AreaCache
class AreaCache: Object {
    /// According SA's Token
    @Persisted var sa_user_token = ""
    
    /// area's id
    @Persisted var id: String?

    /// area's name
    @Persisted var name = ""
    
    /// 类型 1家庭 2公司
    @Persisted var area_type = 1
    
    /// 家庭在对应SA下的user_id
    @Persisted var sa_user_id = 0
    
    /// 家庭是否绑定SA
    @Persisted var is_bind_sa = false
    
    /// sa的wifi名称
    @Persisted var ssid: String?
    
    /// sa的id
    @Persisted var sa_id: String?
    
    /// sa的地址
    @Persisted var sa_lan_address: String?
    
    /// sa的mac地址
    @Persisted var bssid: String?
    
    /// 是否已经设置SA专业版账号
    @Persisted var setAccount = false
    
    /// SA专业版账号名
    @Persisted var accountName: String?
    
    /// 云端用户的user_id
    @Persisted var cloud_user_id = 0
    
    /// 是否需要重新将SA绑定云端
    @Persisted var needRebindCloud = false
    
    func transferToArea() -> Area {
        let area = Area()
        area.id = id
        area.name = name
        area.area_type = area_type
        area.sa_user_token = sa_user_token
        area.sa_user_id = sa_user_id
        area.is_bind_sa = is_bind_sa
        area.ssid = ssid
        area.sa_id = sa_id
        area.sa_lan_address = sa_lan_address
        area.bssid = bssid
        area.setAccount = setAccount
        area.cloud_user_id = cloud_user_id
        area.needRebindCloud = needRebindCloud
        return area
    }
    
    
    static func cacheArea(areaCache: AreaCache) {
        let realm = try! Realm()
        let areaId: String
        let filterContent: String

        if let value = areaCache.id {
            areaId = "\(value)"
            filterContent = "id = '\(areaId)'"
        } else {
            areaId = "nil"
            filterContent = "id = \(areaId) AND sa_user_token = '\(areaCache.sa_user_token)'"
        }

        if let area = realm.objects(AreaCache.self).filter(filterContent).first {
            try? realm.write {
                area.sa_user_id = areaCache.sa_user_id
                area.sa_user_token = areaCache.sa_user_token
                area.name = areaCache.name
                area.area_type = areaCache.area_type
                area.setAccount = areaCache.setAccount
                area.cloud_user_id = areaCache.cloud_user_id
                area.needRebindCloud = areaCache.needRebindCloud
                if let ssid = areaCache.ssid {
                    area.ssid = ssid
                }
                
                if let sa_id = areaCache.sa_id {
                    area.sa_id = sa_id
                }
                
                if let sa_addr = areaCache.sa_lan_address, sa_addr != "" {
                    area.sa_lan_address = sa_addr
                }
                
                if let bssid = areaCache.bssid {
                    area.bssid = bssid
                }
                       
            }
        } else {
            try? realm.write {
                realm.add(areaCache)
            }
        }
        
    }
    
    /// cache & update areas cache from api
    /// - Parameter areas: areas from api
    static func cacheAreas(areas: [Area], needRemove: Bool = true) {
        let realm = try! Realm()
        
        let cacheIds = areas.map(\.id)
        
        if needRemove {
            let removeAreas = AreaCache.areaList().filter({ !cacheIds.contains($0.id) && !$0.needRebindCloud })
            removeAreas.forEach {
                AreaCache.removeArea(area: $0)
            }
        }
        
        

        
        try? realm.write {
            areas.forEach {
                let areaId: String
                if let area_id = $0.id {
                    areaId = "'\(area_id)'"
                } else {
                    areaId = "nil"
                }

                if let cache = realm.objects(AreaCache.self).filter("id = \(areaId)").first {
                    cache.name = $0.name
                    cache.area_type = $0.area_type
                    cache.sa_user_id = $0.sa_user_id
                    cache.cloud_user_id = $0.cloud_user_id
                    cache.is_bind_sa = $0.is_bind_sa
                    
                    if $0.sa_user_token != "" {
                        cache.sa_user_token = $0.sa_user_token
                    }
                    if let sa_addr = $0.sa_lan_address, sa_addr != "" {
                        cache.sa_lan_address = sa_addr
                    }
                    
                    
                    if let sa_id = $0.sa_id {
                        cache.sa_id = sa_id
                    }
                    
                    
                } else {
                    let cache = AreaCache()
                    cache.name = $0.name
                    cache.id = $0.id
                    cache.area_type = $0.area_type
                    cache.sa_user_id = $0.sa_user_id
                    cache.is_bind_sa = $0.is_bind_sa
                    cache.cloud_user_id = $0.cloud_user_id
                    
                    if $0.sa_user_token != "" {
                        cache.sa_user_token = $0.sa_user_token
                    }
                    
                    if let sa_addr = $0.sa_lan_address, sa_addr != "" {
                        cache.sa_lan_address = sa_addr
                    }
                    
                    if let sa_id = $0.sa_id {
                        cache.sa_id = sa_id
                    }
                    
                    
                    
                    realm.add(cache)
                }

                
                
            }
        }
        
    }
    
    
    /// Create Area
    /// - Parameters:
    ///   - name: area's name
    ///   - areas_name: names of areas
    @discardableResult
    static func createArea(name: String, locations_name: [String], sa_token: String, cloud_user_id: Int = 0, mode: Area.AreaType) -> AreaCache {
        let area = AreaCache()
        area.sa_user_token = sa_token
        area.name = name
        area.area_type = mode.rawValue
        area.cloud_user_id = cloud_user_id
        
        let realm = try! Realm()
        try? realm.write {
            realm.add(area)
        }
        
        var id = 1
        let locations = locations_name.map { name -> LocationCache in
            let location = LocationCache()
            location.sa_user_token = sa_token
            location.id = id
            location.name = name
            id = id + 1
            return location
        }
        
        try? realm.write {
            locations.forEach {
                realm.add($0)
            }
        }
        
        return area

    }
    
    /// Delete a area from cache
    /// - Parameter area_id: area_id
    static func deleteArea(id: String?, sa_token: String) {
        let realm = try! Realm()
        
        let areaId: String
        if let area_id = id {
            areaId = "'\(area_id)'"
        } else {
            areaId = "nil"
        }

        if let area = realm.objects(AreaCache.self).filter("id = \(areaId) AND sa_user_token = '\(sa_token)'").first {
            let scenes = realm.objects(SceneCache.self).filter("area_id = \(areaId)")
            let scenesItems = realm.objects(SceneItemCache.self).filter("area_id = \(areaId)")
            let locations = realm.objects(LocationCache.self).filter("area_id = \(areaId) AND sa_user_token = '\(sa_token)'")
            let devices = realm.objects(DeviceCache.self).filter("area_id = \(areaId) AND sa_user_token = '\(sa_token)'")
            try? realm.write {
                realm.delete(area)
                realm.delete(locations)
                realm.delete(scenes)
                realm.delete(scenesItems)
                realm.delete(devices)
            }

        }
    }
    
    static func removeArea(area: Area) {
        let realm = try! Realm()
        let areaId: String
        if let area_id = area.id {
            areaId = "'\(area_id)'"
        } else {
            areaId = "nil"
        }

        if let area = realm.objects(AreaCache.self).filter("id = \(areaId)").first {
            let locations = realm.objects(LocationCache.self).filter("area_id = \(areaId)")
            let devices = realm.objects(DeviceCache.self).filter("area_id = \(areaId)")
            try? realm.write {
                realm.delete(area)
                realm.delete(locations)
                realm.delete(devices)
            }

        }
    }
    
    static func removeArea(by id: String?) {
        let realm = try! Realm()
        let areaId: String
        guard let area_id = id else {
            return
        }
        areaId = "'\(area_id)'"
        if let area = realm.objects(AreaCache.self).filter("id = \(areaId)").first {
            let locations = realm.objects(LocationCache.self).filter("area_id = \(areaId)")
            let devices = realm.objects(DeviceCache.self).filter("area_id = \(areaId)")
            try? realm.write {
                realm.delete(area)
                realm.delete(locations)
                realm.delete(devices)
            }

        }
    }
    
    /// 移除所有无实体sa家庭，清空实体sa家庭与云端关系
    static func removeAllCloudArea() {
        let realm = try! Realm()
        let cloudAreas = realm.objects(AreaCache.self).filter("is_bind_sa = false")
        let bindedAreas = realm.objects(AreaCache.self).filter("is_bind_sa = true")
        cloudAreas.forEach { area in
            deleteArea(id: area.id, sa_token: area.sa_user_token)
        }
        
        bindedAreas.forEach { area in
            try? realm.write {
                area.cloud_user_id = -1
                area.needRebindCloud = false
            }
        }
        
        
        

    }
    
    /// Change a area's name
    /// - Parameters:
    ///   - area_id: area_id
    ///   - name: new name
    static func changeAreaName(id: String?, name: String, sa_token: String) {
        let realm = try! Realm()
        
        let areaId: String
        if let area_id = id {
            areaId = "'\(area_id)'"
        } else {
            areaId = "nil"
        }

        if let area = realm.objects(AreaCache.self).filter("id = \(areaId) AND sa_user_token = '\(sa_token)'").first {
            try? realm.write {
                area.name = name
            }
        }
    }
    
    /// Area List
    /// - Returns: [Area]
    static func areaList() -> [Area] {
        let realm = try! Realm()
        var areaArray = [Area]()
        let result = realm.objects(AreaCache.self)
        result.forEach {
            areaArray.append($0.transferToArea())
        }
        
        return areaArray
    }
    
    /// Area Detail
    /// - Parameter id: area_id
    /// - Returns: (name: String, locations_count: Int)
    static func areaDetail(id: String?, sa_token: String) -> (name: String, locations_count: Int) {
        let realm = try! Realm()
        
        let areaId: String
        if let area_id = id {
            areaId = "'\(area_id)'"
        } else {
            areaId = "nil"
        }

        if let area = realm.objects(AreaCache.self).filter("id = \(areaId) AND sa_user_token = '\(sa_token)'").first {
            let locations_count = realm.objects(LocationCache.self).filter("area_id = \(areaId) AND sa_user_token = '\(sa_token)'").count
            return (area.name, locations_count)
        }
        
        return ("", 0)
    }
    
    
}
