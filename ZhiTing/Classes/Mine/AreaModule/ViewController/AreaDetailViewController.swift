//
//  AreaDetailViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/15.
//
import RealmSwift
import UIKit

class AreaDetailViewController: BaseViewController {

    var area = Area() {
        didSet {
            nameCell.valueLabel.text = area.name
            
        }
    }
    
    var rolePermission = RolePermission()
    
    var locations = [Location]()
    
    var members = [User]()

    private var tipsAlert: TipsAlertView?
    private var tipsChooseAlert: TipsChooseAlertView?

    private lazy var nameCell = ValueDetailCell().then {
        $0.title.text = "名称".localizedString
        $0.valueLabel.text = " "
    }
    
    private lazy var qrCodeCell = ValueDetailCell().then {
        $0.title.text = "二维码".localizedString
        $0.valueLabel.text = " "
    }
    
    private lazy var areasNumCell = ValueDetailCell().then {
        $0.title.text = "房间/区域".localizedString
        $0.valueLabel.text = " "
    }

    private lazy var section1Header = AreaMemberSectionHeader()
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.register(ValueDetailCell.self, forCellReuseIdentifier: ValueDetailCell.reusableIdentifier)
        $0.register(AreaMemberCell.self, forCellReuseIdentifier: AreaMemberCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = ZTScaleValue(50)
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var deleteButton = ImageTitleButton(frame: .zero, icon: nil, title: "删除".localizedString, titleColor: UIColor.custom(.black_333333), backgroundColor: UIColor.custom(.white_ffffff)).then {
        $0.isHidden = true
        $0.clickCallBack = { [weak self] in
            guard let self = self else { return }

            let str0 = getCurrentLanguage() == .chinese ? "确定删除吗?\n\n" : "Are you sure to delete it?\n\n"
            let str1 = getCurrentLanguage() == .chinese ? "删除后，该家庭/公司下的全部设备自动解除绑定" : "After deletion, all devices under the family/company are automatically unbound"
            var attributedString = NSMutableAttributedString(
                string: str0,
                attributes: [
                    NSAttributedString.Key.font : UIFont.font(size: ZTScaleValue(14), type: .bold),
                    NSAttributedString.Key.foregroundColor : UIColor.custom(.black_3f4663)
                ]
            )
            
            let attributedString2 = NSMutableAttributedString(
                string: str1,
                attributes: [
                    NSAttributedString.Key.font : UIFont.font(size: ZTScaleValue(12), type: .bold),
                    NSAttributedString.Key.foregroundColor : UIColor.custom(.black_3f4663)
                ]
            )
            
            attributedString.append(attributedString2)

            self.tipsChooseAlert = TipsChooseAlertView.show(attributedString: attributedString, chooseString: "同时删除智汀家庭云盘存储的文件", sureCallback: { [weak self] tap in
                guard let self = self else { return }

                self.deleteArea()
            }, removeWithSure: false)
        }
    }
    
    private lazy var quitButton = ImageTitleButton(frame: .zero, icon: nil, title: "退出".localizedString, titleColor: UIColor.custom(.black_333333), backgroundColor: UIColor.custom(.white_ffffff)).then {
        $0.isHidden = true
        $0.clickCallBack = { [weak self] in
            guard let self = self else { return }

            let str0 = getCurrentLanguage() == .chinese ? "确定退出吗?\n\n" : "Are you sure to delete it?\n\n"
            let str1 = getCurrentLanguage() == .chinese ? "退出后，不能查看并控制该家庭的房间设备" : "After quit, all areas and devices under the family/company will be invisable"
            var attributedString = NSMutableAttributedString(
                string: str0,
                attributes: [
                    NSAttributedString.Key.font : UIFont.font(size: ZTScaleValue(14), type: .bold),
                    NSAttributedString.Key.foregroundColor : UIColor.custom(.black_3f4663)
                ]
            )
            
            let attributedString2 = NSMutableAttributedString(
                string: str1,
                attributes: [
                    NSAttributedString.Key.font : UIFont.font(size: ZTScaleValue(12), type: .bold),
                    NSAttributedString.Key.foregroundColor : UIColor.custom(.black_3f4663)
                ]
            )
            
            attributedString.append(attributedString2)

            self.tipsAlert = TipsAlertView.show(attributedString: attributedString, sureCallback: { [weak self] in
                guard let self = self else { return }

                self.quitArea()
            }, removeWithSure: false)
        }
    }
    
    private var setNameAlertView: InputAlertView?
    
    private lazy var generateQRCodeAlert = GenerateQRCodeAlert(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    
    private lazy var noAuthTipsView = NoAuthTipsView()
    
    private lazy var loadingView = LodingView().then {
        $0.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight - Screen.k_nav_height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "家庭/公司".localizedString
        getAreaDetail()
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(deleteButton)
        view.addSubview(quitButton)
        
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(getAreaDetail))
        
        generateQRCodeAlert.callback = { [weak self] roles in
            guard let self = self else { return }
            let ids = roles.map(\.id)
            self.getInviteQRCode(role_ids: ids)
        }
    }
    
    override func setupConstraints() {
        deleteButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(-ZTScaleValue(15))
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(10) - Screen.bottomSafeAreaHeight)
        }
        
