//
//  ApiService+Task.swift
//  ZhiTing
//
//  Created by iMac on 2021/7/29.
//

import Foundation
import  Moya

extension ApiService {
    var task: Task {
        switch self {
        case .cloudUserDetail:
            return .requestPlain

        case .brands(let name, _):
            return .requestParameters(parameters: ["name": name], encoding: URLEncoding.default)
        case .brandDetail(_, _):
            return .requestPlain
            
        case .plugins(_, let list_type):
            return .requestParameters(parameters: ["list_type": list_type], encoding: URLEncoding.default)

        case .deletePluginById:
            return .requestPlain

        case .pluginDetail:
            return .requestPlain
            
        case .installPlugin(_, _, let plugins):
            return .requestParameters(parameters: ["plugins": plugins], encoding: JSONEncoding.default)
            
        case .deletePlugin(_, _, let plugins):
            return .requestParameters(parameters: ["plugins": plugins], encoding: JSONEncoding.default)

        case .addDiscoverDevice(let device, _):
            let deviceDict = device.toJSON() ?? [:]
            return .requestParameters(parameters: ["device": deviceDict], encoding: JSONEncoding.default)
        case .defaultLocationList:
            return .requestPlain
        case .createArea(let name, let locations_name):
            return .requestParameters(parameters: ["name" : name, "location_names": locations_name], encoding: JSONEncoding.default)
        case .areaList:
            return .requestPlain
        case .areaDetail:
            return .requestPlain
        case .changeAreaName(_, let name):
            return .requestParameters(parameters: ["name": name], encoding: JSONEncoding.default)
        case .deleteArea(_, let is_del_cloud_disk):
            return .requestParameters(parameters: ["is_del_cloud_disk": is_del_cloud_disk], encoding: JSONEncoding.default)
        case .locationDetail:
            return .requestPlain
        case .changeLocationName(_, _, let name):
            return .requestParameters(parameters: ["name" : name], encoding: JSONEncoding.default)
        case .deleteLocation:
            return .requestPlain
        case .addLocation(_, let name):
            return .requestParameters(parameters: ["name": name], encoding: JSONEncoding.default)
        case .setLocationOrders(_, let location_order):
            return .requestParameters(parameters: ["locations_id": location_order], encoding: JSONEncoding.default)
        case .deviceDetail:
            return .requestPlain
        case .editDevice(_, _, let name, let location_id):
            var parameters = [String: Any]()
            if name != "" { parameters["name"] = name }
            if location_id > 0 { parameters["location_id"] = location_id }
            if location_id == -1 { parameters["location_id"] = 0 }

            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .sceneList(let type ,_):
            return .requestParameters(parameters: ["type": type], encoding: URLEncoding.default)


        case .sceneLogs(let start, let size, _):
        return .requestParameters(parameters: ["start": start, "size": size], encoding: URLEncoding.default)
        case .sceneDetail(_, _):
            return .requestPlain
        case .createScene(let scene, _):
            let json = scene.toJSON() ?? [:]
            return .requestParameters(parameters: json, encoding: JSONEncoding.default)
        case .deleteScene(_, _):
            return .requestPlain

        case .editScene(_, let scene, _):
            let json = scene.toJSON() ?? [:]
            return .requestParameters(parameters: json, encoding: JSONEncoding.default)
        case .sceneExecute(_,let is_execute, _):
            return .requestParameters(parameters: ["is_execute": is_execute], encoding: JSONEncoding.default)

        case .areaLocationsList:
            return .requestPlain
        case .deleteDevice:
            return .requestPlain
        case .deviceList(let type, _):
            return .requestParameters(parameters: ["type": type], encoding: URLEncoding.default)
        case .register(let country_code, let phone, let password, let captcha, let captcha_id):
            return .requestParameters(
                parameters:
                    [
                        "country_code": country_code,
                        "phone": phone,
                        "password": password,
                        "captcha": captcha,
                        "captcha_id": captcha_id
                    ],
                encoding: JSONEncoding.default
            )
        case .login(let phone, let password):
            return .requestParameters(
                parameters:
                    [
                        "phone": phone,
                        "password": password
                    ],
                encoding: JSONEncoding.default
            )
        case .logout:
            return .requestPlain
        case .captcha(let type, let target, let country_code):
            return .requestParameters(
                parameters:
                    [
                        "type": type.rawValue,
                        "target": target,
                        "country_code": country_code
                    ],
                encoding: URLEncoding.default
            )
        case .getInviteQRCode(let area, let role_ids):
            var parameters: [String: Any] = ["role_ids": role_ids]
            if let areaId = area.id {
                parameters["area_id"] = areaId
            }
            
            return .requestParameters(
                parameters: parameters,
                encoding: JSONEncoding.default
            )
        case .userDetail:
            return .requestPlain
        case .memberList:
            return .requestPlain
        case .deleteMember:
            return .requestPlain
        case .editMember(_, _, let role_ids):
            return .requestParameters(parameters: ["role_ids" : role_ids], encoding: JSONEncoding.default)
        case .rolesList:
            return .requestPlain
        case .quitArea:
            return .requestPlain
        case .scanQRCode(let qr_code, _, let nickname, _):
            return .requestParameters(parameters: ["qr_code": qr_code, "nickname": nickname], encoding: JSONEncoding.default)
        case .rolesPermissions:
            return .requestPlain
        case .syncArea(let syncModel, _, _):
            let syncModelDict = syncModel.toJSON() ?? [:]
            return .requestParameters(parameters: syncModelDict, encoding: JSONEncoding.default)
        case .addSADevice(_, let device):
            let deviceDict = device.toJSON() ?? [:]
            return .requestParameters(parameters: ["device": deviceDict], encoding: JSONEncoding.default)
        case .editUser(_, _, let nickname, let account_name, let password):
            if nickname == "" {
                return .requestParameters(parameters: [ "account_name": account_name, "password": password], encoding: JSONEncoding.default)
            } else {
                return .requestParameters(parameters: [ "nickname": nickname], encoding: JSONEncoding.default)
            }
            
        case .editCloudUser(_, let nickname):
            return .requestParameters(parameters: [ "nickname": nickname], encoding: JSONEncoding.default)

        case .checkSABindState:
            return .requestPlain
        case .bindCloud(_, let cloudUserId, _, _, let access_token):
            return .requestParameters(parameters: ["cloud_user_id" : cloudUserId, "access_token" : access_token], encoding: JSONEncoding.default)
        case .scopeList:
            return .requestPlain
        case .scopeToken(_, let scopes):
            return .requestParameters(parameters: ["scopes" : scopes], encoding: JSONEncoding.default)
        case .transferOwner:
            return .requestPlain
        case .temporaryIP(_, let scheme):
            return .requestParameters(
                parameters:
                    [
                        "scheme": scheme
                    ],
                encoding: URLEncoding.default
            )
        case .temporaryIPBySAID(_, let scheme):
            return .requestParameters(parameters:["scheme": scheme], encoding: URLEncoding.default)
            
        case .getSAToken(let area):
            var parameters = [String: Any]()
            if let areaId = area.id {
                parameters["area_id"] = areaId
            }

           return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
        case .commonDeviceList:
            return .requestPlain

        case .getDeviceAccessToken:
            return .requestPlain
            
        case .checkPluginUpdate:
            return .requestPlain
        case .getCaptcha :
            return .requestPlain
            
        case .downloadPlugin(_, _,let dst):
            return .downloadDestination(dst)
            
        case .settingTokenAuth( _, let tokenModel):
            let json = tokenModel.toJSON() ?? [:]
            return .requestParameters(parameters: ["user_credential_found_setting": json], encoding: JSONEncoding.default)
            
        case .checkSoftwareUpdate:
            return .requestPlain
        case .migrationAddr:
            return .requestPlain
            
        case .migrationCloudToLocal(_, let migration_url, let backup_file, let sum):
            return .requestParameters(parameters: ["migration_url" : migration_url, "backup_file": backup_file, "sum": sum], encoding: JSONEncoding.default)

        case .updateSoftware(_, let version):
            return .requestParameters(parameters: ["version": version], encoding: JSONEncoding.default)

        }
        
    }
}
