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
            
        case .plugins:
            return "/plugins"
            
        case .deletePluginById(_, let id):
            return "/plugins/\(id)"
            
        case .pluginDetail(let plugin_id, _):
            return "/plugins/\(plugin_id)"
            
        case .installPlugin(_, let name, _):
            return "/brands/\(name)/plugins"
            
        case .deletePlugin(_, let name, _):
            return "/brands/\(name)/plugins"
            
        case .defaultLocationList:
            return "/location_tmpl"
            
        case .createArea:
            return "/areas"
            
        case .areaList:
            return "/areas"
            
        case .migrationAddr(let area):
            return "/areas/\(area.id ?? "")/migration"
            
        case .migrationCloudToLocal:
            return "/cloud/migration"
            
        case .deleteSA(let area, _, _, _, _):
            return "/areas/\(area.id ?? "")/device/sa"
            
        case .getSAStatus:
            return "/check"
            
        case .areaDetail(let area):
            var areaId = ""
            if let id = area.id {
                areaId = "\(id)"
            }
            return "/areas/\(areaId)"
            
        case .changeAreaName(let area, _):
            var areaId = ""
            if let id = area.id {
                areaId = "\(id)"
            }
            return "/areas/\(areaId)"
            
        case .deleteArea(let area, _):
            var areaId = ""
            if let id = area.id {
                areaId = "\(id)"
            }
            return "/areas/\(areaId)"
            
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
            
        case .deviceDetail(_, let device_id, _):
            return "/devices/\(device_id)"
            
            
        case .editDevice(_, let device_id, _, _, _, _):
            return "/devices/\(device_id)"
            
        case .deviceLogoList(_, let device_id):
            return "/devices/\(device_id)/logo"
            
        case .locationsList:
            return "/locations"
            
        case .deleteDevice(_, let device_id):
            return "/devices/\(device_id)"
            
        case .deviceList:
            return "/devices"
            
        case .getDeviceAccessToken:
            return "/oauth2/access_token"
            
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
            
        case .unregister(let userId, _, _):
            return "/users/\(userId)"
            
        case .unregisterList(let user_id):
            return "/users/\(user_id)/areas"
            
        case .getInviteQRCode(let area, _, _):
            return "/users/\(area.sa_user_id)/invitation/code"
            
        case .userDetail(_, let id):
            return "/users/\(id)"
            
        case .cloudUserDetail(let id):
            return "/users/\(id)"
            
        case .memberList:
            return "/users"
            
        case .deleteMember(_, let id):
            return "/users/\(id)"
            
        case .editMember(_, let id, _, _):
            return "/users/\(id)"
            
        case .rolesList:
            return "/roles"
            
        case .quitArea(let area):
            var areaId = ""
            if let id = area.id {
                areaId = "\(id)"
            }
            
            
            return "/areas/\(areaId)/users/\(area.sa_user_id)"
            
            
        case .scanQRCode:
            return "/invitation/check"
            
        case .rolesPermissions(_, let role_id):
            return "/users/\(role_id)/permissions"
            
        case .syncArea:
            return "/sync"
            
        case .addSADevice:
            return "/sa"
            
        case .editSAUser(_, let user_id, _, _, _, _, _):
            return "/users/\(user_id)"
            
        case .editCloudUser(let user_id, _, _):
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
            
        case .temporaryIP:
            return "/datatunnel"
            
        case .temporaryIPBySAID:
            return "/datatunnel"
            
        case .getSAToken(let area):
            return "/users/\(area.cloud_user_id)/sa_token"
            
        case .getSAExtensions:
            return "/extensions"
            
        case .commonDeviceList:
            return "/device/types"
            
        case .checkPluginUpdate(let id, _):
            return "/plugins/\(id)"
            
        case .getCaptcha:
            return "/verification/code"
            
        case .downloadPlugin(_, _, _):
            return ""
            
        case .settingTokenAuth:
            return "/setting"
            
        case .getSoftwareVersion:
            return "/supervisor/update"

        case .getSoftwareLatestVersion:
            return "/supervisor/update/latest"
            
        case .updateSoftware:
            return "/supervisor/update"
            
        case .getFirmwareLatestVersion:
            return "/supervisor/firmware/update/latest"
            
        case .getFirmwareVersion:
            return "/supervisor/firmware/update"
            
        case .updateFirmware:
            return "/supervisor/firmware/update"
            
        case .commonDeviceMajorList:
            return "/device/types/major"
            
        case .commonDeviceMinorList:
            return "/device/types/minor"
            
        case .departmentList:
            return "/departments"
            
        case .addDepartment:
            return "/departments"
            
        case .departmentDetail(_, let id):
            return "/departments/\(id)"
            
        case .addDepartmentMember(_, let id, _):
            return "/departments/\(id)/users"
            
        case .updateDepartment(_, let id, _, _):
            return "/departments/\(id)"
            
        case .deleteDepartment(_, let id):
            return "/departments/\(id)"
            
        case .setDepartmentOrders:
            return "/departments/"
            
        case .changePWD(let area, _, _):
            return "/users/\(area.cloud_user_id)"
            
        case .forgetPwd:
            return "/forget_password"
            
        case .scUploadFile:
            let userId = UserManager.shared.currentUser.user_id
            return "/users/\(userId)/file/upload"
            
        case .getAppVersions:
            return "/common/service/app/support/app"
            
        case .getSASupportApiVersion:
            return "/common/service/software/support/api"

        case .saUploadFile:
            return "/files"
            
        case .getAppSupportApiVersion:
            return "/common/service/app/support/api"

        case .setSceneSort:
            return "/scenes"
            
        case .thirdPartyCloudListSC:
            return "/cloud/list"
            
        case .unbindThirdPartyCloud(let area, let app_id):
            return "/apps/\(app_id)/areas/\(area.id ?? "")"
            
        case .thirdPartyCloudListSA:
            return "/apps"
            
        case .feedbackList(let user_id):
            return "/users/\(user_id)/feedbacks"
            
        case .feedbackDetail(let user_id, let feedback_id):
            return "/users/\(user_id)/feedbacks/\(feedback_id)"
            
        case .createFeedback(let user_id, _, _, _, _, _, _, _, _, _, _, _):
            return "/users/\(user_id)/feedbacks"
            

        }
    }
}