        quitButton.snp.makeConstraints {
            $0.edges.equalTo(deleteButton)
        }
        
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(deleteButton.snp.top).offset(ZTScaleValue(-10))
        }
    }

    private func showLoadingView(){
        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        loadingView.show()
    }
    
    private func hideLoadingView(){
        loadingView.hide()
        loadingView.removeFromSuperview()
    }
}

extension AreaDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if rolePermission.get_area_invite_code && area.is_bind_sa {
                return 3
            } else {
                return 2
            }
        } else {
            return members.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 && members.count > 0  {
            return section1Header
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && members.count > 0  {
            return 45
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return nameCell
            } else if indexPath.row == 1 {
                if rolePermission.get_area_invite_code && area.is_bind_sa {
                    return qrCodeCell
                } else {
                    return areasNumCell
                }
                
            } else {
                return areasNumCell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AreaMemberCell.reusableIdentifier, for: indexPath) as! AreaMemberCell
            cell.member = members[indexPath.row]
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let setNameAlertView = InputAlertView(labelText: "家庭/公司名称".localizedString, placeHolder: "请输入家庭/公司名称".localizedString) { [weak self] text in
                    guard let self = self else { return }
                    self.changeAreaName(name: text)
                }
                setNameAlertView.textField.text = nameCell.valueLabel.text
                
                self.setNameAlertView = setNameAlertView
                
                SceneDelegate.shared.window?.addSubview(setNameAlertView)
            } else if indexPath.row == 1 {
                
                if rolePermission.get_area_invite_code && area.is_bind_sa {
                    SceneDelegate.shared.window?.addSubview(generateQRCodeAlert)
                } else {
                    let vc = LocationsManagementViewController()
                    vc.area = area
                    
                    
                    navigationController?.pushViewController(vc, animated: true)
                }

                
            } else {
                let vc = LocationsManagementViewController()
                vc.area = area
                
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = MemberInfoViewController()
            vc.area = area
            
            vc.member_id = members[indexPath.row].user_id
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}

extension AreaDetailViewController {
    @objc private func getAreaDetail() {
        let sa_token = area.sa_user_token
        if area.is_bind_sa {
            getRolePermission()
            getMembers()
            getRolesList()
        } else {
            checkAuthState()
        }
        



        /// 本地创建的未绑定SA家庭拿缓存
        if !area.is_bind_sa && !authManager.isLogin {
            let result = AreaCache.areaDetail(id: area.id, sa_token: sa_token)
            tableView.mj_header?.endRefreshing()
            areasNumCell.valueLabel.text = "\(result.locations_count)"
            nameCell.valueLabel.text = result.name == "" ? " " : result.name
            return
        }

        showLoadingView()
        
        ApiServiceManager.shared.areaDetail(area: area) { [weak self] (response) in
            self?.hideLoadingView()
            self?.tableView.mj_header?.endRefreshing()
            self?.areasNumCell.valueLabel.text = "\(response.location_count)"
            self?.nameCell.valueLabel.text = response.name == "" ? " " : response.name
            self?.tableView.reloadData()
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.hideLoadingView()
            self.tableView.mj_header?.endRefreshing()
            if code == 5012 { //token失效(用户被删除)
                if self.authManager.isLogin {
                    WarningAlert.show(message: "你已被管理员移出家庭".localizedString + "\"\(self.area.name)\"")
                    if self.authManager.isLogin { // 请求sc触发一下清除被移除的家庭逻辑
                        ApiServiceManager.shared.areaLocationsList(area: self.area, successCallback: nil, failureCallback: nil)
                        AreaCache.removeArea(area: self.area)
                        if self.authManager.currentArea.sa_user_token == self.area.sa_user_token {
                            if let currentArea = AreaCache.areaList().first {
                                self.authManager.currentArea = currentArea
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                /// 如果被移除后已没有家庭则自动创建一个
                                let area = AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)").transferToArea()
                                self.authManager.currentArea = area
                                
                                if self.authManager.isLogin { /// 若已登录同步到云端
                                    ApiServiceManager.shared.createArea(name: area.name, locations_name: []) { [weak self] response in
                                        guard let self = self else { return }
                                        area.id = response.id
                                        AreaCache.cacheArea(areaCache: area.toAreaCache())
                                        self.authManager.currentArea = area
                                        self.navigationController?.popViewController(animated: true)
                                    } failureCallback: { [weak self] code, err in
                                        self?.navigationController?.popViewController(animated: true)
                                    }

                                }
                            }
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                        
                    }
                    
                }
                
                return
            }
        }

    }
    
    private func changeAreaName(name: String) {
        let id = area.id
        let sa_token = area.sa_user_token
        
        /// cache
        if !area.is_bind_sa && !authManager.isLogin {
            AreaCache.changeAreaName(id: id, name: name, sa_token: sa_token)
            setNameAlertView?.removeFromSuperview()
            nameCell.valueLabel.text = name
            AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
            return
        }

        ApiServiceManager.shared.changeAreaName(area: area, name: name) { [weak self] (response) in
            guard let self = self else { return }
            AreaCache.changeAreaName(id: id, name: name, sa_token: sa_token)
            self.setNameAlertView?.removeFromSuperview()
            self.nameCell.valueLabel.text = name
            AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }

    }
    
    private func deleteArea() {
        let id = area.id
        let sa_token = area.sa_user_token
        
        /// cache
        if !area.is_bind_sa && !authManager.isLogin && area.id == 0 {
            AreaCache.deleteArea(id: id, sa_token: sa_token)
            
            if AreaCache.areaList().count == 0 {
                self.authManager.currentArea = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)").transferToArea()
            }
            
            showToast(string: "删除成功".localizedString)
            tipsChooseAlert?.removeFromSuperview()
            AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
            navigationController?.popViewController(animated: true)
            return
        }


        tipsChooseAlert?.isSureBtnLoading = true
        
        ApiServiceManager.shared.deleteArea(area: area) { [weak self] (response) in
            guard let self = self else { return }
            self.tipsChooseAlert?.removeFromSuperview()
            self.tipsAlert?.removeFromSuperview()
            AreaCache.deleteArea(id: id, sa_token: sa_token)
            
            if AreaCache.areaList().count == 0 {
                self.authManager.currentArea = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)").transferToArea()
                if self.authManager.isLogin {
                    self.authManager.syncLocalAreasToCloud(finish: nil)
                }
            }
            
            if self.authManager.currentArea.id == id && self.authManager.currentArea.sa_user_token == sa_token {
                if let area = AreaCache.areaList().first {
                    self.authManager.currentArea = area
                }
                
            }


            self.showToast(string: "删除成功".localizedString)
            AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
            self.navigationController?.popViewController(animated: true)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.tipsChooseAlert?.isSureBtnLoading = false
        }

    }
    
    private func quitArea() {
        let id = area.id
        let sa_token = area.sa_user_token
        
        
        tipsAlert?.isSureBtnLoading = true
        
        ApiServiceManager.shared.quitArea(area: area) { [weak self] _ in
            guard let self = self else { return }
            self.tipsAlert?.removeFromSuperview()
            AreaCache.deleteArea(id: id, sa_token: sa_token)
            
            if AreaCache.areaList().count == 0 {
                self.authManager.currentArea = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)").transferToArea()
                if self.authManager.isLogin {
                    self.authManager.syncLocalAreasToCloud(finish: nil)
                }
                
            }
            
            if self.authManager.currentArea.id == id && self.authManager.currentArea.sa_user_token == sa_token {
                if let area = AreaCache.areaList().first {
                    self.authManager.currentArea = area
                }
                
            }
            
            self.showToast(string: "退出成功".localizedString)
            AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
            self.navigationController?.popViewController(animated: true)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.tipsAlert?.isSureBtnLoading = false
        }

    }

    
    private func getInviteQRCode(role_ids: [Int]) {
        let areaName = area.name
       
        generateQRCodeAlert.generateButton.selectedChangeView(isLoading: true)
//        ApiServiceManager.shared
        ApiServiceManager.shared.getInviteQRCode(area: area, role_ids: role_ids) { [weak self] (response) in
            guard let self = self else { return }
            self.generateQRCodeAlert.generateButton.selectedChangeView(isLoading: false)
            self.generateQRCodeAlert.removeFromSuperview()
            QRCodePresentAlert.show(qrcodeString: response.qr_code, nickname: self.authManager.currentUser.nickname, areaName: areaName, area_id: self.area.id)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.generateQRCodeAlert.generateButton.selectedChangeView(isLoading: false)
        }
        
    }
    
    private func getMembers() {
        showLoadingView()
        ApiServiceManager.shared.memberList(area: area) { [weak self] response in
            guard let self = self else { return }
            self.hideLoadingView()
            self.section1Header.titleLabel.text = "成员 ".localizedString + " (\(response.users.count))"
            self.members = response.users
            if !response.is_creator {
                self.quitButton.isHidden = false
            } else {
                self.quitButton.isHidden = true
                self.deleteButton.isHidden = false
            }
            self.tableView.reloadData()
            
        } failureCallback: {[weak self] code, err in
            guard let self = self else { return }
            self.hideLoadingView()
        }

    }
    
    private func getRolesList() {
        ApiServiceManager.shared.rolesList(area: area) { [weak self] response in
            guard let self = self else { return }
            self.generateQRCodeAlert.setupRoles(roles: response.roles)
        } failureCallback: { code, err in
            
        }

    }
    


}

