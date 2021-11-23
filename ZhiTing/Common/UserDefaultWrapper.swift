//
//  UserDefaultWrapper.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/11.
//

import Foundation


@propertyWrapper
struct UserDefaultWrapper<T> {
    let userDefaultKey: UserDefaultKey
    
    var wrappedValue: T? {
        get {
            UserDefaults.standard.value(forKey: userDefaultKey.key) as? T
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: userDefaultKey.key)
        }
    }
    
    init(key: UserDefaultKey) {
        self.userDefaultKey = key
    }
   
}

@propertyWrapper
struct UserDefaultBool {
    let userDefaultKey: UserDefaultKey
    
    var wrappedValue: Bool {
        get {
            UserDefaults.standard.bool(forKey: userDefaultKey.key)
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: userDefaultKey.key)
        }
    }
    
    init(key: UserDefaultKey) {
        self.userDefaultKey = key
    }
   
}





enum UserDefaultKey {
    /// 是否登录 Bool
    case isLogin
    /// 是否同意用户协议 Bool
    case isAgreePrivacy
    /// 历史wifi列表 String
    case wifiHistoryList
    /// 证书信任 Data
    case certificate(url: String)
    /// 插件 String
    case plugin(id: String)
    
    var key: String {
        switch self {
        case .isLogin:
            return "zhiting.userDefault.isLogin"
        case .isAgreePrivacy:
            return "zhiting.userDefault.isAgreePrivacy"
        case .wifiHistoryList:
            return "zhiting.userDefault.wifiHistoryList"
        case .certificate(let url):
            return "zhiting.userDefault.certificate.\(url)"
        case .plugin(let id):
            return "zhiting.userDefault.plugin.\(id)"
        }
    }
    
    
}
