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
                .changePWD,
                .forgetPwd,
                .unregister,
                .unregisterList,
                .createArea,
                .scUploadFile,
                .thirdPartyCloudListSC,
                .temporaryIP,
                .getDeviceAccessToken,
                .getSAToken,
                .temporaryIPBySAID,
                .feedbackList,
                .feedbackDetail,
                .createFeedback:
            return URL(string: "\(cloudUrl)/api/v\(apiVersion)")!
            
        case .getAppSupportApiVersion,
                .getSASupportApiVersion,
                .getAppVersions:
            return URL(string: "\(cloudUrl)/api")!
            
        case .scanQRCode(_, let url, _, _, _):
            return URL(string: "\(url)/api")!
            
        case .addSADevice(let url, _):
            return URL(string: "\(url)/api")!
            
        case .checkSABindState(let url):
            return URL(string: "\(url)/api")!
            
        case .bindCloud(_, _, let url, _, _):
            return URL(string: "\(url)/api")!
            
        case .syncArea(_, let url, _):
            return URL(string: "\(url)/api")!
            
        case .downloadPlugin( _, let url, _):
            guard let url = URL(string: url) else {
                
                return URL(string: "http://")!
            }
            return url
            
        case .unbindThirdPartyCloud(let area, _),
                .thirdPartyCloudListSA(let area),
                .saUploadFile(let area, _, _),
                .migrationAddr(let area),
                .migrationCloudToLocal(let area, _, _, _),
                .checkPluginUpdate(_, let area),
                .commonDeviceList(let area),
                .getSAExtensions(let area),
                .deleteSA(let area, _, _, _, _),
            // brand
                .brands(_, let area),
                .brandDetail(_, let area),
            // plugin
                .plugins(let area, _),
                .pluginDetail(_, let area),
                .installPlugin(let area, _, _),
                .deletePlugin(let area, _, _),
                .deletePluginById(let area, _),
            // scenes
                .sceneList(_, let area),
                .createScene(_, let area),
                .sceneDetail(_, let area),
                .editScene(_, _, let area),
                .deleteScene(_, let area),
                .sceneExecute(_, _, let area),
                .sceneLogs(_, _, let area),
            // devices
                .deviceList(_, let area),
                .deviceDetail(let area, _, _),
                .editDevice(let area, _, _, _, _, _),
                .deleteDevice(let area, _),
                .deviceLogoList(let area, _),
            // areas
                .areaDetail(let area),
                .deleteArea(let area, _),
                .changeAreaName(let area, _),
                .quitArea(let area),
            // members
                .memberList(let area),
                .deleteMember(let area, _),
                .editMember(let area, _, _, _),
            // roles
                .rolesList(let area),
                .rolesPermissions(let area, _),
            // locations
                .locationsList(let area),
                .locationDetail(let area, _),
                .addLocation(let area, _),
                .changeLocationName(let area, _, _),
                .deleteLocation(let area, _),
                .setLocationOrders(let area, _),
                .editSAUser(let area, _, _, _, _, _, _),
                .getInviteQRCode(let area, _, _),
                .userDetail(let area, _),
                .scopeList(let area),
                .scopeToken(let area, _),
                .transferOwner(let area, _),
                .getCaptcha(let area),
                .settingTokenAuth(let area, _),
                .getSoftwareVersion(let area),
                .getSoftwareLatestVersion(let area),
                .updateSoftware(let area, _),
                .getFirmwareVersion(let area),
                .updateFirmware(let area, _),
                .getFirmwareLatestVersion(let area),
                .commonDeviceMajorList(let area),
                .commonDeviceMinorList(let area, _),
                .departmentList(let area),
                .addDepartment(let area, _),
                .departmentDetail(let area, _),
                .addDepartmentMember(let area, _, _),
                .updateDepartment(let area, _, _, _),
                .deleteDepartment(let area, _),
                .setDepartmentOrders(let area, _),
                .setSceneSort(let area, _):
            return URL(string: area.requestURL + "/api/v\(apiVersion)")!
            
        case .getSAStatus(let area):
            return URL(string: area.requestURL + "/api")!
        }
        
    }
    
}
