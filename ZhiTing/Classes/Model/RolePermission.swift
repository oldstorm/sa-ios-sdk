//
//  RolePermission.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/6.
//

import Foundation

class RolePermission: BaseModel {
    var add_location = false
    var add_device = false
    var add_role = false
    var control_device = false
    var delete_location = false
    var delete_device = false
    var delete_role = false
    var delete_area_member = false
    var get_location = false
    var get_role = false
    var get_area_invite_code = false
    var update_location_name = false
    var update_location_order = false
    var update_device = false
    var update_role = false
    var update_area_name = false
    var update_area_member_role = false
    var manage_device = false

    var add_scene = false
    var update_scene = false
    var delete_scene = false
    var control_scene = false
    
    var update_area_company_name = false
    var add_department = false
    var update_area_member_department = false
    var add_department_user = false
    var get_department = false
    var update_department = false
    var update_department_order = false

    var sa_firmware_upgrade = false
    var sa_software_upgrade = false
    
}



