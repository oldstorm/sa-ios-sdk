//
//  ApiService+Path.swift
//  ZhiTing
//
//  Created by iMac on 2021/7/29.
//

import Foundation

extension ApiService {
    var path: String {
        switch self {
        case .brands:
            return "/brands"
            
        case .brandDetail(let name, _):
            return "/brands/\(name)"
            
        case .pluginDetail(let plugin_id, _):
            return "/plugin/\(plugin_id)"
            
        case .addDiscoverDevice:
            return "/devices"
            
        case .defaultLocationList:
            return "/location_tmpl"
            
        case .createArea:
            return "/areas"
            
        case .areaList:
            return "/areas"
            
        case .areaDetail(let area):
            if area.is_bind_sa {
                return "/areas/1"
            } else {
                return "/areas/\(area.id)"
            }
            
        case .changeAreaName(let area, _):
            if area.is_bind_sa {
                return "/areas/1"
            } else {
                return "/areas/\(area.id)"
            }
            
        case .deleteArea(let area):
            if area.is_bind_sa {
                return "/areas/1"
            } else {
                return "/areas/\(area.id)"
            }
            
        case .locationDetail(_, let id):
            return "/locations/\(id)"
            
        case .changeLocationName(_, let id, _):
            return "/locations/\(id)"
            
        case .deleteLocation(_, let id):
            return "/locations/\(id)"
            
        case .addLocation:
            return "/locations"
            
        case .setLocationOrders:
            return "/locations"
            
        case .deviceDetail(_, let device_id):
            return "/devices/\(device_id)"
            
        case .editDevice(_, let device_id, _, _):
            return "devices/\(device_id)"
            
        case .areaLocationsList:
            return "/locations"
            
        case .deleteDevice(_, let device_id):
            return "/devices/\(device_id)"
            
        case .deviceList:
            return "/devices"
            
        case .sceneList:
            return "/scenes"
            
        case .createScene:
            return "/scenes"
            
        case .deleteScene(let scene_id ,_):
            return "/scenes/\(scene_id)"
            
        case .editScene(let scene_id, _, _):
            return "/scenes/\(scene_id)"
            
        case .sceneExecute(let scene_id,_, _):
            return "/scenes/\(scene_id)/execute"
            
        case .sceneDetail(let scene_id ,_):
            return "/scenes/\(scene_id)"
            
        case .sceneLogs:
            return "/scene_logs"
            
        case .register:
            return "/users"
            
        case .login:
            return "/sessions/login"
            
        case .logout:
            return "/sessions/logout"
            
        case .captcha:
            return "/captcha"
            
        case .getInviteQRCode(let area, _):
            return "/users/\(area.sa_user_id)/invitation/code"
            
        case .userDetail(_, let id):
            return "/users/\(id)"
            
        case .cloudUserDetail(let id):
            return "/users/\(id)"
            
        case .memberList:
            return "/users"
            
        case .deleteMember(_, let id):
            return "/users/\(id)"
            
        case .editMember(_, let id, _):
            return "/users/\(id)"
            
        case .rolesList:
            return "/roles"
            
        case .quitArea(let area):
            if area.is_bind_sa {
                return "/areas/1/users/\(area.sa_user_id)"
            } else {
                let userId = AppDelegate.shared.appDependency.authManager.currentUser.user_id
                return "/areas/\(area.id)/users/\(userId)"
            }
            
        case .scanQRCode:
            return "/invitation/check"
            
        case .rolesPermissions(_, let role_id):
            return "/users/\(role_id)/permissions"
            
        case .syncArea:
            return "/sync"
            
        case .addSADevice:
            return "/devices"
            
        case .editUser(_, let user_id, _, _, _):
            return "/users/\(user_id)"
            
        case .editCloudUser(let user_id, _):
            return "/users/\(user_id)"
            
        case .checkSABindState:
            return "/check"
            
        case .bindCloud:
            return "/cloud/bind"
            
        case .scopeList:
            return "/scopes"
            
        case .scopeToken:
            return "/scopes/token"
            
        case .transferOwner(_,let id):
            return "/users/\(id)/owner"

        }
    }
    
}
