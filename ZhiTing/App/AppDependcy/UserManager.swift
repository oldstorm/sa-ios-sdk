//
//  UserManager.swift
//  ZhiTing
//
//  Created by iMac on 2022/2/23.
//

import Foundation


/// 管理当前用户信息的类
/// 如果是未登录过的情况下 缓存的信息是本地缓存的用户信息
/// 如果是登录过的情况下 缓存的信息是SC的用户信息
/// 切换家庭时会将信息同步覆盖到对应的SA上(头像昵称等)
class UserManager {
    static let shared = UserManager()
    
    private lazy var queue = DispatchQueue(label: "UserManager.updateCurrentSAUser.queue")
    
    /// 正在更同步用户头像昵称到当前SA (防止多次触发)
    var updatingSAUser = false
    
    /// 是否登录云端账号
    @UserDefaultBool(key: .isLogin) var isLogin
    
    /// 云端账号手机号
    @UserDefaultWrapper(key: .phoneNumber) var currentPhoneNumber: String?
    
    /// 用户头像data缓存
    @UserDefaultWrapper(key: .userAvatarData) var userAvatarData: Data?

    /// 当前账号
    var currentUser = User()
    
    private init() {}
    
    
    /// 将本地的用户昵称头像同步到SA
    func updateCurrentSAUser() {
        if !AuthManager.shared.isSAEnviroment && !UserManager.shared.isLogin || AuthManager.shared.currentArea.id == nil || updatingSAUser {
            return
        }
        
        updatingSAUser = true

        queue.async {
            /// 如果本地有头像缓存的话 同步头像到SA
            if let userAvatarData = UserManager.shared.userAvatarData {
                ApiServiceManager.shared.uploadSAFile(file_upload: userAvatarData, file_type: .img) { [weak self] response in
                    guard let self = self else { return }
                    ApiServiceManager.shared.editSAUser(user_id: AuthManager.shared.currentArea.sa_user_id, nickname: UserManager.shared.currentUser.nickname, avatar_id: response.file_id, successCallback: { [weak self] _ in
                        self?.updatingSAUser = false
                    }, failureCallback: { [weak self] _, _ in
                        self?.updatingSAUser = false
                    })
                } failureCallback: { [weak self] code, err in
                    guard let self = self else { return }
                    ApiServiceManager.shared.editSAUser(user_id: AuthManager.shared.currentArea.sa_user_id, nickname: UserManager.shared.currentUser.nickname, successCallback: { [weak self] _ in
                        self?.updatingSAUser = false
                    }, failureCallback: { [weak self] _, _ in
                        self?.updatingSAUser = false
                    })
                }

            } else {
                ApiServiceManager.shared.editSAUser(user_id: AuthManager.shared.currentArea.sa_user_id, nickname: UserManager.shared.currentUser.nickname, successCallback: { [weak self] _ in
                    self?.updatingSAUser = false
                }, failureCallback: { [weak self] _, _ in
                    self?.updatingSAUser = false
                })
            }
        }
       
    }
}
