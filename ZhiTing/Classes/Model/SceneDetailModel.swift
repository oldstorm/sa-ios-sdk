//
//  SceneDetailModel.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/21.
//

import UIKit

class SceneDetailModel: BaseModel {
    var id: Int?
    /// 场景名称
    var name = ""
    /// auto_run 为false时可不传，1满足所有，2满足任一
    var condition_logic: Int?
    /// true 为自动，false为手动
    var auto_run = false
    /// 生效时间类型，全天为1，时间段为2,auto_run为false可不传
    var time_period: Int?
    /// 生效开始时间,time_period为1时应传某天0点;auto_run为false可不传
    var effect_start_time: Int?
    /// 生效结束时间,time_period为1时应传某天24点;auto_run为false可不传
    var effect_end_time: Int?
    /// 重复执行的类型；1：每天; 2:工作日 ；3：自定义;auto_run为false可不传
    var repeat_type: Int?
    /// 只能传长度为7包含1-7的数字；"1122"视为不合法传参; repeat_type为0时:"1234567"; 1时:12345; 2时：任意
    var repeat_date = "1234567"
    /// 创建者id
    var creator_id: Int?
    /// 创建时间
    var create_at: Int?
    
    /// 是否开启
    var is_on: Bool?
    /// 触发条件
    var scene_conditions = [SceneCondition]()
    /// 执行任务
    var scene_tasks = [SceneTask]()
    
    
    /// 要移除的触发条件 （编辑时)s
    var del_condition_ids: [Int]?
    
    /// 要移除的任务 （编辑时)
    var del_task_ids: [Int]?
}


class SceneCondition: BaseModel {
    var id: Int?
    /// 1:定时；2：设备状态变化时 0: 手动 （用于view展示）
    var condition_type = 0
    /// condition_type为1时必传
    var timing: Int?
    /// condition_type为2时需传
    var device_id: Int?
    /// 设备信息
    var device_info: SceneDetailDeviceInfo?
    /// 触发条件为设备时对应的设备属性变化
    var condition_attr: SceneDeviceControlAction?
    /// ">","<","=";  操作符，condition_type为2时需传
    var `operator`: String?
    
    /// 场景条件展示的 名称+数值
    var displayAction: String {
        guard let controlAction = condition_attr else { return "" }

        switch controlAction.controlActionType {
        case .power:
            guard let action_val = controlAction.val as? String else { return " " }
            if action_val == "on" {
                return "打开".localizedString
            } else if action_val == "off" {
                return "关闭".localizedString
            } else {
                return "开关切换".localizedString
            }
        case .brightness:
            guard
                let val = controlAction.val as? Int,
                let max = controlAction.max as? Int,
                let min = controlAction.min as? Int
            else { return " " }
            let valDouble = Float(val)
            let maxDouble = Float(max)
            let minDouble = Float(min)

            
            let percent = String(format: "%d", lroundf((valDouble - minDouble) / (maxDouble - minDouble) * 100)) + "%"
            
            var str = ""
            if `operator` == ">" {
                str +=  "大于".localizedString
            } else if `operator` == "=" {
                str += "等于".localizedString
            } else if `operator` == "<" {
                str += "小于".localizedString
            }

            return "亮度".localizedString + str + percent
            
        case .color_temp:
            guard
                let val = controlAction.val as? Int,
                let max = controlAction.max as? Int,
                let min = controlAction.min as? Int
            else { return " " }
            let valDouble = Float(val)
            let maxDouble = Float(max)
            let minDouble = Float(min)

            
            let percent = String(format: "%d", lroundf((valDouble - minDouble) / (maxDouble - minDouble) * 100)) + "%"
            
            var str = ""
            if `operator` == ">" {
                str +=  "大于".localizedString
            } else if `operator` == "=" {
                str += "等于".localizedString
            } else if `operator` == "<" {
                str += "小于".localizedString
            }
            return "色温".localizedString + str + percent
            
        case .curtain_location:
            guard
                let val = controlAction.val as? Int,
                let max = controlAction.max as? Int,
                let min = controlAction.min as? Int
            else { return " " }
            let valDouble = Float(val)
            let maxDouble = Float(max)
            let minDouble = Float(min)

            
            let percent = String(format: "%d", lroundf((valDouble - minDouble) / (maxDouble - minDouble) * 100)) + "%"
            
            var str = ""
            if `operator` == ">" {
                str +=  "大于".localizedString
            } else if `operator` == "=" {
                str += "等于".localizedString
            } else if `operator` == "<" {
                str += "小于".localizedString
            }
            return "打开百分比".localizedString + str + percent
            
        case .none:
            return " "
        }
        
    }

    
}



