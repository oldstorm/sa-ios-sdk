//
//  User.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/31.
//

import Foundation

class User: BaseModel {
    var nickname = ""
    var role_infos = [Role]()
    var user_id = 1
    //是否家庭sa设备的拥有者    
    var is_owner = false
    var is_self = false
    var account_name = ""
    var is_set_password = false
    var token = ""
    var phone = ""
    var icon_url = ""
    var role_count = 0
    
    var isSelected = false
    
}
