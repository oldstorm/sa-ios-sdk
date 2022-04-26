//
//  ApiService+Task.swift
//  ZhiTing
//
//  Created by iMac on 2021/7/29.
//

import Foundation
import Moya

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

        case .defaultLocationList:
            return .requestPlain
            
        case .createArea(let name, let location_names, let department_names, let area_type):
            return .requestParameters(parameters: ["name" : name,
                                                   "location_names": location_names,
                                                   "department_names" : department_names,
                                                   "area_type": area_type],
                                      encoding: JSONEncoding.default)
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
            
        case .deviceDetail(_, _, let type):
            return .requestParameters(parameters: ["type": type], encoding: URLEncoding.default)
            
        case .editDevice(_, _, let name, let location_id, let department_id, let logo_type):
            var parameters = [String: Any]()
            if let name = name {
                parameters["name"] = name
            }
            parameters["location_id"] = location_id
            parameters["department_id"] = department_id
            if let logo_type = logo_type {
                parameters["logo_type"] = logo_type
            }

            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .deviceLogoList:
            return .requestPlain

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

        case .locationsList:
            return .requestPlain
            
        case .deleteDevice:
            return .requestPlain
            
        case .deviceList(let type, _):
            return .requestParameters(parameters: ["type": type], encoding: URLEncoding.default)
            
        case .scUploadFile(let file_upload, let file_auth, let file_server, let file_type):
            let file_auth_data = file_auth.rawValue.data(using: .utf8) ?? Data()
            let file_server_data = file_server.rawValue.data(using: .utf8) ?? Data()
            let file_type_data = file_type.type.data(using: .utf8) ?? Data()
            let fileName: String
            let mimeType: String
            let hash = file_upload.sha256().toHexString().data(using: .utf8) ?? Data()
            
            switch file_type {
            case .img:
                fileName = "\(file_upload.sha256().toHexString()).jpeg"
                mimeType = "image/jpeg"
                return .uploadMultipart([
                    //.init(provider: .stream(InputStream(data: file_upload), UInt64(file_upload.count)), name: "file_upload", fileName: fileName, mimeType: "application/octet-stream"),
                    .init(provider: .data(file_upload), name: "file_upload", fileName: fileName, mimeType: mimeType),
                    .init(provider: .data(file_server_data), name: "file_server"),
                    .init(provider: .data(file_auth_data), name: "file_auth"),
                    .init(provider: .data(file_type_data), name: "file_type"),
                    .init(provider: .data(hash), name: "file_hash")
                ])
            case .feedback(let subType):
                switch subType {
                case .image:
                    fileName = "\(file_upload.sha256().toHexString()).jpeg"
                case .video(let ext):
                    fileName = "\(file_upload.sha256().toHexString()).\(ext)"
                }
                mimeType = subType.mimeType
                return .uploadMultipart([
                    .init(provider: .data(file_upload), name: "file_upload", fileName: fileName, mimeType: mimeType),
                    .init(provider: .data(file_server_data), name: "file_server"),
                    .init(provider: .data(file_auth_data), name: "file_auth"),
                    .init(provider: .data(file_type_data), name: "file_type"),
                    .init(provider: .data(hash), name: "file_hash")
                ])
            }

            
            
        case .saUploadFile(_, let file_upload, let file_type):
            let file_type_data = file_type.type.data(using: .utf8) ?? Data()
            let fileName: String
            let mimeType: String
            let hash = file_upload.sha256().toHexString().data(using: .utf8) ?? Data()
            
            switch file_type {
            case .img:
                fileName = "\(file_upload.sha256().toHexString()).jpeg"
                mimeType = "image/jpeg"
                return .uploadMultipart([
                    //.init(provider: .stream(InputStream(data: file_upload), UInt64(file_upload.count)), name: "file_upload", fileName: fileName, mimeType: "application/octet-stream"),
                    .init(provider: .data(file_upload), name: "file_upload", fileName: fileName, mimeType: mimeType),
                    .init(provider: .data(file_type_data), name: "file_type"),
                    .init(provider: .data(hash), name: "file_hash")
                ])
            case .feedback(let subType):
                switch subType {
                case .image:
                    fileName = "\(file_upload.sha256().toHexString()).jpeg"
                case .video(let ext):
                    fileName = "\(file_upload.sha256().toHexString()).\(ext)"
                }

                
                mimeType = subType.mimeType
                return .uploadMultipart([
                    .init(provider: .data(file_upload), name: "file_upload", fileName: fileName, mimeType: mimeType),
                    .init(provider: .data(file_type_data), name: "file_type"),
                    .init(provider: .data(hash), name: "file_hash")
                ])
            }

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
            
        case .login(let phone, let password, let login_type, let country_code,let captcha,let captcha_id):
            if login_type == 0 {
                return .requestParameters(
                    parameters:
                        [
                            "phone": phone,
                            "password": password,
                            "login_type": login_type,
                            "country_code" : country_code
                        ],
                    encoding: JSONEncoding.default
                )
            } else {
                return .requestParameters(
                    parameters:
                        [
                            "phone": phone,
                            "password": password,
                            "login_type": login_type,
                            "country_code": country_code,
                            "captcha": captcha,
                            "captcha_id": captcha_id
                        ],
                    encoding: JSONEncoding.default
                )
            }
            
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
            
        case .unregister(_, let captcha, let captcha_id):
            return .requestParameters(
                parameters:
                    [
                        "captcha": captcha,
                        "captcha_id": captcha_id
                    ],
                encoding: JSONEncoding.default
            )
            
        case .unregisterList:
            return .requestPlain
            
        case .getInviteQRCode(let area, let role_ids, let department_ids):
            var parameters: [String: Any] = ["role_ids": role_ids, "department_ids": department_ids]
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
            
        case .editMember(_, _, let role_ids, let department_ids):
            return .requestParameters(parameters: ["role_ids" : role_ids, "department_ids": department_ids], encoding: JSONEncoding.default)
            
        case .rolesList:
            return .requestPlain
            
        case .quitArea:
            return .requestPlain
            
        case .scanQRCode(let qr_code, _, let nickname, let avatar_url, _):
            var parameters: [String: Any] = ["qr_code": qr_code, "nickname": nickname]
            if let avatar_url = avatar_url {
                parameters["avatar_url"] = avatar_url
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .rolesPermissions:
            return .requestPlain
            
        case .syncArea(let syncModel, _, _):
            let syncModelDict = syncModel.toJSON() ?? [:]
            return .requestParameters(parameters: syncModelDict, encoding: JSONEncoding.default)
            
        case .addSADevice(_, let device):
            let deviceDict = device.toJSON() ?? [:]
            return .requestParameters(parameters: ["device": deviceDict], encoding: JSONEncoding.default)
            
        case .editSAUser(_, _, let nickname, let account_name, let password, let old_password, let avatar_id):
            var parameters: [String: Any] = [:]
            if  nickname != "" && nickname != nil {
                parameters["nickname"] = nickname
            }
            
            if  password != "" && password != nil {
                parameters["password"] = password
            }
                
            if  old_password != "" && old_password != nil {
                parameters["old_password"] = old_password
            }
            
            if  account_name != "" && account_name != nil {
                parameters["account_name"] = account_name
            }
            
            if  avatar_id != 0 && avatar_id != nil {
                parameters["avatar_id"] = avatar_id
            }
            
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
            
        case .editCloudUser(_, let nickname, let avatar_id):
            var parameters: [String: Any] = [:]
            if let nickname = nickname {
                parameters["nickname"] = nickname
            }
                
            if let avatar_id = avatar_id {
                parameters["avatar_id"] = avatar_id
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case .checkSABindState:
            return .requestPlain
            
        case .deleteSA(_, let is_migration_sa, let is_del_cloud_disk, let cloud_area_id, let cloud_access_token):
            var parameters: [String: Any] = ["is_migration_sa" : is_migration_sa, "is_del_cloud_disk" : is_del_cloud_disk]
            if let cloud_area_id = cloud_area_id {
                parameters["cloud_area_id"] = cloud_area_id
            }
            
            if let cloud_access_token = cloud_access_token {
                parameters["cloud_access_token"] = cloud_access_token
            }
            
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

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
            
        case .getSoftwareVersion:
            return .requestPlain
            
        case .getSoftwareLatestVersion:
            return .requestPlain
            
        case .migrationAddr:
            return .requestPlain
            
        case .migrationCloudToLocal(_, let migration_url, let backup_file, let sum):
            return .requestParameters(parameters: ["migration_url" : migration_url, "backup_file": backup_file, "sum": sum], encoding: JSONEncoding.default)

        case .updateSoftware(_, let version):
            return .requestParameters(parameters: ["version": version], encoding: JSONEncoding.default)
            
        case .getFirmwareLatestVersion:
            return .requestPlain
            
        case .getFirmwareVersion:
            return .requestPlain
            
        case .updateFirmware(_, let version):
            return .requestParameters(parameters: ["version": version], encoding: JSONEncoding.default)

        case .commonDeviceMajorList:
            return .requestPlain
            
        case .commonDeviceMinorList(_, let type):
            return .requestParameters(parameters: ["type": type], encoding: URLEncoding.default)
            
        case .departmentList:
            return .requestPlain
            
        case .addDepartment(_, let name):
            return .requestParameters(parameters: ["name" : name], encoding: JSONEncoding.default)
            
        case .departmentDetail:
            return .requestPlain
            
        case .addDepartmentMember(_, _, let users):
            return .requestParameters(parameters: ["users" : users], encoding: JSONEncoding.default)
            
        case .updateDepartment(_, _, let name, let manager_id):
            var parameters: [String: Any] = ["name" : name]
            if let manager_id = manager_id {
                parameters["manager_id"] = manager_id
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .deleteDepartment:
            return .requestPlain
            
        case .setDepartmentOrders(_, let department_order):
            return .requestParameters(parameters: ["departments_id": department_order], encoding: JSONEncoding.default)
            
        case .changePWD( _, let old_password,let new_password):
            return .requestParameters(parameters: ["old_password": old_password, "new_password": new_password], encoding: JSONEncoding.default)
            
        case .forgetPwd(let country_code, let phone, let new_password, let captcha, let captcha_id):
            return .requestParameters(
                parameters:
                    [
                        "country_code": country_code,
                        "phone": phone,
                        "new_password": new_password,
                        "captcha": captcha,
                        "captcha_id": captcha_id
                    ],
                encoding: JSONEncoding.default
            )
            
        case .getSAExtensions:
            return .requestPlain
            
        case .getAppVersions:
            return .requestParameters(
                parameters: ["client": "ios", "app_type": "zhiting"],
                encoding: URLEncoding.default
            )
        case .getAppSupportApiVersion(let version):
            return .requestParameters(
                parameters: ["version": version, "client": "ios"],
                encoding: URLEncoding.default
            )
            
        case .setSceneSort(_,let sceneIds):
            return .requestParameters(parameters: ["scene_ids": sceneIds], encoding: JSONEncoding.default)
            
        case .getSAStatus:
            return .requestPlain
            
        case .thirdPartyCloudListSC(let area):
            var parameters = [String: Any]()
            if let area_id = area.id {
                parameters["area_id"] = area_id
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
        case .thirdPartyCloudListSA(let area):
            var parameters = [String: Any]()
            if let area_id = area.id {
                parameters["area_id"] = area_id
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)

        case .unbindThirdPartyCloud:
            return .requestPlain
            
        case .getSASupportApiVersion(let version):
            return .requestParameters(parameters: ["version": version], encoding: URLEncoding.default)
            
        case .feedbackList:
            return .requestPlain
            
        case .feedbackDetail:
            return .requestPlain
            
        case .createFeedback(_, let feedback_type, let type, let description, let file_ids, let contact_information, let is_auth, let api_version, let app_version, let phone_model, let phone_system, let sa_id):
            var parameters = [String: Any]()
            parameters["feedback_type"] = feedback_type
            parameters["type"] = type
            parameters["description"] = description
            parameters["is_auth"] = is_auth
            if let file_ids = file_ids {
                parameters["file_ids"] = file_ids
            }
            
            if let contact_information = contact_information {
                parameters["contact_information"] = contact_information
            }
            
            if let api_version = api_version, let app_version = app_version, let phone_model = phone_model, let phone_system = phone_system {
                parameters["api_version"] = api_version
                parameters["app_version"] = app_version
                parameters["phone_model"] = phone_model
                parameters["phone_system"] = "iOS " + phone_system
                parameters["sa_id"] = sa_id ?? ""
            } 
            
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
        
    }
}
