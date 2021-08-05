//
//  ApiService+Header.swift
//  ZhiTing
//
//  Created by iMac on 2021/7/29.
//

import Foundation
import Moya

extension ApiService {
    var headers: [String : String]? {
        var headers = [String : String]()
        headers["Content-type"] = "application/json"

        switch self {
        // brand & plugin

        case .brands(_, let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
        case .brandDetail(_, let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
        case .pluginDetail(_, let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        // areas
        case .areaDetail(let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .changeAreaName(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            headers["Area-ID"] = "\(area.id)"
            
        case .deleteArea(let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .quitArea(let area):
            headers["smart-assistant-token"] = area.sa_user_token
            headers["Area-ID"] = "\(area.id)"
            
        case .getInviteQRCode(let area, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        // members
        case .memberList(let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .userDetail(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            headers["Area-ID"] = "\(area.id)"
            
            
        case .deleteMember(let area, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .editMember(let area, _, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        // roles
        case .rolesList(let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .rolesPermissions(let area, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        // location
        case .areaLocationsList(let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .locationDetail(let area, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .addLocation(let area, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .changeLocationName(let area, _, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deleteLocation(let area, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .setLocationOrders(let area, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        // device
        case .addDiscoverDevice(_, let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deviceList(_, let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deviceDetail(let area, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deleteDevice(let area, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .editDevice(let area, _, _, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
            
        //Scene
        case .sceneList(_, let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .sceneDetail(_, let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .sceneLogs(_, _, let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .sceneExecute(_, _, let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deleteScene(_, let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .createScene(_, let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .editScene(_, _, let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        //Scopes
        case .scopeToken(let area, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .transferOwner(let area, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .cloudUserDetail:
            break
        
        case .register:
            break
            
        case .login:
            break
            
        case .logout:
            break
            
        case .captcha:
            break

        case .editUser(let area, _, _, _, _):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .editCloudUser:
            break
            
        case .bindCloud(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token

        case .syncArea:
            headers["smart-assistant-token"] = AppDelegate.shared.appDependency.authManager.currentArea.sa_user_token
            
            
        case .checkSABindState:
            break
            
        case .addSADevice:
            break

        case .defaultLocationList:
            break
            
        case .areaList:
            break
            
        case .createArea:
            break
            
        case .scanQRCode(_, _, _, let token, let area_id):
            if let token = token {
                headers["smart-assistant-token"] = token
            }
            
            if area_id > 0 && AppDelegate.shared.appDependency.authManager.isLogin {
                headers["Area-ID"] = "\(area_id)"
            }
            
        case .scopeList(area: let area):
            headers["Area-ID"] = "\(area.id)"
            headers["smart-assistant-token"] = area.sa_user_token
        }
        
        
        return headers
    }
}
