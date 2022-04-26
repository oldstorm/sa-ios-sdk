//
//  FeedbackViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/22.
//

import Foundation
import UIKit
import TZImagePickerController

class FeedbackViewController: BaseViewController {
    private lazy var typeCell = FeedbackTypeSelectViewCell()

    private lazy var contactCell = FeedbackContactCell()
    
    private lazy var descriptionCell = FeedbackDecriptionViewCell()

    private lazy var agreementCell = FeedbackAgreementCell()

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        
    }
    
    private lazy var commitButton = Button().then {
        $0.setTitle("提交".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.addTarget(self, action: #selector(commit), for: .touchUpInside)
        $0.isEnabled = false
        $0.alpha = 0.6
    }
    
    private lazy var footerView = UIView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 70))

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "我要反馈".localizedString

    }
    
    override func setupViews() {
        footerView.addSubview(commitButton)
        view.backgroundColor = .custom(.gray_f1f4fd)
        view.addSubview(tableView)
        tableView.tableFooterView = footerView
        descriptionCell.descriptionView.viewHeightChange = { [weak self] in
            guard let self = self else { return }
            self.tableView.performBatchUpdates(nil)

        }
        
        descriptionCell.descriptionView.addItemCallback = { [weak self] in
            guard let self = self else { return }
            self.presentPicker()
        }
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        commitButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(Screen.screenWidth - 30)
            $0.center.equalToSuperview()
        }

    }
    
    override func setupSubscriptions() {
        typeCell.selectView.typeChanged
            .combineLatest(descriptionCell.descriptionView.textChanged)
            .sink { [weak self] feedbackType, description in
                switch feedbackType {
                case .problem(let category):
                    self?.commitButton.isEnabled = (description != "" && category != nil)
                    self?.commitButton.alpha = (description != "" && category != nil) ? 1 : 0.6
                case .suggestion(let category):
                    self?.commitButton.isEnabled = (description != "" && category != nil)
                    self?.commitButton.alpha = (description != "" && category != nil) ? 1 : 0.6
                }
            }
            .store(in: &cancellables)
        
        typeCell.selectView.typeChanged
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

    }
    
    override func navPop() {
        var ifAfterEdit = false
        if descriptionCell.descriptionView.textView.text != ""
            || descriptionCell.descriptionView.descriptionItems.count > 0
            || agreementCell.selectButton.isSelected
            || contactCell.textField.text?.count ?? 0 > 0
            || typeCell.selectView.selectedType.selectedSubType {
            ifAfterEdit = true
        }


        if ifAfterEdit {
            TipsAlertView.show(message: "退出后修改将丢失,是否退出".localizedString) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        var ifAfterEdit = false
        if descriptionCell.descriptionView.textView.text != ""
            || descriptionCell.descriptionView.descriptionItems.count > 0
            || agreementCell.selectButton.isSelected
            || contactCell.textField.text?.count ?? 0 > 0
            || typeCell.selectView.selectedType.selectedSubType {
            ifAfterEdit = true
        }

        if ifAfterEdit {
            TipsAlertView.show(message: "退出后修改将丢失,是否退出".localizedString) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return false
        } else {
            return true
        }
    }

}

