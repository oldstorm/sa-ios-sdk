//
//  MineViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit
import RealmSwift

class MineViewController: BaseViewController {

    private lazy var header = MineHeaderView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: ZTScaleValue(100) + Screen.statusBarHeight))

    private lazy var loginSectionHeader = MineLoginSectionHeader()
    
    fileprivate lazy var cellTypes: [CellType] = [.area, .brands, .thirdParty, .proEdition, .explore, .aboutUs]
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.estimatedSectionHeaderHeight = 0
        $0.estimatedSectionFooterHeight = 0
        $0.separatorStyle = .none
        $0.tableHeaderView = header
        if #available(iOS 15.0, *) {
            $0.sectionHeaderTopPadding = 0
        }

        $0.register(MineViewCell.self, forCellReuseIdentifier: MineViewCell.reusableIdentifier)
        $0.alwaysBounceVertical = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        disableSideSliding = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.reloadData()
        updateCellType()
        requestNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(tableView)
        
        header.infoCallback = { [weak self] in
            let vc = MineInfoViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        header.scanBtn.clickCallBack = { [weak self] _ in
            let vc = ScanQRCodeViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        loginSectionHeader.button.clickCallBack = { [weak self] _ in
            AuthManager.checkLoginWhenComplete(loginComplete: { [weak self] in
                self?.tableView.reloadData()
                self?.requestNetwork()
            }, jumpAfterLogin: true)
        }

    }
    
    override func setupSubscriptions() {
        authManager.currentAreaPublisher
            .receive(on: DispatchQueue.main)
            .sink {  [weak self] area in
                guard let self = self else { return }
                self.updateCellType()
                
            }
            .store(in: &cancellables)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.statusBarHeight)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    func updateCellType() {
        var types = [CellType]()
        types.append(.area)
        types.append(.brands)
        types.append(.thirdParty)
        if authManager.currentArea.id != nil {
            types.append(.proEdition)
        }
        types.append(.explore)
        if UserManager.shared.isLogin {
            types.append(.feedback)
        }
        types.append(.aboutUs)
        cellTypes = types
        tableView.reloadData()
        
        if authManager.currentArea.id != nil && (UserManager.shared.isLogin || authManager.isSAEnviroment) {
            ApiServiceManager.shared.getSAExtensions(area: authManager.currentArea, successCallback: { [weak self] response in
                guard let self = self else { return }
                var types = [CellType]()
                types.append(.area)
                if response.extension_names.contains("crm") {
                    types.append(.crm)
                }
                if response.extension_names.contains("scm") {
                    types.append(.scm)
                }
                types.append(.brands)
                types.append(.thirdParty)
                if self.authManager.currentArea.id != nil {
                    types.append(.proEdition)
                }
                types.append(.explore)
                if UserManager.shared.isLogin {
                    types.append(.feedback)
                }
                types.append(.aboutUs)
                
                self.cellTypes = types
                self.tableView.reloadData()
             
            }, failureCallback: nil)
        }
    }
}

