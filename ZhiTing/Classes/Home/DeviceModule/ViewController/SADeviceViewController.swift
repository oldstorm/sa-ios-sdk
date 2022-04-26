//
//  SADeviceViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/20.
//

import UIKit

class SADeviceViewController: BaseViewController {
    var device_id = 0
    
    var area = Area()
    
    var cellsArray = [UITableViewCell]()
    
    private lazy var settingButton = Button().then {
        $0.setImage(.assets(.settings), for: .normal)
        $0.frame.size = CGSize(width: 18, height: 18)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let vc = DeviceDetailViewController()
            vc.area = self.area
            vc.device_id = self.device_id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    lazy var deviceImg = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.device_sa)
    }
    
    private lazy var coverView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var deviceNameLabel = Label().then {
        $0.text = "Smart Assistant"
        $0.font = .font(size: 16, type: .bold)
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "设备详情".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingButton)
        requestNetwork()
    }

    private lazy var softwareCell = ValueDetailCell().then {
        $0.title.text = "软件升级".localizedString
        $0.line.isHidden = true
        $0.bottomLine.isHidden = false
        $0.valueLabel.text = " "
    }
    
    private lazy var firmwareCell = ValueDetailCell().then {
        $0.title.text = "固件升级".localizedString
        $0.line.isHidden = true
        $0.bottomLine.isHidden = false
        $0.valueLabel.text = " "
    }

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = ZTScaleValue(50)
        if #available(iOS 15.0, *) {
            $0.sectionHeaderTopPadding = 0
        }
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var deleteButton = ImageTitleButton(frame: .zero, icon: nil, title: "删除设备".localizedString, titleColor: UIColor.custom(.black_333333), backgroundColor: UIColor.custom(.white_ffffff)).then {
        $0.isHidden = true
    }
    
    var tipsAlert: DeleteSAAlert?
    
    /// sa是否绑定云端
    var isBindCloud = false
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(coverView)
        coverView.addSubview(deviceImg)
        coverView.addSubview(deviceNameLabel)
        view.addSubview(tableView)
        view.addSubview(deleteButton)
        
        deleteButton.clickCallBack = { [weak self] in
            guard let self = self else { return }
            self.tipsAlert = DeleteSAAlert.show(area: self.area, isBindCloud: self.isBindCloud) { [weak self] is_migration_sa, is_del_cloud_disk in
                guard let self = self else { return }
                Task { [weak self] in
                    guard let self = self else { return }
                    await self.deleteSA(is_migration_sa: is_migration_sa, is_del_cloud_disk: is_del_cloud_disk)
                }

            } loginClick: { [weak self] in
                let vc = LoginViewController()
                vc.loginComplete = { [weak self] in
                    self?.tipsAlert?.removeFromSuperview()
                    self?.navigationController?.popToRootViewController(animated: true)
                }
                vc.hidesBottomBarWhenPushed = true
                let nav = BaseNavigationViewController(rootViewController: vc)
                nav.modalPresentationStyle = .overFullScreen
                AppDelegate.shared.appDependency.tabbarController.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    override func setupConstraints() {
        
        coverView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(246))
        }
        
        deviceImg.snp.makeConstraints {
            $0.width.height.equalTo(ZTScaleValue(120))
            $0.top.equalToSuperview().offset(ZTScaleValue(25))
            $0.centerX.equalToSuperview()
        }
        
        deviceNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(deviceImg.snp.bottom).offset(ZTScaleValue(15))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(coverView.snp.bottom).offset(ZTScaleValue(10))
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(deleteButton.snp.top).offset(-15)
        }
        
        deleteButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(-ZTScaleValue(15))
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(10) - Screen.bottomSafeAreaHeight)
        }
    }
    
    private func requestNetwork() {
        if area.is_bind_sa {
            ApiServiceManager.shared.getSAExtensions(area: area) { [weak self] response in
                self?.area.extensions = response.extension_names
            } failureCallback: { [weak self] code, err in
                self?.showToast(string: err)
            }
        }
        
        ApiServiceManager.shared.deviceDetail(area: area, device_id: device_id) { [weak self] (response) in
            guard let self = self else { return }
            self.deviceNameLabel.text = response.device_info.name

            if (response.device_info.permissions.delete_device || response.device_info.permissions.update_device) {
                self.settingButton.isHidden = false
            } else {
                self.settingButton.isHidden = true
            }
            
            self.getRolePermission()
            self.getUserDetail()
            
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
        
        
    }
    
    private func getRolePermission() {
        ApiServiceManager.shared.rolesPermissions(area: area, user_id: area.sa_user_id) { [weak self] response in
            guard let self = self else { return }
            self.cellsArray.removeAll()

            if response.permissions.sa_software_upgrade {
                self.cellsArray.append(self.softwareCell)
            }
            
            if response.permissions.sa_firmware_upgrade {
                self.cellsArray.append(self.firmwareCell)
            }
            
            self.tableView.reloadData()
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.showToast(string: err)
        }

    }
    
    private func getUserDetail() {
        ApiServiceManager.shared.userDetail(area: area, id: area.sa_user_id) { [weak self] response in
            guard let self = self else { return }
            self.isBindCloud = response.area?.is_bind_cloud == true
            self.deleteButton.isHidden = !response.is_owner
            
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.showToast(string: err)
        }

    }
    
    @MainActor
    private func deleteSA(is_migration_sa: Bool, is_del_cloud_disk: Bool) async {
        do {
            showLoadingView()
            /// 删除SA响应
            let response: DeleAreaResponse
            
            /// 同时云端家庭
            if is_migration_sa {
                let cloudAreaResponse = try await AsyncApiService.createArea(name: area.name, location_names: [], department_names: [], area_type: area.areaType)
                
                response = try await AsyncApiService.deleteSA(area: area, is_migration_sa: true, is_del_cloud_disk: is_del_cloud_disk, cloud_area_id: cloudAreaResponse.id, cloud_access_token: cloudAreaResponse.cloud_sa_user_info?.token)
            } else {
                response = try await AsyncApiService.deleteSA(area: area, is_migration_sa: false, is_del_cloud_disk: is_del_cloud_disk, cloud_area_id: nil, cloud_access_token: nil)
            }
            
            if response.remove_status == 3 { /// 移除成功
                hideLoadingView()
                AreaCache.deleteArea(id: area.id, sa_token: area.sa_user_token)
                if AreaCache.areaList().count == 0 {
                    self.authManager.currentArea = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family).transferToArea()
                    if UserManager.shared.isLogin {
                        self.authManager.syncLocalAreasToCloud(needUpdateCurrentArea: true) { [weak self] in
                            guard let self = self else { return }
                            self.navigationController?.popToRootViewController(animated: true)
                            self.showToast(string: "删除成功".localizedString)
                        }
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                        self.showToast(string: "删除成功".localizedString)
                    }
                    
                } else if self.authManager.currentArea.id == area.id && self.authManager.currentArea.sa_user_token == area.sa_user_token {
                    if let area = AreaCache.areaList().first {
                        self.authManager.currentArea = area
                    }
                    self.showToast(string: "删除成功".localizedString)
                    self.navigationController?.popViewController(animated: true)
                    
                } else {
                    self.showToast(string: "删除成功".localizedString)
                    self.navigationController?.popViewController(animated: true)
                }
                
            } else if response.remove_status == 2 { /// 移除失败
                hideLoadingView()
                TipsAlertView.show(message: "提示\n\n删除智慧中心失败,请稍后再试", sureCallback: nil)
            } else if response.remove_status == 1 { /// 移除中
                hideLoadingView()
                
                let areas = AreaCache.areaList().filter({ $0.id != self.area.id })
                
                if self.area.needRebindCloud || self.area.cloud_user_id == -1 { /// 未同步到云端的家庭直接移除缓存
                    AreaCache.deleteArea(id: area.id, sa_token: area.sa_user_token)
                }

                if areas.count == 0 {
                    /// 若除了正在删除中的家庭外没有家庭了,则帮其自动创建一个
                    self.authManager.currentArea = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family).transferToArea()
                    if UserManager.shared.isLogin {
                        self.authManager.syncLocalAreasToCloud(needUpdateCurrentArea: true) { [weak self] in
                            guard let self = self else { return }
                            WarningAlert.show(message: "删除数据和云盘文件需要一定时间，已为你后台运行，可在首页切换家庭/公司查看删除情况。".localizedString, sureTitle: "确定".localizedString) { [weak self] in
                                guard let self = self else { return }
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    } else {
                        WarningAlert.show(message: "删除数据和云盘文件需要一定时间，已为你后台运行，可在首页切换家庭/公司查看删除情况。".localizedString, sureTitle: "确定".localizedString) { [weak self] in
                            guard let self = self else { return }
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                } else {
                    /// 删除的是当前家庭时 帮其切换至对应局域网的家庭，若无则切换至第一个
                    if AuthManager.shared.currentArea.id == self.area.id {
                        if let area = areas.first(where: { $0.bssid == NetworkStateManager.shared.getWifiBSSID() }) {
                            AuthManager.shared.currentArea = area
                        } else {
                            if let area = areas.first {
                                AuthManager.shared.currentArea = area
                            }
                        }
                    }
                    
                    WarningAlert.show(message: "删除数据和云盘文件需要一定时间，已为你后台运行，可在首页切换家庭/公司查看删除情况。".localizedString, sureTitle: "确定".localizedString) { [weak self] in
                        guard let self = self else { return }
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
            
        } catch {
            hideLoadingView()
            TipsAlertView.show(message: "提示\n\n删除智慧中心失败,请稍后再试", sureCallback: nil)
        }
        

    }

}

extension SADeviceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellsArray[indexPath.row]

    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = SAUpdateViewController()
        switch cellsArray[indexPath.row] {
        case softwareCell:
            print("点击软件升级")
            vc.updateType = .software
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case firmwareCell:
            print("点击固件更新")
            vc.updateType = .firmware
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    
}