extension FeedbackViewController: TZImagePickerControllerDelegate {
    private func presentPicker() {
        guard let pickerVC = TZImagePickerController(maxImagesCount: 1, delegate: self) else {
            return
        }
        pickerVC.naviBgColor = .custom(.white_ffffff)
        pickerVC.naviTitleColor = .custom(.black_3f4663)
        pickerVC.barItemTextColor = .custom(.blue_2da3f6)
        pickerVC.iconThemeColor = .custom(.blue_2da3f6)
        pickerVC.oKButtonTitleColorNormal = .custom(.blue_2da3f6)
        pickerVC.allowPickingVideo = true
        pickerVC.allowPickingImage = true
        pickerVC.allowPickingMultipleVideo = false
        pickerVC.allowPickingOriginalPhoto = true
       
        pickerVC.photoPreviewPageUIConfigBlock = { _,_,_,_,_,_,_,_,btn,_,_ in
            btn?.setTitleColor(.white, for: .normal)
        }
        pickerVC.photoOriginSelImage = .assets(.fileSelected_selected)
        pickerVC.photoSelImage = .assets(.fileSelected_selected)
        
        
        pickerVC.modalPresentationStyle = .fullScreen
        present(pickerVC, animated: true, completion: nil)
        showLoadingView()
        
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: PHAsset!) {
        TZImageManager.default().requestVideoURL(with: asset) { [weak self] url in
            guard let self = self,
                  let url = url,
                  let data = try? Data(contentsOf: url)
            else {
                DispatchQueue.main.async {
                    self?.showToast(string: "获取资源失败".localizedString)
                    self?.hideLoadingView()
                }
                return
            }
            
            DispatchQueue.main.async {
                if data.count > 50 * 1024 * 1024 {
                    self.showToast(string: "附件大小不得超过50M".localizedString)
                    self.hideLoadingView()
                } else {
                    self.updateItem(cover: coverImage, data: data, feedbackSubType: .video(url.pathExtension.lowercased()))
                }

                
            }
            
        } failure: { [weak self] info in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showToast(string: "获取资源失败".localizedString)
                self.hideLoadingView()
            }
            
        }
    }
    
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        if let photo = photos.first, let photoData = photo.jpegData(compressionQuality: 0.6) {
            if photoData.count > 50 * 1024 * 1024 {
                showToast(string: "附件大小不得超过50M".localizedString)
                self.hideLoadingView()
            } else {
                updateItem(cover: photo, data: photoData, feedbackSubType: .image)
            }

            
            
            return
        }
        
        showToast(string: "获取资源失败".localizedString)
        self.hideLoadingView()
    }
    
    func tz_imagePickerControllerDidCancel(_ picker: TZImagePickerController!) {
        self.hideLoadingView()
    }
    
    

}

extension FeedbackViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch typeCell.selectView.selectedType {
        case .problem:
            return 4
        case .suggestion:
            return 3
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return typeCell
        } else if indexPath.row == 1 {
            return descriptionCell
        } else if indexPath.row == 2 {
            return contactCell
        } else {
            return agreementCell
        }
        
    }
    
    
}


extension FeedbackViewController {
    /// 提交反馈
    @objc private func commit() {
        let feedback_type: Int
        let type: Int
        let is_auth: Bool
        var api_version: String?
        var app_version: String?
        var phone_model: String?
        var phone_system: String?
        var file_ids: [Int]?
        let sa_id = AuthManager.shared.currentArea.sa_id

        switch typeCell.selectView.selectedType {
        case .problem(let category):
            feedback_type = 1
            type = category?.rawValue ?? 1
            is_auth = agreementCell.selectButton.isSelected
        case .suggestion(let category):
            feedback_type = 2
            type = category?.rawValue ?? 7
            is_auth = false
        }
        let description = descriptionCell.descriptionView.textView.text ?? ""
        let contact_information = contactCell.textField.text ?? ""
        if is_auth {
            api_version = apiVersion
            app_version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            phone_system = UIDevice.current.systemVersion
            phone_model = UIDevice.current.modelName
        }
        
        file_ids = descriptionCell.descriptionView.descriptionItems.map(\.file_id)
        
        ApiServiceManager.shared.createFeedback(
            user_id: UserManager.shared.currentUser.user_id,
            feedback_type: feedback_type,
            type: type,
            description: description,
            file_ids: file_ids,
            contact_information: contact_information,
            is_auth: is_auth,
            api_version: api_version,
            app_version: app_version,
            phone_model: phone_model,
            phone_system: phone_system,
            sa_id: sa_id) { [weak self] response in
                guard let self = self else { return }
                self.showToast(string: "谢谢您的反馈，我们将持续为您改进".localizedString)
                self.navigationController?.popViewController(animated: true)
            } failureCallback: { [weak self] code, err in
                guard let self = self else { return }
                self.hideLoadingView()
                self.showToast(string: err)
            }

    }
    
    /// 上传反馈附件
    /// - Parameters:
    ///   - cover: 封面
    ///   - data: 数据
    private func updateItem(cover: UIImage, data: Data, feedbackSubType: FileUploadType.FeedbackSubType) {
        ApiServiceManager.shared.uploadSCFile(file_upload: data, file_auth: .private, file_server: .cloud, file_type: .feedback(feedbackSubType)) { [weak self] file in
            guard let self = self else { return }
            self.descriptionCell.descriptionView.descriptionItems.append(.init(file_id: file.file_id, cover: cover, data: data))
            self.descriptionCell.descriptionView.collectionView.reloadData()
            self.hideLoadingView()
            
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.showToast(string: err)
            self.hideLoadingView()
        }
    }
}
