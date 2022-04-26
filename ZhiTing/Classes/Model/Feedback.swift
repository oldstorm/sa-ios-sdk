//
//  Feedback.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/22.
//

import Foundation

class Feedback: BaseModel {
    var id = 0
    /// 类型(1:遇到问题 2:提建议)
    var feedback_type = 1
    /// 分类
    /// (1: 应用问题  2: 注册和登录问题  3: 用户数据问题 4: 设备问题
    ///  5: 场景问题 6: 其他问题 7: 应用功能建议 8: 设备功能建议 9: 场景功能建议 10: 其他功能建议)
    var type = 1
    /// 创建时间
    var created_at = 0
    /// 联系方式
    var contact_information = ""
    /// 是否同意获取信息
    var is_auth = false
    /// 描述
    var description = ""
    /// 设备型号
    var phone_model = ""
    
    var files: [FileModel]?
    
    /// --
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(created_at)))
    }
    
    var feedbackType: FeedbackType? {
        if feedback_type == 1 {
            return .problem(category: FeedbackProblemCategory(rawValue: type))
        } else if feedback_type == 2 {
            return .suggestion(category: FeedbackSuggestionCategory(rawValue: type))
        } else {
            return nil
        }
    }

}

enum FeedbackType {
    /// 遇到问题
    case problem(category: FeedbackProblemCategory?)
    /// 提建议/意见
    case suggestion(category: FeedbackSuggestionCategory?)
    
    var title: String {
        switch self {
        case .problem(let category):
            return "遇到问题".localizedString + ": \(category?.title ?? "")"
        case .suggestion(let category):
            return "提建议/意见".localizedString + ": \(category?.title ?? "")" 
        }
    }
    
    /// 是否选择了子分类
    var selectedSubType: Bool {
        switch self {
        case .problem(let category):
            return category != nil
        case .suggestion(let category):
            return category != nil
        }
    }
}

enum FeedbackProblemCategory: Int, CaseIterable {
    /// 应用问题
    case application = 1
    /// 注册与登录问题
    case account = 2
    /// 用户数据问题
    case data = 3
    /// 设备问题
    case device = 4
    /// 场景问题
    case scene = 5
    /// 其他问题
    case other = 6
    
    var title: String {
        switch self {
        case .application:
            return "应用问题".localizedString
        case .account:
            return "注册与登录问题".localizedString
        case .data:
            return "用户数据问题".localizedString
        case .device:
            return "设备问题".localizedString
        case .scene:
            return "场景问题".localizedString
        case .other:
            return "其他问题".localizedString
        }
    }

}

enum FeedbackSuggestionCategory: Int, CaseIterable {
    /// 应用功能建议
    case application = 7
    /// 设备功能建议
    case device = 8
    /// 场景功能建议
    case scene = 9
    /// 其他意见与建议
    case other = 10
    
    var title: String {
        switch self {
        case .application:
            return "应用功能建议".localizedString
        case .device:
            return "设备功能建议".localizedString
        case .scene:
            return "场景功能建议".localizedString
        case .other:
            return "其他意见与建议".localizedString
        }
    }

}
