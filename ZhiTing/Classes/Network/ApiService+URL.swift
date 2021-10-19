//
//  ApiService+URL.swift
//  ZhiTing
//
//  Created by iMac on 2021/7/29.
//

import Foundation
extension ApiService {
        
    var baseURL: URL {
        switch self {
        case .logout,
             .login,
             .register,
             .captcha,
             .cloudUserDetail,
             .editCloudUser,
             .defaultLocationList,
             .areaList,
             .createArea:
            return URL(string: "\(cloudUrl)/api")!
        
        case .checkPluginUpdate(_, let area):
            return area.requestURL
            
        case .commonDeviceList(let area):
            return area.requestURL
 
        case .scanQRCode(_, let url, _, _):
            return URL(string: "\(url)/api")!
            
        case .addSADevice(let url, _):
            return URL(string: "\(url)/api")!
            
        case .checkSABindState(let url):
            return URL(string: "\(url)/api")!
            
        // brand
        case .brands(_, let area):
            return area.requestURL
            
        case .brandDetail(_, let area):
            return area.requestURL
            
        // plugin
        case .pluginDetail(_, let area):
            return area.requestURL
            
        // scenes
        case .sceneList(_, let area):
            return area.requestURL
            
        case .createScene(_, let area):
            return area.requestURL
            
        case .sceneDetail(_, let area):
            return area.requestURL
            
        case .editScene(_, _, let area):
            return area.requestURL
            
        case .deleteScene(_, let area):
            return area.requestURL
            
        case .sceneExecute(_, _, let area):
            return area.requestURL
            
        case .sceneLogs(_, _, let area):
            return area.requestURL
            
        // devices
        case .deviceList(_, let area):
            return area.requestURL
            
        case .addDiscoverDevice(_, let area):
            return area.requestURL
            
        case .deviceDetail(let area, _):
            return area.requestURL
            
        case .editDevice(let area, _, _, _):
            return area.requestURL
            
        case .deleteDevice(let area, _):
            return area.requestURL
            
        case .getDeviceAccessToken(let area):
            return URL(string: "\(cloudUrl)/api")!

        // areas
        case .areaDetail(let area):
            return area.requestURL
            
        case .deleteArea(let area, _):
            return area.requestURL
            
        case .changeAreaName(let area, _):
            return area.requestURL
            
        case .quitArea(let area):
            return area.requestURL
            
        // members
        case .memberList(let area):
            return area.requestURL
            
        case .deleteMember(let area, _):
            return area.requestURL
            
        case .editMember(let area, _, _):
            return area.requestURL
            
        // roles
        case .rolesList(let area):
            return area.requestURL
            
        case .rolesPermissions(let area, _):
            return area.requestURL
            
        // locations
        case .areaLocationsList(let area):
            return area.requestURL
            
        case .locationDetail(let area, _):
            return area.requestURL
            
        case .addLocation(let area, _):
            return area.requestURL
            
        case .changeLocationName(let area, _, _):
            return area.requestURL
            
        case .deleteLocation(let area, _):
            return area.requestURL
            
        case .setLocationOrders(let area, _):
            return area.requestURL
            
        
        case .editUser(let area, _, _, _, _):
            return area.requestURL
            
        case .bindCloud(_, _, _, let url, _):
            return URL(string: "\(url)/api")!
            
        case .syncArea(_, let url, _):
            return URL(string: "\(url)/api")!
            
        case .getInviteQRCode(let area, _):
            return area.requestURL
            
        case .userDetail(let area, _):
            return area.requestURL
            
        case .scopeList(let area):
            return area.requestURL
            
        case .scopeToken(let area, _):
            return area.requestURL
            
        case .transferOwner(let area, _):
            return area.requestURL
        
        case .temporaryIP:
            return URL(string: "\(cloudUrl)/api")!

        case .getSAToken:
            return URL(string: "\(cloudUrl)/api")!

        case .temporaryIPBySAID:
            return URL(string: "\(cloudUrl)/api")!
            
        case .getCaptcha(let area):
            return area.requestURL
            
        case .downloadPlugin( _, let url, _):
            return URL(string: url)!

        }
        
    }
    
}
