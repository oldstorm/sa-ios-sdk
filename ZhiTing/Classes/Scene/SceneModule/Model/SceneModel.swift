//
//  SceneModel.swift
//  ZhiTing
//
//  Created by zy on 2021/4/12.
//

import UIKit

class SceneModel: BaseModel {
    /// scene's title场景名称
    var scene_title = ""
    /// whether the scene's action need Auto是否自动
    var is_Auto = false
    /// whether the scene's action need timer是否定时
    var is_Timer = false
    /// brand's supported devices控制的设备
    var support_devices = [Device]()
    ///日期 执行日期
    var date = ""
    ///时间 执行时间
    var time = ""
    ///Month 统计月份
    var Month = ""
    ///result 执行结果
    var result = 0
    
}
