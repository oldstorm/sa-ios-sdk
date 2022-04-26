//
//  DoorLockUserType.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/19.
//

import Foundation

enum DoorLockUserType: CaseIterable {
    case root
    case normal
    case visitor
    case threaten
    
    var title: String {
        switch self {
        case .root:
            return "管理员".localizedString
        case .normal:
            return "普通用户".localizedString
        case .visitor:
            return "常访客".localizedString
        case .threaten:
            return "胁迫用户".localizedString
        }
    }
}
