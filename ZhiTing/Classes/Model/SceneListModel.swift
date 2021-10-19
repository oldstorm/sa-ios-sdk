//
//  SceneListModel.swift
//  ZhiTing
//
//  Created by mac on 2021/4/21.
//

import UIKit

class SceneListModel: BaseModel {
    //手动场景列表
    var manual = [SceneTypeModel]()
    //自动场景列表
    var auto_run = [SceneTypeModel]()
    
}

class SceneTypeModel: BaseModel {
    var area_id = ""
    /// smartAssistant's token
    var sa_user_token = ""
    //场景ID
    var id = 0
    //场景名称
    var name = ""
    //修改场景状态权限
    var control_permission = false
    //自动场景是否启动
    var is_on = false
    //执行任务列表
    var items = [SceneItemModel]()
    //触发条件
    var condition = SceneConditionModel()
    
    var isSelected : Bool?
    
    
}


class SceneItemModel: BaseModel {
//    var area_id = -1
//    /// smartAssistant's token
//    var sa_user_token = ""
    //执行任务类型;1为设备,2为场景
    var type = 0
    //设备图片
    var logo_url = ""
    //设备状态;1为正常,2为已删除,3为离线
    var status = 0
}

class SceneConditionModel: BaseModel {
    //触发条件类型;1为定时任务, 2为设备
    var type = 0
    //触发条件为设备时返回设备图片url    
    var logo_url = ""
    //设备状态:1正常2已删除3离线
    var status = 0
}
