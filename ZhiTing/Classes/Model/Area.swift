//
//  Area.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/17.
//

import Foundation
import HandyJSON

class Area: NSObject, HandyJSON {
    /// Area's id
    var id: String?
    
    /// Area's name
    var name = ""
    
    /// isbind smartAssistant
    var is_bind_sa: Bool = false
    
    /// smartAssistant's user_id
    var sa_user_id = 1
    
    /// smartAssistant's token
    var sa_user_token = ""
    
    /// sa的wifi名称
    var ssid: String?
    
    /// sa的id
    var sa_id: String?
    
    /// sa的地址
    var sa_lan_address: String?
    
    /// sa的mac地址
    var bssid: String?
    
    /// 是否已经设置sa专业版账号
    var setAccount: Bool?
    
    /// sa专业版账号名
    var accountName: String?
    
    /// 云端用户的user_id
    var cloud_user_id = -1
    
    /// 是否需要重新将SA绑定云端
    var needRebindCloud = false
    
    /// 是否允许找回凭证
    var isAllowedGetToken = true
    
    /// Area类型 (家庭、公司等)
    var area_type = 1
    
    /// 扩展应用
    var extensions: [String]?
    
    /// 是否绑定云端
    var is_bind_cloud: Bool?
    
    required override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(updateProperty(_:)), name: .init(rawValue: "AreaUpdate"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func updateProperty(_ noti: Notification) {
        guard let json = noti.object as? String, let info = Area.deserialize(from: json) else { return }
        if info.id == self.id && info.sa_lan_address != self.sa_lan_address && self.bssid != NetworkStateManager.shared.getWifiBSSID() {
            self.sa_lan_address = info.sa_lan_address
            self.bssid = info.bssid
            self.ssid = info.ssid
        }
    }

    func toAreaCache() -> AreaCache {
        let cache = AreaCache()
        cache.id = id
        cache.name = name
        cache.sa_user_token = sa_user_token
        cache.sa_id = sa_id
        cache.sa_user_id = sa_user_id
        cache.is_bind_sa = is_bind_sa
        cache.ssid = ssid
        cache.sa_lan_address = sa_lan_address
        cache.area_type = area_type
        cache.bssid = bssid
        cache.cloud_user_id = cloud_user_id
        cache.needRebindCloud = needRebindCloud
        if let is_set_password = setAccount {
            cache.setAccount = is_set_password
        }
        
    
        return cache
    }
    
    private lazy var mutex = DispatchSemaphore(value: 1)

    
    /// 临时通道地址
    var temporaryIP: String {
        set { //avoid data race
            mutex.wait()
            self._temporaryIP = newValue
            mutex.signal()
        }
        
        get {
            _temporaryIP
        }
    }
    
    private var _temporaryIP: String = "http://"
    
    /// 请求的地址url(判断请求sa还是sc)
    var requestURL: String {
        if bssid == NetworkStateManager.shared.getWifiBSSID() && bssid != nil {//局域网
            return sa_lan_address ?? "http://"
        } else if UserManager.shared.isLogin && id != nil {
            return temporaryIP
        } else {
            return sa_lan_address ?? "http://"
        }
    }

    

}

extension Area {
    enum AreaType: Int {
        case family = 1
        case company = 2
    }
    
    var areaType: AreaType {
        return AreaType(rawValue: area_type) ?? .family
    }
    
    override var description: String {
        return self.toJSONString(prettyPrint: true) ?? ""
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
        var departments = [LocationSyncModel]()
    }
}
