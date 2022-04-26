//
//  AvatarViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/2/21.
//

import UIKit
import TZImagePickerController

class AvatarViewController: BaseViewController {
    private lazy var queue = DispatchQueue(label: "updateAvatarQueue")
    private lazy var sema = DispatchSemaphore(value: 1)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    
    private lazy var changeBtn = CustomButton(buttonType:
                                                    .centerTitleAndLoading(normalModel:
                                                                                .init(
                                                                                    title: "更换头像".localizedString,
                                                                                    titleColor: .custom(.white_ffffff),
                                                                                    font: .font(size: 14, type: .bold),
                                                                                    backgroundColor: .custom(.blue_2da3f6)
                                                                                )
                                                                          )).then {
        $0.layer.cornerRadius = 25
        $0.clipsToBounds = true
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.addTarget(self, action: #selector(presentPicker), for: .touchUpInside)
    }
    
    private lazy var avatar = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .black
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(popVC)))
    }

    
    override func setupViews() {
        view.backgroundColor = .black
        view.addSubview(avatar)
        view.addSubview(changeBtn)
        
        if let userAvatarData = UserManager.shared.userAvatarData {
            avatar.image = UIImage(data: userAvatarData)
        } else {
            avatar.image = .assets(.default_avatar)
        }
        

    }
    
    override func setupConstraints() {
        avatar.snp.makeConstraints {
            $0.width.equalTo(Screen.screenWidth)
            $0.height.equalTo(Screen.screenWidth)
            $0.center.equalToSuperview()
        }

        changeBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-15 - Screen.bottomSafeAreaHeight)
            $0.left.equalToSuperview().offset(ZTScaleValue(60))
            $0.right.equalToSuperview().offset(ZTScaleValue(-60))
            $0.height.equalTo(50)
        }
    }
    
    @objc
    private func popVC() {
        navigationController?.popViewController(animated: true)
    }

}

extension AvatarViewController: TZImagePickerControllerDelegate {
    @objc
    private func presentPicker() {
        guard let pickerVC = TZImagePickerController(maxImagesCount: 1, delegate: self) else {
            return
        }
        pickerVC.naviBgColor = .custom(.white_ffffff)
        pickerVC.naviTitleColor = .custom(.black_3f4663)
        pickerVC.barItemTextColor = .custom(.blue_2da3f6)
        pickerVC.iconThemeColor = .custom(.blue_2da3f6)
        pickerVC.oKButtonTitleColorNormal = .custom(.blue_2da3f6)
        pickerVC.allowPickingVideo = false
        pickerVC.allowPickingImage = true
        pickerVC.allowPickingMultipleVideo = false
        pickerVC.allowPickingOriginalPhoto = true
        pickerVC.allowCrop = true
        pickerVC.cropRect = CGRect(x: 0, y: Screen.screenHeight / 2 - Screen.screenWidth / 2, width: Screen.screenWidth, height: Screen.screenWidth)
        pickerVC.cropViewSettingBlock = { view in
            if let view = view {
                view.layer.borderColor = UIColor.clear.cgColor
                let cropView = CropView(frame: view.bounds)
                view.addSubview(cropView)
            }
        }
        pickerVC.photoPreviewPageUIConfigBlock = { _,_,_,_,_,_,_,_,btn,_,_ in
            btn?.setTitleColor(.white, for: .normal)
        }
        pickerVC.photoOriginSelImage = .assets(.fileSelected_selected)
        pickerVC.photoSelImage = .assets(.fileSelected_selected)
        
        
        pickerVC.modalPresentationStyle = .fullScreen
        present(pickerVC, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        changeBtn.selectedChangeView(isLoading: true)
        view.isUserInteractionEnabled = false
        disableSideSliding = true
        if let photoData = photos.first?.jpegData(compressionQuality: 0.6) {
//            Task(priority: .high) {
//                await self.uploadAvatar(data: photoData)
//            }
            
            updateAvatar(data: photoData)
        } else {
            changeBtn.selectedChangeView(isLoading: false)
            view.isUserInteractionEnabled = true
            disableSideSliding = false
        }
        
    }

}

extension AvatarViewController {
    /// 修改头像
    /// - Parameter data: 头像data
    private func updateAvatar(data: Data?) {
        guard let data = data else {
            showToast(string: "获取相册图片失败".localizedString)
            changeBtn.selectedChangeView(isLoading: false)
            view.isUserInteractionEnabled = true
            disableSideSliding = false
            return
        }
        
        
        view.isUserInteractionEnabled = false
        queue.async { [weak self] in
            guard let self = self else { return }
            /// 头像是否成功以SC为准
            var isSuccess = false
            if UserManager.shared.isLogin { /// 已登录SC的话先更新SC上用户头像
                
                /// 上传头像文件
                var file_id: Int?
                self.sema.wait()
                ApiServiceManager.shared.uploadSCFile(file_upload: data, file_auth: .private, file_server: .cloud, file_type: .img) { [weak self] response in
                    guard let self = self else { return }
                    file_id = response.file_id
                    self.sema.signal()
                    
                } failureCallback: { [weak self] code, err in
                    guard let self = self else { return }
                    self.sema.signal()
                    
                }
                /// 更新SC个人资料头像
                self.sema.wait()
                if let file_id = file_id {
                    
                    ApiServiceManager.shared.editCloudUser(user_id: UserManager.shared.currentUser.user_id, avatar_id: file_id) { [weak self] _ in
                        guard let self = self else { return }
                        /// 保存头像data
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            UserManager.shared.userAvatarData = data
                            self.avatar.image = UIImage(data: data)
                            isSuccess = true
                            self.sema.signal()
                        }
                    } failureCallback: { [weak self] code, err in
                        guard let self = self else { return }
                        self.sema.signal()
                    }

                } else {
                    self.sema.signal()
                }
                
            }

            
            if !UserManager.shared.isLogin && !AuthManager.shared.isSAEnviroment || AuthManager.shared.currentArea.id == nil {
                UserManager.shared.userAvatarData = data
                self.avatar.image = UIImage(data: data)
                isSuccess = true
            } else {
                /// 更新SA上的用户头像
                /// 上传头像文件
                var file_id: Int?
                self.sema.wait()
                ApiServiceManager.shared.uploadSAFile(file_upload: data, file_type: .img) { [weak self] response in
                    guard let self = self else { return }
                    file_id = response.file_id
                    self.sema.signal()
                    
                } failureCallback: { [weak self] code, err in
                    guard let self = self else { return }
                    self.sema.signal()
                    
                }
                
                
                /// 更新SA个人资料头像
                self.sema.wait()
                if let file_id = file_id {
                    ApiServiceManager.shared.editSAUser(user_id: AuthManager.shared.currentArea.sa_user_id, avatar_id: file_id) { [weak self] _ in
                        guard let self = self else { return }
                        /// 保存头像data
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            UserManager.shared.userAvatarData = data
                            self.avatar.image = UIImage(data: data)
                            if !UserManager.shared.isLogin {
                                isSuccess = true
                            }

                            self.sema.signal()
                        }
                    } failureCallback: { [weak self] code, err in
                        guard let self = self else { return }
                        self.sema.signal()
                    }

                } else {
                    self.sema.signal()
                }
                 
            }
            
