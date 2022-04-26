//
//  FamilyDetailViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/15.
//
import RealmSwift
import UIKit

class FamilyDetailViewController: BaseViewController {
    lazy var requestQueue = DispatchQueue(label: "ZhiTing.FamilyDetailViewController.requestQueue")

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
        $0.title.text = "房间".localizedString
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
    
    private lazy var deleteButton = ImageTitleButton(frame: .zero, icon: nil, title: "删除家庭".localizedString, titleColor: UIColor.custom(.black_333333), backgroundColor: UIColor.custom(.white_ffffff)).then {
        $0.isHidden = true
        $0.clickCallBack = { [weak self] in
            guard let self = self else { return }

            let str0 = getCurrentLanguage() == .chinese ? "确定删除吗?\n\n" : "Are you sure to delete it?\n\n"
            let str1 = getCurrentLanguage() == .chinese ? "删除后，该家庭下的全部设备自动解除绑定" : "After deletion, all devices under the family are automatically unbound"
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
                //判断是否有云盘
                ApiServiceManager.shared.getSAExtensions(area: AuthManager.shared.currentArea, successCallback: { [weak self] response in
                    guard let self = self else { return }
                    if response.extension_names.contains("wangpan") {
                        self.tipsChooseAlert = TipsChooseAlertView.show(attributedString: attributedString, chooseString: "同时删除智汀云盘存储的文件", sureCallback: { [weak self] tap in
                            guard let self = self else { return }

                            self.deleteArea(isDeleteDisk: tap == 1)
                        }, removeWithSure: false)
                    }else{
                        self.tipsAlert = TipsAlertView.show(attributedString: attributedString, sureCallback: { [weak self] in
                            guard let self = self else { return }
                            self.deleteArea(isDeleteDisk: false)
                        }, removeWithSure: false)
                    }
                 
                }, failureCallback: nil)

            } else {

                self.tipsAlert = TipsAlertView.show(attributedString: attributedString, sureCallback: { [weak self] in
                    guard let self = self else { return }
                    self.deleteArea(isDeleteDisk: false)
                }, removeWithSure: false)
            }
            

            
        }
    }
    
    private lazy var quitButton = ImageTitleButton(frame: .zero, icon: nil, title: "退出家庭".localizedString, titleColor: UIColor.custom(.black_333333), backgroundColor: UIColor.custom(.white_ffffff)).then {
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
    
    private lazy var deleteOrQuitButton = ImageTitleButton(frame: .zero, icon: nil, title: "删除/退出家庭".localizedString, titleColor: UIColor.custom(.black_333333), backgroundColor: UIColor.custom(.white_ffffff)).then {
        $0.isHidden = true
        $0.clickCallBack = { [weak self] in
            guard let self = self else { return }
            if UserManager.shared.isLogin {
                WarningAlert.show(message: "当前终端无凭证或已过期,请在局域网使用电脑访问专业版进行操作".localizedString, sureTitle: "确定".localizedString)
            } else {
                TipsAlertView.show(message: "当前终端无凭证或已过期,请登录后再进行操作".localizedString, sureTitle: "去登录".localizedString, sureCallback: { // 登录弹窗
                    AuthManager.checkLoginWhenComplete(loginComplete: { [weak self] in
                        guard let self = self else { return }
                        self.requestNetwork()
                    }, jumpAfterLogin: true)
                })
            }
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
        requestNetwork()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "家庭".localizedString
        
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(deleteOrQuitButton)
        view.addSubview(deleteButton)
        view.addSubview(quitButton)
        
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
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
        
        deleteOrQuitButton.snp.makeConstraints {
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

// MARK: - TableViewDelegate & TableViewDataSource
extension FamilyDetailViewController: UITableViewDelegate, UITableViewDataSource {
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
                let setNameAlertView = InputAlertView(labelText: "家庭名称".localizedString, placeHolder: "请输入家庭名称".localizedString) { [weak self] text in
                    guard let self = self else { return }
                    self.changeAreaName(name: text)
                }
                setNameAlertView.textField.text = nameCell.valueLabel.text
                
                self.setNameAlertView = setNameAlertView
                
                SceneDelegate.shared.window?.addSubview(setNameAlertView)
                
            case .codeQR:
                SceneDelegate.shared.window?.addSubview(generateQRCodeAlert)
            case .location:
                let vc = RoomsManagementViewController()
                vc.area = area
                navigationController?.pushViewController(vc, animated: true)
                
            case .captcha:
                break
            }
            
        } else {
            let vc = FamilyMemberInfoViewController()
            vc.area = area
            vc.header.nickNameLabel.text = members[indexPath.row].nickname
            vc.member_id = members[indexPath.row].user_id
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}

// MARK: - NetworkRequests
extension FamilyDetailViewController {
    @objc private func requestNetwork() {
        /// 本地创建的未绑定SA家庭拿缓存
        if area.id == nil && !UserManager.shared.isLogin {
            let result = AreaCache.areaDetail(id: area.id, sa_token: area.sa_user_token)
            tableView.mj_header?.endRefreshing()
            areasNumCell.valueLabel.text = "\(result.locations_count)"
            nameCell.valueLabel.text = result.name == "" ? " " : result.name
            checkAuthState()
            return
        }
        
        requestQueue.async { [weak self] in
            guard let self = self else { return }
            let sema = DispatchSemaphore(value: 0)
            
            sema.signal()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.mj_header?.endRefreshing()
                self.showLoadingView()
            }
            
           
            
            sema.wait()
            /// 获取家庭详情
            ApiServiceManager.shared.areaDetail(area: self.area) { [weak self] (response) in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
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
                    sema.signal()
                }
                
                
                
            } failureCallback: { [weak self] (code, err) in
                guard let self = self else { return }
                if code == 5012 || code == 5027 { //token失效
                    ApiServiceManager.shared.getSAToken(area: self.area) { [weak self] response in
                        guard let self = self else { return }
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.area.sa_user_token = response.sa_token
                            self.area.isAllowedGetToken = true
                            AreaCache.cacheArea(areaCache: self.area.toAreaCache())
                            sema.signal()
                            //找回凭证，页面刷新
                            self.requestNetwork()
                        }
                       
                    } failureCallback: { [weak self] code, err in
                        guard let self = self else { return }
                        if code == 2011 || code == 2010 { //凭证获取失败，状态码2011，无权限
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.area.isAllowedGetToken = false
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
                                sema.signal()
                            }
                            
                        } else {
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.showToast(string: err)
                                sema.signal()
                            }
                        }
                    }

                }  else if code == 5003 || code == 3002 { /// 用户已被移除家庭
                    if self.area.needRebindCloud { // 未成功绑定到云端的家庭暂不移除
                        return
                    }

                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        /// 提示被管理员移除家庭
                        WarningAlert.show(message: "你已被管理员移出家庭".localizedString + "\"\(self.area.name)\"")
                        AreaCache.removeArea(area: self.area)
                        if self.authManager.currentArea.id == self.area.id {
                            if let currentArea = AreaCache.areaList().first {
                                self.authManager.currentArea = currentArea
                                sema.signal()
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                /// 如果被移除后已没有家庭则自动创建一个
                                let area = AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family).transferToArea()
                                self.authManager.currentArea = area
                                
                                if UserManager.shared.isLogin { /// 若已登录同步到云端
                                    ApiServiceManager.shared.createArea(name: area.name, location_names: [], department_names: [], area_type: .family) { [weak self] response in
                                        guard let self = self else { return }
                                        DispatchQueue.main.async { [weak self] in
                                            guard let self = self else { return }
                                            area.id = response.id
                                            AreaCache.cacheArea(areaCache: area.toAreaCache())
                                            self.authManager.currentArea = area
                                            sema.signal()
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                      
                                        
                                        
                                    } failureCallback: { [weak self] code, err in
                                        DispatchQueue.main.async { [weak self] in
                                            sema.signal()
                                            self?.navigationController?.popViewController(animated: true)
                                        }
                                        
                                        
                                    }
                                } else {
                                    sema.signal()
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        } else if code == 100001 { // 云端家庭已迁移
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                /// 重新获取临时通道
                                /// 置空本地存储的临时通道地址
                                let key = AuthManager.shared.currentArea.sa_user_token
                                UserDefaults.standard.setValue("", forKey: key)
                                /// 再次请求. 页面刷新
                                sema.signal()
                                self.requestNetwork()
                                
                            }
                        } else {
                            sema.signal()
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.showToast(string: err)
                        sema.signal()
                    }
                   
                }
                
            }
            
            sema.wait()
            /// 获取用户权限
            ApiServiceManager.shared.rolesPermissions(area: self.area, user_id: self.area.sa_user_id) { [weak self] response in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.rolePermission = response.permissions
                    sema.signal()
                }
                
                
            } failureCallback: { [weak self] code, err in
                guard let self = self else { return }
                self.rolePermission = RolePermission()
                sema.signal()
            }
            
            sema.wait()
            //获取用户是否拥有者权限
            ApiServiceManager.shared.userDetail(area: self.area, id: self.area.sa_user_id) { [weak self] (memberInfo) in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.member = memberInfo
                    sema.signal()
                
                }
                
            } failureCallback: { code, err in
                sema.signal()
            }
            
            sema.wait()
            /// 获取成员列表
            ApiServiceManager.shared.memberList(area: self.area) { [weak self] response in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.section1Header.titleLabel.text = "成员 ".localizedString + " (\(response.users.count))"
                    self.members = response.users
                    if !response.is_owner {
                        self.quitButton.isHidden = false
                    } else {
                        self.quitButton.isHidden = true
                        self.deleteButton.isHidden = false
                    }
                    sema.signal()
                }
                
                
            } failureCallback: { code, err in
                sema.signal()
            }
            
            sema.wait()
            /// 获取角色列表
            ApiServiceManager.shared.rolesList(area: self.area) { [weak self] response in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.generateQRCodeAlert.setupRoles(roles: response.roles)
                    sema.signal()
                }
                
                
            } failureCallback: { code, err in
                sema.signal()
            }
            
            sema.wait()
            /// 根据权限更新视图
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.checkAuthState()
                self.hideLoadingView()
            }
            
        }
        
        
        
        
    }
}

