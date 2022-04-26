//
//  ApiServiceAsyncSupport.swift
//  ZhiTing
//
//  Created by iMac on 2021/12/17.
//

import Alamofire
import Moya
import Foundation

struct AsyncApiError: Error {
    let code: Int
    let err: String
}

/// 用swift concurrency对接口层进行封装
struct AsyncApiService {
    /// 获取家庭列表
    /// - Returns: 结果响应
    static func getAreaList() async throws -> [Area] {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.areaList { response in
                continuation.resume(with: .success(response.areas))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }
    
    
    /// 创建云端家庭/公司
    /// - Parameters:
    ///   - name: 名称
    ///   - location_names: 房间数组
    ///   - department_names: 部门数组
    ///   - area_type: 类型
    /// - Returns: 云端家庭/公司信息
    static func createArea(name: String, location_names: [String], department_names: [String], area_type: Area.AreaType) async throws -> CreateAreaResponse {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.createArea(name: name, location_names: location_names, department_names: department_names, area_type: area_type) { response in
                continuation.resume(with: .success(response))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }

    /// 获取家庭/公司详情
    /// - Parameter area: 家庭/公司
    /// - Returns: 结果响应
    static func areaDetail(area: Area) async throws -> AreaDetailResponse {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.areaDetail(area: area) { response in
                continuation.resume(with: .success(response))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }
    
    /// 获取房间列表
    /// - Parameter area: 家庭
    /// - Returns: 房间列表
    static func locationList(area: Area) async throws -> [Location] {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.areaLocationsList(area: area) { response in
                continuation.resume(with: .success(response.locations))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }
    
    /// 获取部门列表
    /// - Parameter area: 公司
    /// - Returns: 部门列表
    static func departmentList(area: Area) async throws -> [Location] {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.departmentList(area: area) { response in
                continuation.resume(with: .success(response.departments))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }
    
    /// 获取设备列表
    /// - Parameters:
    ///   - area: 家庭/公司
    ///   - type: 类型0或不传: 全部设备 1: 有写权限的设备 (执行任务使用) 2: 有读权限或通知权限的设备（触发条件使用）
    /// - Returns: 设备列表
    static func deviceList(area: Area, type: Int = 0) async throws -> [Device] {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.deviceList(type: type, area: area) { response in
                continuation.resume(with: .success(response.devices))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }
    
    /// 获取家庭/公司凭证
    /// - Parameter area: 家庭/公司
    /// - Returns: token响应
    static func getSAToken(area: Area) async throws -> SATokenResponse {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.getSAToken(area: area) { response in
                continuation.resume(with: .success(response))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }
    
    /// 删除sa
    /// - Parameters:
    ///   - area: 家庭/公司
    ///   - is_migration_sa: 是否创建云端家庭
    ///   - is_del_cloud_disk: 是否删除网盘数据
    ///   - cloud_area_id: 云端家庭id， 如果是要创建云端家庭则必须
    ///   - cloud_access_token: 云端家庭token，如果是要创建云端家庭则必须
    /// - Returns: 删除状态响应
    static func deleteSA(area: Area, is_migration_sa: Bool, is_del_cloud_disk: Bool, cloud_area_id: String?, cloud_access_token: String?) async throws -> DeleAreaResponse {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.deleteSA(area: area, is_migration_sa: is_migration_sa, is_del_cloud_disk: is_del_cloud_disk, cloud_area_id: cloud_area_id, cloud_access_token: cloud_access_token) { response in
                continuation.resume(with: .success(response))
                
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }
    
    /// 获取家庭scopeList
    /// - Parameter area: 家庭/公司
    /// - Returns: [授权项]
    static func getAreaScopeList(area: Area) async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.scopeList(area: area) { response in
                continuation.resume(with: .success(response.scopes.map(\.name)))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }
    
    /// 获取家庭scopeToken
    /// - Parameters:
    ///   - area: 家庭/公司
    ///   - scopes: [授权项]
    /// - Returns: 授权
    static func getAreaScopeToken(area: Area, scopes: [String]) async throws -> ScopeTokenModel {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.scopeToken(area: area, scopes: scopes) { response in
                continuation.resume(with: .success(response.scope_token))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }

        }
    }
    
    /// 上传文件到SC
    /// - Parameters:
    ///   - file_upload: 文件Data
    ///   - file_auth: 服务权限类型
    ///   - file_server: 服务类型
    ///   - file_type: 文件类型(头像等)
    /// - Returns: 上传文件结果
    static func scUploadFile(file_upload: Data, file_auth: FileUploadAuth, file_server: FileUploadServer, file_type: FileUploadType) async throws -> FileModel {
        try await withUnsafeThrowingContinuation { continuation in
            ApiServiceManager.shared.uploadSCFile(file_upload: file_upload, file_auth: file_auth, file_server: file_server, file_type: file_type) { response in
                continuation.resume(with: .success(response))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }

        }
    }
    
    /// 上传文件到SA
    /// - Parameters:
    ///   - file_upload: 文件Data
    ///   - file_type: 文件类型(头像等)
    /// - Returns: 上传文件结果
    static func saUploadFile(file_upload: Data, file_type: FileUploadType) async throws -> FileModel {
        try await withUnsafeThrowingContinuation { continuation in
            ApiServiceManager.shared.uploadSAFile(file_upload: file_upload, file_type: file_type) { response in
                continuation.resume(with: .success(response))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }

        }
    }
    
    /// 更改云端账号信息
    /// - Parameters:
    ///   - nickname: 昵称
    ///   - user_id: 用户id
    ///   - avatar_id: 头像文件id
    static func editCloudUser(user_id: Int, nickname: String? = nil, avatar_id: Int? = nil) async throws {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.editCloudUser(user_id: user_id, nickname: nickname, avatar_id: avatar_id) { response in
                continuation.resume(with: .success(()))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }
    
    /// 更改SA用户信息
    /// - Parameters:
    ///   - user_id: sa_user_id
    ///   - nickname: 用户名
    ///   - account_name: 专业版用户名
    ///   - password: 专业版密码
    ///   - old_password: 专业版旧密码
    ///   - avatar_id: 头像id
    ///   - avatar_url: 头像url
    static func editSAUser(user_id: Int = 0, nickname: String? = nil, account_name: String? = nil, password: String? = nil, old_password: String? = nil, avatar_id: Int? = nil) async throws {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.editSAUser(user_id: user_id, nickname: nickname, account_name: account_name, password: password, old_password: old_password, avatar_id: avatar_id) { response in
                continuation.resume(with: .success(()))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
        
    }
    
    /// 获取App支持的最低SA api版本
    /// - Returns: App支持的最低SA api版本
    static func getAppSupportApiVersion(version: String) async throws -> SASupportVersionResponse {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.getAppSupportApiVersions(version: version) { response in
                continuation.resume(with: .success(response))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }
    
    /// 获取SA当前状态(绑定状态、sa版本)
    /// - Parameter area: 绑定SA的家庭
    /// - Returns:  sa状态
    static func getSAStatus(area: Area = AuthManager.shared.currentArea) async throws -> SABindResponse {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.getSAStatus(area: area) { response in
                continuation.resume(with: .success(response))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }
    
    /// 获取SA支持的最低SA api版本
    /// - Returns: SA支持的最低SA api版本
    static func getSASupportApiVersion(version: String) async throws -> SASupportVersionResponse {
        try await withCheckedThrowingContinuation { continuation in
            ApiServiceManager.shared.getSASupportApiVersions(version: version) { response in
                continuation.resume(with: .success(response))
            } failureCallback: { code, err in
                continuation.resume(throwing: AsyncApiError(code: code, err: err))
            }
        }
    }

}