class SceneTask: BaseModel {
    var id: Int?
    var scene_id: Int?
    /// 可不传，延迟秒数
    var delay_seconds: Int?
    /// 1:控制设备；2:手动执行; 3:开启自动执行; 4:关闭自动执行
    var type = 0
    /// 被控制的场景id type为smart_device时可不传
    var control_scene_id: Int?
    /// 被的控制场景信息
    var control_scene_info: SceneTaskControlSceneInfo?
    
    /// 设备信息
    var device_info: SceneDetailDeviceInfo?
    
    /// 设备id
    var device_id: Int?

    /// 控制设备时，对应的设备操作 type为smart_device时，必须设置
    var attributes: [SceneDeviceControlAction]?
 
}




class SceneDeviceControlAction: BaseModel {
    enum ControlActionType: String {
        /// 开关
        case power
        /// 亮度
        case brightness
        /// 色温
        case color_temp
        /// 窗帘位置
        case curtain_location

        case none
    }
    
    var id: Int?
    
    var scene_task_id: Int?
    
    var scene_condition_id: Int?
    

    /// 动态类型
    var val: Any?
    
    /// val_type为数字是表示该值最小值
    var min: Any?
    
    /// val_type为数字是表示该值最大值
    var max: Any?
    
    /// bool,int,string,float64
    var val_type = "bool"
    
    /// 开关："switch"; 色温"color_temp"; 亮度:"brightness"
    var attribute = ""
    
    var instance_id = 0
    
    var controlActionType: ControlActionType {
        return ControlActionType(rawValue: attribute) ?? .none
    }
    
    /// 展示actionName
    var actionName: String {
        switch controlActionType {
        case .power:
            return "开关".localizedString
        case .brightness:
            return "亮度".localizedString
        case .color_temp:
            return  "色温".localizedString
        case .curtain_location:
            return "窗帘打开".localizedString
        default:
            return ""
        }
    }
    
    
    
    /// val展示的数值
    var displayActionValue: String {
        switch controlActionType {
        case .power:
            guard let action_val = val as? String else { return " " }
            if action_val == "on" {
                return "打开".localizedString
            } else if action_val == "off" {
                return "关闭".localizedString
            } else {
                return "开关切换".localizedString
            }
        case .brightness:
            guard
                let val = val as? Int,
                let max = max as? Int,
                let min = min as? Int
            else { return " " }
            let valDouble = Float(val)
            let maxDouble = Float(max)
            let minDouble = Float(min)

            
            return String(format: "%d", lroundf((valDouble - minDouble) / (maxDouble - minDouble) * 100)) + "%"
            
        case .color_temp:
            guard
                let val = val as? Int,
                let max = max as? Int,
                let min = min as? Int
            else { return " " }
            let valDouble = Float(val)
            let maxDouble = Float(max)
            let minDouble = Float(min)

            
            return String(format: "%d", lroundf((valDouble - minDouble) / (maxDouble - minDouble) * 100)) + "%"
            
        case .curtain_location:
            guard
                let val = val as? Int,
                let max = max as? Int,
                let min = min as? Int
            else { return " " }
            let valDouble = Float(val)
            let maxDouble = Float(max)
            let minDouble = Float(min)

            
            return String(format: "%d", lroundf((valDouble - minDouble) / (maxDouble - minDouble) * 100)) + "%"
            
        case .none:
            return " "
        }
        
    }
    
}

class SceneDetailDeviceInfo: BaseModel {
    /// 设备名称
    var name: String = ""
    /// 设备位置
    var location_name: String = ""
    /// 设备图片
    var logo_url = ""
    
    /// 设备状态 1正常 2被删除
    var status = 1
}

class SceneTaskControlSceneInfo: BaseModel {
    /// 被控制的场景名称
    var name: String = ""
    /// 场景状态;1正常,2被删除
    var status = 1
}
