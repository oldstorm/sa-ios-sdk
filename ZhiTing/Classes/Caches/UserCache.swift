//
//  LocalCache.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/30.
//
import RealmSwift
import Foundation


// MARK: - UserCache
class UserCache: Object {
    @Persisted var nickname = ""
    @Persisted var phone = ""
    @Persisted var avatar_url = ""
    @Persisted var user_id = 0
    
    /// 更新用户信息
    /// - Parameter user: 用户数据
    static func update(from user: User) {
        //创建一个Realm对象
        let realm = try! Realm()
        
        if let userCache = realm.objects(UserCache.self).first {
            try? realm.write {
                if user.nickname != "" {
                    userCache.nickname = user.nickname
                }
                userCache.avatar_url = user.avatar_url
                userCache.phone = user.phone
                userCache.user_id = user.user_id
            }
        } else {
            let userCache = UserCache()
            if user.nickname != "" {
                userCache.nickname = user.nickname
            }
            userCache.user_id = user.user_id
            userCache.avatar_url = user.avatar_url
            userCache.phone = user.phone
            try? realm.write {
                realm.add(userCache)
            }
        }
    }
    
    static func getUsers() -> [User] {
        let realm = try! Realm()
        var users = [User]()
        let userCaches = realm.objects(UserCache.self)
        userCaches.forEach {
            let user = User()
            user.nickname = $0.nickname
            user.avatar_url = $0.avatar_url
            user.phone = $0.phone
            user.user_id = $0.user_id
            users.append(user)
        }
        
        return users
    }

}
