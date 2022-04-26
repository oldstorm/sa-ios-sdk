//
//  SceneCache.swift
//  ZhiTing
//
//  Created by iMac on 2021/12/28.
//

import Foundation
import RealmSwift

// MARK: - SceneCache
class SceneCache: Object {
    @Persisted var area_id: String?
    /// According SA's Token
    @Persisted var sa_user_token = ""
    //场景ID
    @Persisted var id = 0
    //场景名称
    @Persisted var name = ""
    //修改场景状态权限
    @Persisted var control_permission = false
    //自动场景是否启动
    @Persisted var is_on = false
    //执行任务列表
//    @objc dynamic var items = [SceneItemModel]()
    //触发条件
//    @objc dynamic var condition = SceneConditionModel()
    //触发条件类型;1为定时任务, 2为设备
    @Persisted var type = 0
    //触发条件为设备时返回设备图片url
    @Persisted var logo_url = ""
    //设备状态:1正常2已删除3离线
    @Persisted var status = 0
    //是否自动
    @Persisted var is_auto = 0

    
    func transformToDevice() -> SceneTypeModel {
        let scene = SceneTypeModel()
        scene.id = id
        scene.name = name
        scene.control_permission = control_permission
        scene.is_on = is_on
        scene.condition.type = type
        scene.condition.logo_url = logo_url
        scene.condition.status = status
        scene.items = SceneItemCache.sceneItemsList(area_id: area_id, sa_token: sa_user_token, scene_id: id)
        return scene
    }
    
    /// Cache devices
    /// - Parameter SceneItems: [SceneItemModel]
    /// - Parameter sa_token: String
    static func cacheScenes(scenes: [SceneTypeModel], area_id: String?, sa_token: String, is_auto: Int) {
        let realm = try! Realm()
        let SceneCaches = scenes.map { scene -> SceneCache in
            let Scene_cache = SceneCache()
            Scene_cache.id = scene.id
            Scene_cache.name = scene.name
            Scene_cache.control_permission = scene.control_permission
            Scene_cache.is_on = scene.is_on
            Scene_cache.type = scene.condition.type
            Scene_cache.logo_url = scene.condition.logo_url
            Scene_cache.status = scene.condition.status
            Scene_cache.area_id = area_id
            Scene_cache.sa_user_token = sa_token
            Scene_cache.is_auto = is_auto
            //存储items
            SceneItemCache.cacheSceneItems(sceneItems: scene.items, area_id: area_id, sa_token: sa_token, scene_id: scene.id)
            return Scene_cache
        }
        
        let areaId: String
        if let area_id = area_id {
            areaId = "'\(area_id)'"
        } else {
            areaId = "nil"
        }

        let caches = realm.objects(SceneCache.self).filter("area_id = \(areaId) AND sa_user_token = '\(sa_token)' AND is_auto = \(is_auto)")
        try? realm.write {
            realm.delete(caches)
            realm.add(SceneCaches)
        }
    }

    
    /// Retrieve devices by area_id
    /// - Parameter area_id: area_id
    /// - Returns: [SceneItemModel]
    static func sceneList(area_id: String?, sa_token: String,is_auto: Int) -> [SceneTypeModel] {
        let realm = try! Realm()
        var sceneArray = [SceneTypeModel]()
        
        let areaId: String
        if let area_id = area_id {
            areaId = "'\(area_id)'"
        } else {
            areaId = "nil"
        }

        let result = realm.objects(SceneCache.self).filter("area_id = \(areaId) AND sa_user_token = '\(sa_token)' AND is_auto = \(is_auto)")
        result.forEach {
            sceneArray.append($0.transformToDevice())
        }
        return sceneArray
    }
    
}
// MARK: - SceneItemCache
class SceneItemCache: Object {
    /// According SA's Token
    @Persisted var sa_user_token = ""
    /// device's id
    @Persisted var area_id: String?
    //执行任务类型;1为设备,2为场景
    @Persisted var type = 0
    //设备图片
    @Persisted var logo_url = ""
    //设备状态;1为正常,2为已删除,3为离线
    @Persisted var status = 0
    //是否自动类型
    @Persisted var scene_id = 0

    
    func transformToDevice() -> SceneItemModel {
        let device = SceneItemModel()
        device.type = type
        device.logo_url = logo_url
        device.status = status
        return device
    }
    
    /// Cache devices
    /// - Parameter SceneItems: [SceneItemModel]
    /// - Parameter sa_token: String
    static func cacheSceneItems(sceneItems: [SceneItemModel], area_id: String?, sa_token: String, scene_id: Int) {
        let realm = try! Realm()
        let itemCaches = sceneItems.map { sceneItem -> SceneItemCache in
            let itemCache = SceneItemCache()
            itemCache.type = sceneItem.type
            itemCache.status = sceneItem.status
            itemCache.logo_url = sceneItem.logo_url
            itemCache.area_id = area_id
            itemCache.sa_user_token = sa_token
            itemCache.scene_id = scene_id
            return itemCache
        }
        
        let areaId: String
        if let area_id = area_id {
            areaId = "'\(area_id)'"
        } else {
            areaId = "nil"
        }

        let caches = realm.objects(SceneItemCache.self).filter("area_id = \(areaId) AND sa_user_token = '\(sa_token)' AND scene_id = \(scene_id)")
        
        try? realm.write {
            realm.delete(caches)
            realm.add(itemCaches)
        }
        
    }

    
    /// Retrieve devices by area_id
    /// - Parameter area_id: area_id
    /// - Returns: [SceneItemModel]
    static func sceneItemsList(area_id: String?, sa_token: String, scene_id: Int) -> [SceneItemModel] {
        let realm = try! Realm()
        var itemArray = [SceneItemModel]()
        
        let areaId: String
        if let area_id = area_id {
            areaId = "'\(area_id)'"
        } else {
            areaId = "nil"
        }

        let result = realm.objects(SceneItemCache.self).filter("area_id = \(areaId) AND sa_user_token = '\(sa_token)' AND scene_id = \(scene_id)")
        result.forEach {
            itemArray.append($0.transformToDevice())
        }
        return itemArray
    }
}
