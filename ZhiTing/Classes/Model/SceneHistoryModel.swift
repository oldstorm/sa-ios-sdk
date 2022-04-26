//
//  HistoryModel.swift
//  ZhiTing
//
//  Created by mac on 2021/4/13.
//

import UIKit


class SceneHistoryModel: BaseModel {
    var data = [SceneHistoryMonthModel]()
}

class SceneHistoryMonthModel: BaseModel{
    //月份(从最近月份开始排序)
    var date = ""
    var items = [SceneHistoryMonthItemModel]()
    
}

class SceneHistoryMonthItemModel: BaseModel {
    //设备名称/场景名称
    var name = ""
    //执行任务类型:1设备; 2 3 4场景
    var type = 0
    //任务结果:1执行完成;2部分执行完成;3执行失败;4执行超时;5设备已被删除;6设备离线;7场景已被删除
    var result = 0
    //任务执行完成时间
    var finished_at = 0
    //任务执行详情
    var items = [SceneHistoryItemModel]()
}


class SceneHistoryItemModel: BaseModel{
    //设备名称/场景名称
    var name = ""
    //执行任务类型:1设备; 2 3 4场景
    var type = 0
    //位置
    var location_name: String?
    //部门
    var department_name: String?
    //任务结果:1执行完成;2部分执行完成;3执行失败;4执行超时;5设备已被删除;6设备离线;7场景已被删除
    var result = 0
    
}