            self.sema.wait()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.changeBtn.selectedChangeView(isLoading: false)
                self.view.isUserInteractionEnabled = true
                self.disableSideSliding = false
                self.sema.signal()
                if isSuccess {
                    self.showToast(string: "修改成功".localizedString)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.showToast(string: "修改失败".localizedString)
                }

            }
        }

        

    }
}


extension AvatarViewController {
    /// 更新头像
    /// - Parameter data: 图片data
    @MainActor
    private func uploadAvatar(data: Data?) async {
        guard let data = data else {
            showToast(string: "获取相册图片失败".localizedString)
            GlobalLoadingView.hide()
            return
        }
        
        if UserManager.shared.isLogin { /// 已登录SC的话先更新SC上用户头像
            do {
                /// 上传头像文件
                let response = try await AsyncApiService.scUploadFile(file_upload: data, file_auth: .private, file_server: .cloud, file_type: .img)
                /// 更新SC个人资料头像
                try await AsyncApiService.editCloudUser(user_id: UserManager.shared.currentUser.user_id, avatar_id: response.file_id)

                /// 保存头像data
                UserManager.shared.userAvatarData = data
                avatar.image = UIImage(data: data)
            } catch {
                if let error = error as? AsyncApiError {
                    showToast(string: error.err)
                }
            }
        }
        
        if !UserManager.shared.isLogin && !AuthManager.shared.isSAEnviroment || AuthManager.shared.currentArea.id == nil {
            UserManager.shared.userAvatarData = data
        } else {
            /// 更新SA上的用户头像
            do {
                /// 上传头像文件
                var time = Date().timeIntervalSince1970
                let response = try await AsyncApiService.saUploadFile(file_upload: data, file_type: .img)
                time = Date().timeIntervalSince1970 - time
                print(time)
                /// 更新SA个人资料头像
                try await AsyncApiService.editSAUser(user_id: authManager.currentArea.sa_user_id, avatar_id: response.file_id)
                /// 保存头像data
                UserManager.shared.userAvatarData = data
                avatar.image = UIImage(data: data)
            } catch { }
        }
           
        GlobalLoadingView.hide()
        
        


    }


}
