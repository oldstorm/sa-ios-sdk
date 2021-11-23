//
//  ApiService+Method.swift
//  ZhiTing
//
//  Created by iMac on 2021/7/29.
//

import Foundation
import Moya



extension ApiService {
    var method: Moya.Method {
        switch self {
        case .editCloudUser:
            return .put
        case .cloudUserDetail:
            return .get
        case .brands:
            return .get
        case .brandDetail:
            return .get
        case .plugins:
            return .get
        case .deletePluginById:
            return .delete
        case .pluginDetail:
            return .get
        case .installPlugin:
            return .post
        case .deletePlugin:
            return .delete
        case .addDiscoverDevice:
            return .post
        case .defaultLocationList:
            return .get
        case .createArea:
            return .post
        case .areaList:
            return .get
        case .areaDetail:
            return .get
        case .changeAreaName:
            return .put
        case .deleteArea:
            return .delete
        case .locationDetail:
            return .get
        case .changeLocationName:
            return .put
        case .deleteLocation:
            return .delete
        case .addLocation:
            return .post
        case .setLocationOrders:
            return .put
        case .deviceDetail:
            return .get
        case .editDevice:
            return .put
        case .areaLocationsList:
            return .get
        case .deleteDevice:
            return .delete
        case .deviceList:
            return .get
        case .getDeviceAccessToken:
            return .post
        case .sceneList:
            return .get
        case .createScene:
            return .post
        case .deleteScene:
            return .delete
        case .sceneExecute:
            return .post
        case .sceneDetail:
            return .get
        case .editScene:
            return .put
        case .sceneLogs:
            return .get
        case .register:
            return .post
        case .login:
            return .post
        case .logout:
            return .post
        case .captcha:
            return .get
        case .getInviteQRCode:
            return .post
        case .userDetail:
            return .get
        case .memberList:
            return .get
        case .deleteMember:
            return .delete
        case .editMember:
            return .put
        case .rolesList:
            return .get
        case .quitArea:
            return .delete
        case .scanQRCode:
            return .post
        case .rolesPermissions:
            return .get
        case .syncArea:
            return .post
        case .addSADevice:
            return .post
        case .editUser:
            return .put
        case .checkSABindState:
            return .get
        case .bindCloud:
            return .post
        case .scopeList:
            return .get
        case .scopeToken:
            return .post
        case .transferOwner:
            return .put
        case .temporaryIP:
            return .get
        case .temporaryIPBySAID:
            return .get
        case .getSAToken:
            return .get
        case .commonDeviceList:
            return .get
        case .checkPluginUpdate:
            return .get
        case .getCaptcha:
            return .post
        case .downloadPlugin:
            return .get
        case .settingTokenAuth:
            return .put
        case .checkSoftwareUpdate:
            return .get
        case .updateSoftware:
            return .post
        case .migrationAddr:
            return .get
        case .migrationCloudToLocal:
            return .post
        
        }
    }
}
