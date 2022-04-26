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
    /// SA离线帮助
    case offlineHelp
    /// 客户关系管理
    case crm(token: String)
    /// 供应链管理
    case scm(token: String)

    
    var link: String {
        switch self {
        case .proEdition:
            return AuthManager.shared.currentArea.requestURL
        case .thirdParty:
            return "\(cloudUrl)/#/third-platform/"
        case .privacy:
            return "\(cloudUrl)/smartassitant/protocol/privacy/"
        case .userAgreement:
            return "\(cloudUrl)/smartassitant/protocol/user/"
        case .offlineHelp:
            return "\(cloudUrl)/#/help/out-line?type=sa"
        case .crm(let token):
            return AuthManager.shared.currentArea.requestURL + "/crm/#/?crmToken=\(token)"
        case .scm(let token):
            return AuthManager.shared.currentArea.requestURL + "/scm/#/?scmToken=\(token)"
        }
    }
    
    var webViewTitle: String {
        switch self {
        case .proEdition:
            return "专业版".localizedString
        case .thirdParty:
            return "第三方平台".localizedString
        case .privacy:
            return "隐私政策".localizedString
        case .userAgreement:
            return "用户协议".localizedString
        case .offlineHelp:
            return "离线帮助".localizedString
        case .crm:
            return "客户关系管理".localizedString
        case .scm:
            return "供应链管理".localizedString
        }
    }
}
