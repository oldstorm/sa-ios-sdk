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
    var member = User()
    
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
    
    private lazy var captchaCell = AreaDetailCaptchaCell().then {
        $0.title.text = "验证码".localizedString
    }

    /// infoCells
    var infoCellTypes: [InfoCellType] = [.name, .location]

    private lazy var section1Header = AreaMemberSectionHeader()
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.register(AreaMemberCell.self, forCellReuseIdentifier: AreaMemberCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = ZTScaleValue(50)
        if #available(iOS 15.0, *) {
            $0.sectionHeaderTopPadding = 0
        }
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
            
            if self.area.is_bind_sa {
                self.tipsChooseAlert = TipsChooseAlertView.show(attributedString: attributedString, chooseString: "同时删除智汀家庭云盘存储的文件", sureCallback: { [weak self] tap in
                    guard let self = self else { return }

                    self.deleteArea(isDeleteDisk: tap == 1)
                }, removeWithSure: false)
            } else {
                self.tipsAlert = TipsAlertView.show(attributedString: attributedString, sureCallback: { [weak self] in
                    guard let self = self else { return }

                    self.deleteArea(isDeleteDisk: false)
                }, removeWithSure: false)
            }
            

            
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
    
    private lazy var noTokenTipsView = NoTokenTipsView().then {
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noTokenTapAction)))
        $0.isUserInteractionEnabled = true
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
        
        //生成验证码信息
        captchaCell.clickCallback = {[weak self] in
            guard let self = self else {
                return
            }
            self.captchaCell.valueBtn.selectedChangeView(isLoading: true)
            ApiServiceManager.shared.getCaptcha(area: self.area) {[weak self] captcha in
                guard let self = self else {
                    return
                }
                self.captchaCell.valueBtn.selectedChangeView(isLoading: false)
                AreaCaptchaAlert.show(captcha: captcha.code)
            } failureCallback: {[weak self] code, error in
                guard let self = self else {
                    return
                }
                self.showToast(string: error)
            }


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
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.bottom.equalTo(deleteButton.snp.top).offset(ZTScaleValue(-10))
        }
    }

    
    @objc private func noTokenTapAction() {
        let vc = GuideTokenViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension AreaDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return infoCellTypes.count
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
//            if indexPath.row == 0 {
//                return nameCell
//            } else if indexPath.row == 1 {
//                if rolePermission.get_area_invite_code && area.id != nil {
//                    return qrCodeCell
//                } else {
//                    return areasNumCell
//                }
//
//            } else {
//                return areasNumCell
//            }
            
            switch infoCellTypes[indexPath.row] {
            case .name:
                return nameCell
            case .codeQR:
                return qrCodeCell
            case .location:
                return areasNumCell
            case .captcha:
                return captchaCell
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
            
            switch infoCellTypes[indexPath.row] {
            case .name:
                let setNameAlertView = InputAlertView(labelText: "家庭/公司名称".localizedString, placeHolder: "请输入家庭/公司名称".localizedString) { [weak self] text in
                    guard let self = self else { return }
                    self.changeAreaName(name: text)
                }
                setNameAlertView.textField.text = nameCell.valueLabel.text
                
                self.setNameAlertView = setNameAlertView
                
                SceneDelegate.shared.window?.addSubview(setNameAlertView)
                
            case .codeQR:
                SceneDelegate.shared.window?.addSubview(generateQRCodeAlert)
            case .location:
                let vc = LocationsManagementViewController()
                vc.area = area
                navigationController?.pushViewController(vc, animated: true)
                
            case .captcha:
                break
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
        if area.id != nil {
            getRolePermission()
            getMembers()
            getRolesList()
        } else {
            checkAuthState()
        }
        



        /// 本地创建的未绑定SA家庭拿缓存
        if area.id == nil && !authManager.isLogin {
            let result = AreaCache.areaDetail(id: area.id, sa_token: sa_token)
            tableView.mj_header?.endRefreshing()
            areasNumCell.valueLabel.text = "\(result.locations_count)"
            nameCell.valueLabel.text = result.name == "" ? " " : result.name
            return
        }

        showLoadingView()
        
        ApiServiceManager.shared.areaDetail(area: area) { [weak self] (response) in
            guard let self = self else { return }

            self.hideLoadingView()
            self.tableView.mj_header?.endRefreshing()
            self.areasNumCell.valueLabel.text = "\(response.location_count)"
            self.nameCell.valueLabel.text = response.name == "" ? " " : response.name
            
            self.noTokenTipsView.removeFromSuperview()
            self.tableView.snp.remakeConstraints {
                $0.top.equalTo(Screen.k_nav_height).offset(15)
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(self.deleteButton.snp.top).offset(-10)
            }
            self.tableView.isUserInteractionEnabled = true
            self.tableView.alpha = 1

            self.tableView.reloadData()
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.hideLoadingView()
            self.tableView.mj_header?.endRefreshing()
            if code == 5012 { //token失效(用户被删除)
                ApiServiceManager.shared.getSAToken(area: self.area) { [weak self] response in
                    guard let self = self else { return }
                    self.area.sa_user_token = response.sa_token
                    AreaCache.cacheArea(areaCache: self.area.toAreaCache())
                    //找回凭证，页面刷新
                    self.getAreaDetail()
                } failureCallback: { [weak self] code, error in
                    guard let self = self else { return }

                    if code == 2011 || code == 2010 {
                        //凭证获取失败，状态码2011，无权限
                        self.view.addSubview(self.noTokenTipsView)
                        self.noTokenTipsView.snp.makeConstraints {
                            $0.top.equalToSuperview().offset(15 + Screen.k_nav_height)
                            $0.left.equalToSuperview().offset(15)
                            $0.right.equalToSuperview().offset(-15)
                            $0.height.equalTo(40)
                        }
                        
                        self.tableView.snp.remakeConstraints {
                            $0.top.equalTo(self.noTokenTipsView.snp.bottom).offset(15)
                            $0.left.right.equalToSuperview()
                            $0.bottom.equalTo(self.deleteButton.snp.top).offset(-10)
                        }
                        self.tableView.isUserInteractionEnabled = false
                        self.tableView.alpha = 0.5
                        
                    }else if code == 3002 {
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
                    } else if code == 2008 || code == 2009 { /// 在SA环境下且未登录, 用户被移除家庭
                        #warning("TODO: 暂未有这种情况的说明")
                        self.showToast(string: "家庭可能被移除或token失效,请先登录")
                    }
                }
                
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
            
            return
        }
        setNameAlertView?.isSureBtnLoading = true
        ApiServiceManager.shared.changeAreaName(area: area, name: name) { [weak self] (response) in
            guard let self = self else { return }
            AreaCache.changeAreaName(id: id, name: name, sa_token: sa_token)
            self.setNameAlertView?.removeFromSuperview()
            self.nameCell.valueLabel.text = name
            self.setNameAlertView?.isSureBtnLoading = false
            
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.setNameAlertView?.isSureBtnLoading = false
        }

    }
    
    private func deleteArea(isDeleteDisk: Bool) {
        let id = area.id
        let sa_token = area.sa_user_token
        
        /// cache
        if !area.is_bind_sa && area.id == nil {
            AreaCache.deleteArea(id: id, sa_token: sa_token)
            var isPopToRoot = false
            
            if AreaCache.areaList().count == 0 {
                self.authManager.currentArea = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)").transferToArea()
                isPopToRoot = true
            }
            
            showToast(string: "删除成功".localizedString)
            tipsChooseAlert?.removeFromSuperview()
            tipsAlert?.removeFromSuperview()
            
            if isPopToRoot {
                self.navigationController?.tabBarController?.selectedIndex = 0
                self.navigationController?.popToRootViewController(animated: true)
                
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }


        tipsChooseAlert?.isSureBtnLoading = true
        tipsAlert?.isSureBtnLoading = true
        
        ApiServiceManager.shared.deleteArea(area: area, isDeleteDisk: isDeleteDisk) { [weak self] (response) in
            guard let self = self else { return }
            self.tipsChooseAlert?.removeFromSuperview()
            self.tipsAlert?.removeFromSuperview()
            AreaCache.deleteArea(id: id, sa_token: sa_token)
            var isPopToRoot = false
            
            if AreaCache.areaList().count == 0 {
                self.authManager.currentArea = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)").transferToArea()
                if self.authManager.isLogin {
                    self.authManager.syncLocalAreasToCloud(finish: nil)
                }
                isPopToRoot = true
            }
            
            if self.authManager.currentArea.id == id && self.authManager.currentArea.sa_user_token == sa_token {
                if let area = AreaCache.areaList().first {
                    self.authManager.currentArea = area
                }
                
            }


            self.showToast(string: "删除成功".localizedString)
            
            if isPopToRoot {
                self.navigationController?.tabBarController?.selectedIndex = 0
                self.navigationController?.popToRootViewController(animated: true)
                
            } else {
                self.navigationController?.popViewController(animated: true)
            }

        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.tipsChooseAlert?.isSureBtnLoading = false
            self?.tipsAlert?.isSureBtnLoading = false
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
            var isPopToRoot = false

            if AreaCache.areaList().count == 0 {
                self.authManager.currentArea = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)").transferToArea()
                if self.authManager.isLogin {
                    self.authManager.syncLocalAreasToCloud(finish: nil)
                }
                isPopToRoot = true
            }
            
            if self.authManager.currentArea.id == id && self.authManager.currentArea.sa_user_token == sa_token {
                if let area = AreaCache.areaList().first {
                    self.authManager.currentArea = area
                }
                
            }
            
            self.showToast(string: "退出成功".localizedString)
            
            if isPopToRoot {
                self.navigationController?.tabBarController?.selectedIndex = 0
                self.navigationController?.popToRootViewController(animated: true)
                
            } else {
                self.navigationController?.popViewController(animated: true)
            }

            
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.tipsAlert?.isSureBtnLoading = false
        }

    }

    
    private func getInviteQRCode(role_ids: [Int]) {
        let areaName = area.name
       
        generateQRCodeAlert.generateButton.selectedChangeView(isLoading: true)

        ApiServiceManager.shared.getInviteQRCode(area: area, role_ids: role_ids) { [weak self] (response) in
            guard let self = self else { return }
            self.generateQRCodeAlert.generateButton.selectedChangeView(isLoading: false)
            self.generateQRCodeAlert.removeFromSuperview()
            QRCodePresentAlert.show(qrcodeString: response.qr_code, nickname: self.authManager.currentUser.nickname, areaName: areaName)
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
            if !response.is_owner {
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
        if area.is_bind_sa && (area.bssid != nil && area.bssid != networkStateManager.currentWifiBSSID) && !authManager.isLogin {
            view.addSubview(noAuthTipsView)
            noAuthTipsView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(15 + Screen.k_nav_height)
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
        
        if !area.is_bind_sa && area.id == nil {
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
        
        if rolePermission.get_area_invite_code && area.id != nil {//本地家庭无邀请权限，则不展示二维码选项

            if self.member.is_owner && self.member.is_self {//当前用户是拥有者,显示生成验证码操作
                infoCellTypes = [.name, .codeQR,.location, .captcha]
            }else{
                infoCellTypes = [.name, .codeQR, .location]
            }
        }else{
            infoCellTypes = [.name, .location]
        }
        
        
        tableView.reloadData()


    }
    
    private func getRolePermission() {
        ApiServiceManager.shared.rolesPermissions(area: area, user_id: area.sa_user_id) { [weak self] response in
            guard let self = self else { return }
            self.rolePermission = response.permissions
            
            //获取用户是否拥有者权限
            ApiServiceManager.shared.userDetail(area: self.area, id: self.area.sa_user_id) { [weak self] (memberInfo) in
                    guard let self = self else { return }
                    self.tableView.mj_header?.endRefreshing()
                    self.member = memberInfo
                    self.checkAuthState()
                } failureCallback: {(code, err) in
                    
                }


            
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.rolePermission = RolePermission()
            self.checkAuthState()
        }

    }
}


extension AreaDetailViewController {
    enum InfoCellType {
        case name
        case codeQR
        case location
        case captcha
    }
}
