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
            
        case .on_off:
            guard let action_val = controlAction.val as? String else { return " " }
            if action_val == "on" {
                return "打开".localizedString
            } else if action_val == "off" {
                return "关闭".localizedString
            } else {
                return "开关切换".localizedString
            }
            
        case .switch_event:
            guard let action_val = controlAction.val as? Int else { return " " }
            if action_val == 0 {
                return "单击".localizedString
            } else if action_val == 1 {
                return "双击".localizedString
            } else {
                return "长按".localizedString
            }
            
        case .powers_1:
            guard let action_val = controlAction.val as? String else { return " " }
            if action_val == "on" {
                return "一键打开".localizedString
            } else if action_val == "off" {
                return "一键关闭".localizedString
            } else {
                return "一键开关切换".localizedString
            }
            
        case .powers_2:
            guard let action_val = controlAction.val as? String else { return " " }
            if action_val == "on" {
                return "二键打开".localizedString
            } else if action_val == "off" {
                return "二键关闭".localizedString
            } else {
                return "二键开关切换".localizedString
            }
            
        case .powers_3:
            guard let action_val = controlAction.val as? String else { return " " }
            if action_val == "on" {
                return "三键打开".localizedString
            } else if action_val == "off" {
                return "三键关闭".localizedString
            } else {
                return "三键开关切换".localizedString
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
            
        case .target_position:
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
                if percent == "100%" {
                    return "打开窗帘".localizedString
                } else if percent == "0%" {
                    return "关闭窗帘".localizedString
                }

            } else if `operator` == "<" {
                str += "小于".localizedString
            }
            
            

            return "窗帘状态".localizedString + str + percent
            
        case .rgb:
            guard let val = controlAction.val as? String else { return "#FFFFFF" }
            return val
        
        case .humidity:
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
            return "湿度".localizedString + str + percent
            
            
        case .temperature:
            guard
                let val = controlAction.val as? Float
            else { return " " }
            
            
            let percent = "\(val)°C"
            
            var str = ""
            if `operator` == ">" {
                str +=  "大于".localizedString
            } else if `operator` == "=" {
                str += "等于".localizedString
            } else if `operator` == "<" {
                str += "小于".localizedString
            }
            return "温度".localizedString + str + percent
            
        case .motion_detected:
            guard let val = controlAction.val as? Int else { return " " }
            
            return (val == 1 ? "检测到动作时".localizedString : "")

        case .contact_sensor_state:
            guard let val = controlAction.val as? Int else { return " " }
            
            return (val == 1 ? "由关闭变为打开时".localizedString : "由打开变为关闭时".localizedString)
            
        case .leak_detected:
            guard let val = controlAction.val as? Int else { return " " }
            
            return (val == 1 ? "检测到浸水时".localizedString : " ")
            
        case .target_state:
            guard let val = controlAction.val as? Int else { return " " }
            
            if val == 0 {
                return "开启在家模式".localizedString
            } else if val == 1 {
                return "开启离家模式".localizedString
            } else if val == 2 {
                return "开启睡眠模式".localizedString
            } else if val == 3 {
                return "关闭守护模式".localizedString
            } else {
                return " "
            }
            
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
    /// 设备控制项
    enum ControlActionType: String {
        /// 开关
        case power
        case on_off
        /// 亮度
        case brightness
        /// 色温
        case color_temp
        /// 窗帘位置
        case target_position
        /// 色彩
        case rgb
        /// 湿度
        case humidity
        /// 温度
        case temperature
        /// 人体传感器状态
        case motion_detected
        /// 门窗传感器状态
        case contact_sensor_state
        /// 水浸传感器状态
        case leak_detected
        /// 守护模式
        case target_state
        
        /// 多键开关
        case powers_1
        case powers_2
        case powers_3
        
        /// 无状态开关
        case switch_event
        
        case none
    }
    
    var aid: Int?
    
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
    
    var permission: Int?

    /// 开关："switch"; 色温"color_temp"; 亮度:"brightness"
    var type = ""
    
    var controlActionType: ControlActionType {
        return ControlActionType(rawValue: type) ?? .none
    }
    
    /// 展示actionName
    var actionName: String {
        switch controlActionType {
        case .power:
            return "开关".localizedString
        case .on_off:
            return "开关".localizedString
        case .brightness:
            return "亮度".localizedString
        case .color_temp:
            return  "色温".localizedString
        case .target_position:
            return "窗帘状态".localizedString
        case .rgb:
            return "彩色".localizedString
        case .humidity:
            return "湿度".localizedString
        case .temperature:
            return "温度".localizedString
        case .motion_detected:
            return "状态".localizedString
        case .contact_sensor_state:
            return "状态".localizedString
        case .leak_detected:
            return "状态".localizedString
        case .target_state:
            return "守护".localizedString
        case .powers_1:
            return "一键".localizedString
        case .powers_2:
            return "二键".localizedString
        case .powers_3:
            return "三键".localizedString
        case .switch_event:
            return "开关".localizedString
        case .none:
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
            
        case .on_off:
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
            
        case .target_position:
            guard
                let val = val as? Int,
                let max = max as? Int,
                let min = min as? Int
            else { return " " }
            let valDouble = Float(val)
            let maxDouble = Float(max)
            let minDouble = Float(min)
            
            
            return String(format: "%d", lroundf((valDouble - minDouble) / (maxDouble - minDouble) * 100)) + "%"
            
        case .rgb:
            guard let val = val as? String else { return "#FFFFFF" }
            return val
        
        case .humidity:
            guard let val = val as? Int,
                  let max = max as? Int,
                  let min = min as? Int
            else {
                return " "
            }
            
            let percent = (Float(val - min) / Float(max - min)) * 100
            return "\(Int(percent))%"
            
            
        case .temperature:
            guard let val = val as? Float else { return " "}
            return "\(val)"
            
        case .motion_detected:
            guard let val = val as? Int else { return " " }
            
            return (val == 1 ? "检测到动作时".localizedString : "")

        case .contact_sensor_state:
            guard let val = val as? Int else { return " " }
            
            return (val == 1 ? "由关闭变为打开时".localizedString : "由打开变为关闭时".localizedString)
            
        case .leak_detected:
            guard let val = val as? Int else { return " " }
            
            return (val == 1 ? "检测到浸水时".localizedString : " ")
            
        case .target_state:
            guard let val = val as? Int else { return " " }
            
            if val == 0 {
                return "开启在家模式".localizedString
            } else if val == 1 {
                return "开启离家模式".localizedString
            } else if val == 2 {
                return "开启睡眠模式".localizedString
            } else if val == 3 {
                return "关闭守护模式".localizedString
            } else {
                return " "
            }
            
        case .powers_1:
            guard let action_val = val as? String else { return " " }
            if action_val == "on" {
                return "打开".localizedString
            } else if action_val == "off" {
                return "关闭".localizedString
            } else {
                return "开关切换".localizedString
            }

        case .powers_2:
            guard let action_val = val as? String else { return " " }
            if action_val == "on" {
                return "打开".localizedString
            } else if action_val == "off" {
                return "关闭".localizedString
            } else {
                return "开关切换".localizedString
            }
            
        case .powers_3:
            guard let action_val = val as? String else { return " " }
            if action_val == "on" {
                return "打开".localizedString
            } else if action_val == "off" {
                return "关闭".localizedString
            } else {
                return "开关切换".localizedString
            }
            
        case .switch_event:
            guard let action_val = val as? Int else { return " " }
            if action_val == 0 {
                return "单击".localizedString
            } else if action_val == 1 {
                return "双击".localizedString
            } else {
                return "长按".localizedString
            }
            
        case .none:
            return " "
        }
        
    }
    
}

class SceneDetailDeviceInfo: BaseModel {
    /// 设备名称
    var name: String = ""
    /// 设备位置
    var location_name: String?
    
    /// 设备所属部门
    var department_name: String?
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
