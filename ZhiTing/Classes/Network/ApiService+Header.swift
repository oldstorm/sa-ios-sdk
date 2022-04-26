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
        headers["Content-Type"] = "application/json"
        
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
            
        case .plugins(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deletePluginById(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .pluginDetail(_, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .installPlugin(let area, _, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deletePlugin(let area, _, _):
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
            
        case .getInviteQRCode(let area, _, _):
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
            
        case .editMember(let area, _, _, _):
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
        case .locationsList(let area):
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
       
        case .deviceList(_, let area):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deviceDetail(let area, _, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deleteDevice(let area, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .editDevice(let area, _, _, _, _, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deviceLogoList(let area, _):
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
            
        case .editSAUser(let area, _, _, _, _, _, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .unregister:
            break
            
        case .unregisterList:
            break
            
            
        case .editCloudUser:
            break
            
        case .bindCloud(let area, _, _, let saId, _):
            if let saId = saId {
                headers["SA-ID"] = "\(saId)"
            }
            
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .syncArea(_, _, let token):
            headers["smart-assistant-token"] = token
            
        case .deleteSA(let area, _, _, _, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            headers["smart-assistant-token"] = area.sa_user_token

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
            
        case .scanQRCode(_, _, _, _, let token):
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
            
        case .getDeviceAccessToken:
            break
        case .settingTokenAuth(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .downloadPlugin:
            break
            
        case .getSAExtensions(let area):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .getSoftwareVersion(let area):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .getSoftwareLatestVersion(let area):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .updateSoftware(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .getFirmwareLatestVersion(let area):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .getFirmwareVersion(let area):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .updateFirmware(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .migrationAddr(let area):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .migrationCloudToLocal(let area, _, _, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .commonDeviceMajorList(let area):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .commonDeviceMinorList(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .departmentList(let area):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .addDepartment(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .departmentDetail(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .addDepartmentMember(let area, _, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .updateDepartment(let area, _, _, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .deleteDepartment(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .setDepartmentOrders(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .changePWD(let area, _, _):
            if let areaId = area.id {
                headers["Area-ID"] = "\(areaId)"
            }
            
        case .forgetPwd:
            break
            
        case .scUploadFile:
            headers["Content-Type"] = "multipart/form-data"
            
        case .getAppVersions:
            break
            
        case .saUploadFile(let area, _, _):
            headers["smart-assistant-token"] = area.sa_user_token
            headers["Content-Type"] = "multipart/form-data"
            
        case .getAppSupportApiVersion:
            break
            
        case .setSceneSort(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .getSAStatus:
            break
            
        case .unbindThirdPartyCloud(let area, _):
            headers["smart-assistant-token"] = area.sa_user_token
            
        case .thirdPartyCloudListSC:
            break

        case .thirdPartyCloudListSA(let area):
            headers["smart-assistant-token"] = area.sa_user_token

        case .getSASupportApiVersion:
            break
            
        case .feedbackList:
            break
        
        case .feedbackDetail:
            break
            
        case .createFeedback:
            break

        }
        
        return headers
        
    }
}