extension AreaDetailViewController {
    private func checkAuthState() {
        if area.is_bind_sa && (area.macAddr != nil && area.macAddr != networkStateManager.currentWifiMAC) && !authManager.isLogin {
            view.addSubview(noAuthTipsView)
            noAuthTipsView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(15)
                $0.left.equalToSuperview().offset(15)
                $0.right.equalToSuperview().offset(-15)
                $0.height.equalTo(40)
            }
            
            tableView.snp.remakeConstraints {
                $0.top.equalTo(noAuthTipsView.snp.bottom).offset(15)
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(deleteButton.snp.top).offset(-10)
            }
            tableView.isUserInteractionEnabled = false
            tableView.alpha = 0.5
            return
        }
        
        if !area.is_bind_sa {
            deleteButton.isHidden = false
            return
        }

        
        
        if rolePermission.update_area_name {
            nameCell.isUserInteractionEnabled = true
            nameCell.contentView.alpha = 1
            
        } else {
            nameCell.contentView.alpha = 0.5
            nameCell.isUserInteractionEnabled = false
            
        }
        
        
        tableView.reloadData()


    }
    
    private func getRolePermission() {
        ApiServiceManager.shared.rolesPermissions(area: area, user_id: area.sa_user_id) { [weak self] response in
            guard let self = self else { return }
            self.rolePermission = response.permissions
            self.checkAuthState()
            
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.rolePermission = RolePermission()
            self.checkAuthState()
        }

    }
}