extension FamilyDetailViewController {
    
    
    private func changeAreaName(name: String) {
        let id = area.id
        let sa_token = area.sa_user_token
        
        /// cache
        if !area.is_bind_sa && !UserManager.shared.isLogin {
            AreaCache.changeAreaName(id: id, name: name, sa_token: sa_token)
            setNameAlertView?.removeFromSuperview()
            nameCell.valueLabel.text = name
            showToast(string: "修改成功".localizedString)
            return
        }
        setNameAlertView?.isSureBtnLoading = true
        ApiServiceManager.shared.changeAreaName(area: area, name: name) { [weak self] (response) in
            guard let self = self else { return }
            AreaCache.changeAreaName(id: id, name: name, sa_token: sa_token)
            self.setNameAlertView?.removeFromSuperview()
            self.nameCell.valueLabel.text = name
            self.showToast(string: "修改成功".localizedString)
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
                self.authManager.currentArea = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family).transferToArea()
                isPopToRoot = true
            }
            
            showToast(string: "删除成功".localizedString)
            tipsChooseAlert?.removeFromSuperview()
            tipsAlert?.removeFromSuperview()
            
            if isPopToRoot {
//                self.navigationController?.tabBarController?.selectedIndex = 0
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
            
            if response.remove_status == 3 { /// 移除成功
                AreaCache.deleteArea(id: id, sa_token: sa_token)
                if AreaCache.areaList().count == 0 {
                    self.authManager.currentArea = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family).transferToArea()
                    if UserManager.shared.isLogin {
                        self.authManager.syncLocalAreasToCloud(needUpdateCurrentArea: true) { [weak self] in
                            guard let self = self else { return }
                            self.navigationController?.popToRootViewController(animated: true)
                            self.showToast(string: "删除成功".localizedString)
                        }
                    }
                    
                } else if self.authManager.currentArea.id == id && self.authManager.currentArea.sa_user_token == sa_token {
                    if let area = AreaCache.areaList().first {
                        self.authManager.currentArea = area
                    }
                    self.showToast(string: "删除成功".localizedString)
                    self.navigationController?.popViewController(animated: true)
                    
                } else {
                    self.showToast(string: "删除成功".localizedString)
                    self.navigationController?.popViewController(animated: true)
                }
                
            } else if response.remove_status == 1 { /// 正在移除
                let areas = AreaCache.areaList().filter({ $0.id != self.area.id })
                
                if self.area.needRebindCloud || self.area.cloud_user_id == -1 { /// 未同步到云端的家庭直接移除缓存
                    AreaCache.deleteArea(id: id, sa_token: sa_token)
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

                

            } else { /// 移除失败
                self.showToast(string: "删除失败".localizedString)
                self.tipsChooseAlert?.isSureBtnLoading = false
                self.tipsAlert?.isSureBtnLoading = false
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
            

            if AreaCache.areaList().count == 0 {
                self.authManager.currentArea = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family).transferToArea()
                if UserManager.shared.isLogin {
                    self.authManager.syncLocalAreasToCloud(needUpdateCurrentArea: true) { [weak self] in
                        guard let self = self else { return }
//                        self.navigationController?.tabBarController?.selectedIndex = 0
                        self.navigationController?.popToRootViewController(animated: true)
                        self.showToast(string: "退出成功".localizedString)
                    }
                }
                
            } else if self.authManager.currentArea.id == id && self.authManager.currentArea.sa_user_token == sa_token {
                if let area = AreaCache.areaList().first {
                    self.authManager.currentArea = area
                }
                self.showToast(string: "退出成功".localizedString)
                self.navigationController?.popViewController(animated: true)
                
            } else {
                self.showToast(string: "退出成功".localizedString)
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

        ApiServiceManager.shared.getInviteQRCode(area: area, role_ids: role_ids, department_ids: []) { [weak self] (response) in
            guard let self = self else { return }
            self.generateQRCodeAlert.generateButton.selectedChangeView(isLoading: false)
            self.generateQRCodeAlert.removeFromSuperview()
            QRCodePresentAlert.show(qrcodeString: response.qr_code, area: self.area, nickname: UserManager.shared.currentUser.nickname, areaName: areaName)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.generateQRCodeAlert.removeFromSuperview()
            self?.generateQRCodeAlert.generateButton.selectedChangeView(isLoading: false)
        }
        
    }
    
    


}

extension FamilyDetailViewController {
    private func checkAuthState() {
        if area.is_bind_sa && (area.bssid != nil && area.bssid != networkStateManager.currentWifiBSSID) && !UserManager.shared.isLogin {
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
            } else {
                infoCellTypes = [.name, .codeQR, .location]
            }
        } else {
            
            if self.member.is_owner && self.member.is_self {
                infoCellTypes = [.name, .location, .captcha]
            } else {
                infoCellTypes = [.name, .location]
            }
        }
        
        deleteOrQuitButton.isHidden = area.isAllowedGetToken
        tableView.reloadData()


    }
}


extension FamilyDetailViewController {
    enum InfoCellType {
        case name
        case codeQR
        case location
        case captcha
    }
}
