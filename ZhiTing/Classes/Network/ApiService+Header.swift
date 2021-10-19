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
        // discover
        case .commonDeviceList:
            break
        case .checkPluginUpdate(_, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
        // brand & plugin

        case .brands(_, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
        case .brandDetail(_, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
        case .pluginDetail(_, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        // areas
        case .areaDetail(let area):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .changeAreaName(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deleteArea(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .quitArea(let area):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .getInviteQRCode(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        // members
        case .memberList(let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .userDetail(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            
            
        case .deleteMember(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .editMember(let area, _, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        // roles
        case .rolesList(let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .rolesPermissions(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        // location
        case .areaLocationsList(let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .locationDetail(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .addLocation(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .changeLocationName(let area, _, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deleteLocation(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .setLocationOrders(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        // device
        case .addDiscoverDevice(_, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deviceList(_, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deviceDetail(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deleteDevice(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .editDevice(let area, _, _, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
            
        //Scene
        case .sceneList(_, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .sceneDetail(_, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .sceneLogs(_, _, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .sceneExecute(_, _, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deleteScene(_, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .createScene(_, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .editScene(_, _, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        //Scopes
        case .scopeToken(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .transferOwner(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
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
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
           
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .editCloudUser:
            break
            
        case .bindCloud(let area, _, _, _, let saId):
            if let saId = saId {
                headers["SA-ID"] = "\(saId)"
            }

            headers["smart-assistant-token"] = area.sa_user_token

        case .syncArea(_, _, let token):
            headers["smart-assistant-token"] = token
            
            
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
            
        case .scanQRCode(_, _, _, let token):
            if let token = token {
                headers["smart-assistant-token"] = token
            }
            
        case .scopeList(area: let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .temporaryIP(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            
        case .temporaryIPBySAID(let saID, _):
            headers["SA-ID"] = saID
            
        case .getSAToken(let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            
        case .getCaptcha(let area):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .getDeviceAccessToken(area: let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            
        case .downloadPlugin:
            break
        }
        return headers
    }
}