extension MineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if UserManager.shared.isLogin {
            let view = UIView()
            view.backgroundColor = .custom(.gray_f6f8fd)
            return view
        } else {
            return loginSectionHeader
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if UserManager.shared.isLogin {
            return 10
        } else {
            return ZTScaleValue(70)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MineViewCell.reusableIdentifier, for: indexPath) as! MineViewCell
        cell.setEnable(true)
        let cellType = cellTypes[indexPath.row]
        cell.title.text = cellType.title
        cell.icon.image = cellType.icon
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellType = cellTypes[indexPath.row]
        
        switch cellType {
        case .area:
            let vc = AreaListViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .brands:
            if authManager.currentArea.id != nil {
                if UserManager.shared.isLogin {
                    Task {
                        do {
                            showLoadingView()
                            try await retreiveSAToken()
                            hideLoadingView()
                            let vc = BrandMainViewController()
                            navigationController?.pushViewController(vc, animated: true)
                            
                        } catch {
                            hideLoadingView()
                            TipsAlertView.show(
                                message: "当前终端无凭证或已过期，可通过云端找回凭证。".localizedString,
                                sureTitle: "如何找回".localizedString,
                                sureCallback: { [weak self] in
                                    guard let self = self else { return }
                                    let vc = GuideTokenViewController()
                                    self.navigationController?.pushViewController(vc, animated: true)
                                },
                                cancelCallback: nil,
                                removeWithSure: true
                            )
                        }
                    }
                } else if authManager.isSAEnviroment {
                    Task {
                        do {
                            showLoadingView()
                            let _ = try await AsyncApiService.areaDetail(area: AuthManager.shared.currentArea)
                            hideLoadingView()
                            let vc = BrandMainViewController()
                            navigationController?.pushViewController(vc, animated: true)
                            
                        } catch {
                            hideLoadingView()
                            if let err = error as? AsyncApiError {
                                if err.code == 2011 || err.code == 2010 || err.code == 5012 {
                                    TipsAlertView.show(
                                        message: "当前终端无凭证或已过期，可通过云端找回凭证。".localizedString,
                                        sureTitle: "如何找回".localizedString,
                                        sureCallback: { [weak self] in
                                            guard let self = self else { return }
                                            let vc = GuideTokenViewController()
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        },
                                        cancelCallback: nil,
                                        removeWithSure: true
                                    )
                                } else {
                                    showToast(string: err.err)
                                }
                                
                            }
                            
                        }
                    }
                   

                } else {
                    showToast(string: "请在局域网内或登录后使用".localizedString)
                }
               
            } else { /// 无实体SA
                showToast(string: "请先添加智慧中心或登录".localizedString)
            }

           
        case .thirdParty:
            let vc = ThirdPartyListViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .proEdition:
            if UserManager.shared.isLogin {
                Task {
                    do {
                        showLoadingView()
                        try await retreiveSAToken()
                        hideLoadingView()
                        let vc = ProEditionViewController(linkEnum: .proEdition)
                        let nav = BaseProNavigationViewController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        present(nav, animated: true, completion: nil)
                    } catch {
                        hideLoadingView()
                        TipsAlertView.show(
                            message: "当前终端无凭证或已过期，可通过云端找回凭证。".localizedString,
                            sureTitle: "如何找回".localizedString,
                            sureCallback: { [weak self] in
                                guard let self = self else { return }
                                let vc = GuideTokenViewController()
                                self.navigationController?.pushViewController(vc, animated: true)
                            },
                            cancelCallback: nil,
                            removeWithSure: true
                        )
                    }
                }
            } else if authManager.isSAEnviroment {
                Task {
                    do {
                        showLoadingView()
                        let _ = try await AsyncApiService.areaDetail(area: AuthManager.shared.currentArea)
                        hideLoadingView()
                        let vc = ProEditionViewController(linkEnum: .proEdition)
                        let nav = BaseProNavigationViewController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        present(nav, animated: true, completion: nil)
                        
                    } catch {
                        hideLoadingView()
                        if let err = error as? AsyncApiError {
                            if err.code == 2011 || err.code == 2010 || err.code == 5012 {
                                TipsAlertView.show(
                                    message: "当前终端无凭证或已过期，可通过云端找回凭证。".localizedString,
                                    sureTitle: "如何找回".localizedString,
                                    sureCallback: { [weak self] in
                                        guard let self = self else { return }
                                        let vc = GuideTokenViewController()
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    },
                                    cancelCallback: nil,
                                    removeWithSure: true
                                )
                            } else {
                                showToast(string: err.err)
                            }
                            
                        }
                    }
                }
                
            }  else {
                showToast(string: "请在局域网内或登录后使用".localizedString)
            }
            
        case .explore:
            let vc = ExperienceViewController()
            navigationController?.pushViewController(vc, animated: true)
            
        case .aboutUs:
            let vc = AboutUsViewController()
//            let vc = DoorLockViewController()
            navigationController?.pushViewController(vc, animated: true)

        case .scm:
            if UserManager.shared.isLogin {
                Task {
                    do {
                        showLoadingView()
                        try await retreiveSAToken()
                        hideLoadingView()
                        let vc = CustomHeaderWebViewController(linkEnum: .scm(token: authManager.currentArea.sa_user_token))
                        let nav = BaseProNavigationViewController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        present(nav, animated: true, completion: nil)
                        
                    } catch {
                        hideLoadingView()
                        TipsAlertView.show(
                            message: "当前终端无凭证或已过期，可通过云端找回凭证。".localizedString,
                            sureTitle: "如何找回".localizedString,
                            sureCallback: { [weak self] in
                                guard let self = self else { return }
                                let vc = GuideTokenViewController()
                                self.navigationController?.pushViewController(vc, animated: true)
                            },
                            cancelCallback: nil,
                            removeWithSure: true
                        )
                    }
                }
            } else if authManager.isSAEnviroment {
                Task {
                    do {
                        showLoadingView()
                        let _ = try await AsyncApiService.areaDetail(area: AuthManager.shared.currentArea)
                        hideLoadingView()
                        let vc = CustomHeaderWebViewController(linkEnum: .scm(token: authManager.currentArea.sa_user_token))
                        let nav = BaseProNavigationViewController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        present(nav, animated: true, completion: nil)
                        
                    } catch {
                        hideLoadingView()
                        if let err = error as? AsyncApiError {
                            if err.code == 2011 || err.code == 2010 || err.code == 5012 {
                                TipsAlertView.show(
                                    message: "当前终端无凭证或已过期，可通过云端找回凭证。".localizedString,
                                    sureTitle: "如何找回".localizedString,
                                    sureCallback: { [weak self] in
                                        guard let self = self else { return }
                                        let vc = GuideTokenViewController()
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    },
                                    cancelCallback: nil,
                                    removeWithSure: true
                                )
                            } else {
                                showToast(string: err.err)
                            }
                            
                        }
                    }
                }
                
            } else {
                showToast(string: "请在局域网内或登录后使用".localizedString)
            }
            
        case .crm:
            if UserManager.shared.isLogin {
                Task {
                    do {
                        showLoadingView()
                        try await retreiveSAToken()
                        hideLoadingView()
                        let vc = CustomHeaderWebViewController(linkEnum: .crm(token: authManager.currentArea.sa_user_token))
                        let nav = BaseProNavigationViewController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        present(nav, animated: true, completion: nil)
                    } catch {
                        hideLoadingView()
                        TipsAlertView.show(
                            message: "当前终端无凭证或已过期，可通过云端找回凭证。".localizedString,
                            sureTitle: "如何找回".localizedString,
                            sureCallback: { [weak self] in
                                guard let self = self else { return }
                                let vc = GuideTokenViewController()
                                self.navigationController?.pushViewController(vc, animated: true)
                            },
                            cancelCallback: nil,
                            removeWithSure: true
                        )
                    }
                }
            } else if authManager.isSAEnviroment {
                Task {
                    do {
                        showLoadingView()
                        let _ = try await AsyncApiService.areaDetail(area: AuthManager.shared.currentArea)
                        hideLoadingView()
                        let vc = CustomHeaderWebViewController(linkEnum: .crm(token: authManager.currentArea.sa_user_token))
                        let nav = BaseProNavigationViewController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        present(nav, animated: true, completion: nil)
                        
                    } catch {
                        hideLoadingView()
                        if let err = error as? AsyncApiError {
                            if err.code == 2011 || err.code == 2010 || err.code == 5012 {
                                TipsAlertView.show(
                                    message: "当前终端无凭证或已过期，可通过云端找回凭证。".localizedString,
                                    sureTitle: "如何找回".localizedString,
                                    sureCallback: { [weak self] in
                                        guard let self = self else { return }
                                        let vc = GuideTokenViewController()
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    },
                                    cancelCallback: nil,
                                    removeWithSure: true
                                )
                            } else {
                                showToast(string: err.err)
                            }
                            
                        }
                    }
                }
                
            } else {
                showToast(string: "请在局域网内或登录后使用".localizedString)
            }
            
        case .feedback:
            let vc = FeedbackListViewController()
            navigationController?.pushViewController(vc, animated: true)
            
        }

    }
    
    func requestNetwork() {
        /// 如果是云端环境则用云端user_id 否则用对应SA的user_id 请求
        let user_id = UserManager.shared.isLogin ? UserManager.shared.currentUser.user_id : authManager.currentArea.sa_user_id
        
        /// 默认头像 & 昵称
        if let userAvatarData = UserManager.shared.userAvatarData {
            header.avatar.image = UIImage(data: userAvatarData)
        } else {
            header.avatar.setImage(urlString: UserManager.shared.currentUser.avatar_url, placeHolder: .assets(.default_avatar))
        }
        header.nickNameLabel.text = UserManager.shared.currentUser.nickname
        tableView.reloadData()
        
        if !UserManager.shared.isLogin && authManager.currentArea.id == nil {
            return
        }

        /// 如果是云端的话 更新本地存储的用户信息
        if UserManager.shared.isLogin { // 云端用户信息
            ApiServiceManager.shared.cloudUserDetail(id: user_id) { [weak self] (response) in
                guard let self = self else { return }
                /// 如果是云端的话 更新本地存储的用户信息
                self.header.avatar.setImage(urlString: response.user_info.avatar_url, placeHolder: self.header.avatar.image) { img in
                    UserManager.shared.userAvatarData = img.jpegData(compressionQuality: 1)
                }
                self.header.nickNameLabel.text = response.user_info.nickname
                UserManager.shared.currentUser = response.user_info
                UserCache.update(from: response.user_info)
                self.tableView.reloadData()

            } failureCallback: { [weak self] (code, err) in
                guard let self = self else { return }
                self.header.avatar.setImage(urlString: UserManager.shared.currentUser.avatar_url, placeHolder: self.header.avatar.image)
                self.header.nickNameLabel.text = UserManager.shared.currentUser.nickname
                self.tableView.reloadData()
            }
        } else { // sa用户信息
            ApiServiceManager.shared.userDetail(area: authManager.currentArea, id: user_id) { [weak self] (response) in
                guard let self = self else { return }
                self.header.avatar.setImage(urlString: UserManager.shared.currentUser.avatar_url, placeHolder: self.header.avatar.image)
                self.header.nickNameLabel.text = UserManager.shared.currentUser.nickname
                self.tableView.reloadData()

            } failureCallback: { [weak self] (code, err) in
                guard let self = self else { return }
                self.header.avatar.setImage(urlString: UserManager.shared.currentUser.avatar_url, placeHolder: self.header.avatar.image)
                self.header.nickNameLabel.text = UserManager.shared.currentUser.nickname
                self.tableView.reloadData()
            }
        }

    }
    
    @MainActor
    func retreiveSAToken() async throws {
        do {
            let _ = try await AsyncApiService.areaDetail(area: AuthManager.shared.currentArea)
        } catch {
            let response = try await AsyncApiService.getSAToken(area: authManager.currentArea)
            authManager.currentArea.isAllowedGetToken = true
            //更新数据库token
            authManager.currentArea.sa_user_token = response.sa_token
            AreaCache.cacheArea(areaCache: authManager.currentArea.toAreaCache())
        }
    }
    
    
}




fileprivate enum CellType: String {
    case area
    case brands
    case thirdParty
    case proEdition
    case explore
    case aboutUs
    case crm
    case scm
    case feedback

    
    var title: String {
        switch self {
        case .area:
            return "家庭/公司".localizedString
        case .brands:
            return "支持品牌".localizedString
        case .thirdParty:
            return "第三方平台".localizedString
        case .proEdition:
            return "专业版".localizedString
        case .explore:
            return "体验中心".localizedString
        case .aboutUs:
            return "关于我们".localizedString
        case .crm:
            return "客户管理".localizedString
        case .scm:
            return "供应链管理".localizedString
        case .feedback:
            return "问题反馈".localizedString
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .area:
            return .assets(.icon_family_brand)
        case .brands:
            return .assets(.icon_brand)
        case .thirdParty:
            return .assets(.icon_thirdParty)
        case .proEdition:
            return .assets(.icon_professional)
        case .explore:
            return .assets(.icon_experience)
        case .aboutUs:
            return .assets(.icon_about_us)
        case .crm:
            return .assets(.icon_crm)
        case .scm:
            return .assets(.icon_scm)
        case .feedback:
            return .assets(.icon_feedback)
        }
    }
}
