//
//  LinkEnum.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/11.
//

import Foundation

/// WebView地址枚举类
enum LinkEnum {
    /// 专业版
    case proEdition
    /// 第三方平台
    case thirdParty
    /// 隐私政策
    case privacy
    /// 用户协议
    case userAgreement
    
    
    var link: String {
        switch self {
        case .proEdition:
            return AuthManager.shared.currentArea.sa_lan_address ?? "http://unkown"
        case .thirdParty:
            return "\(cloudUrl)/#/third-platform"
        case .privacy:
            return "\(cloudUrl)/smartassitant/protocol/privacy"
        case .userAgreement:
            return "\(cloudUrl)/smartassitant/protocol/user"
        }
    }
}
