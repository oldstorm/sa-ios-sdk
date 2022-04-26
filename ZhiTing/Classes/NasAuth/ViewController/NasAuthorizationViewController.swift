//
//  NasAuthorizationViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/5/26.
//

import UIKit
import SwiftUI

class NasAuthorizationViewController: BaseViewController {
    let shareTokenURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.zhiting.tech")!.appendingPathComponent("shareToken.plist")
    
    private lazy var nickname = "\(String(UserManager.shared.currentUser.nickname.prefix(1)))******"
    
    /// 需要授权的家庭
    private var areas = [Area]()
    
    /// 已授权的家庭
    private var authAreas = [AuthedAreaModel]()
    
    /// 授权家庭的授权状态dict
    private var authStateDict = [String: AuthAreaItemCell.AuthState]()

    private lazy var containerView = UIView()

    private lazy var avatar = ImageView().then {
        $0.image = .assets(.default_avatar_rounded)
        $0.contentMode = .scaleAspectFit
    }

    private lazy var nickNameLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(20), type: .bold)
        $0.textColor = .custom(.black_333333)
        $0.text = nickname
    }
    
    private lazy var welcomeLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(20), type: .light)
        $0.textColor = .custom(.black_333333)
        $0.text = "欢迎加入智汀云盘".localizedString
    }
    
    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .regular)
        $0.textColor = .custom(.black_333333)
        $0.text = "同意将智汀家庭云(\(nickname))的登录状态及以下信息授权给智汀云盘"
        $0.numberOfLines = 0
    }
    
    private lazy var areaTipsLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_333333)
        $0.text = "家庭/公司包括："
        $0.numberOfLines = 0
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.register(AuthAreaItemCell.self, forCellReuseIdentifier: AuthAreaItemCell.reusableIdentifier)
        $0.delegate = self
        $0.dataSource = self
        $0.estimatedRowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
        
    }
    
    private lazy var confirmButton = CustomButton(buttonType:
                                                .leftLoadingRightTitle(
                                                    normalModel:
                                                        .init(
                                                            title: "确认授权".localizedString,
                                                            titleColor: UIColor.custom(.white_ffffff),
                                                            font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                            backgroundColor: UIColor.custom(.blue_427aed)
                                                        ),
                                                    lodingModel:
                                                        .init(
                                                            title: "授权中...".localizedString,
                                                            titleColor: UIColor.custom(.gray_94a5be),
                                                            font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                            backgroundColor: UIColor.custom(.gray_f6f8fd)
                                                        )
                                                )
    ).then {
        $0.layer.cornerRadius = ZTScaleValue(4)
        $0.layer.masksToBounds = true
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.alpha = 0.5
        $0.isUserInteractionEnabled = false
        $0.addTarget(self, action: #selector(confirm), for: .touchUpInside)
    }
    
    private lazy var cancelButton = Button().then {
        $0.layer.cornerRadius = ZTScaleValue(4)
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_dddddd).cgColor
        $0.setTitleColor(.custom(.black_333333), for: .normal)
        $0.setTitle("取消".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getAreaList()
        Task {
            await tryAuthorizeAll()
        }
    }

    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(containerView)
        containerView.addSubview(avatar)
        containerView.addSubview(nickNameLabel)
        containerView.addSubview(welcomeLabel)
        containerView.addSubview(tipsLabel)
        containerView.addSubview(areaTipsLabel)
        containerView.addSubview(tableView)
        containerView.addSubview(confirmButton)
        containerView.addSubview(cancelButton)
        
        cancelButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            if let url = URL(string: "zhitingNas://") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            self.dismiss(animated: true, completion: nil)
        }
        

    }

    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - ZTScaleValue(100))
        }
        
        avatar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.height.width.equalTo(ZTScaleValue(60))
            $0.left.equalToSuperview()
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(avatar.snp.top).offset(ZTScaleValue(3))
            $0.left.equalTo(avatar.snp.right).offset(16.5)
            $0.right.equalToSuperview()
        }
        
        welcomeLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom)
            $0.left.equalTo(nickNameLabel.snp.left)
            $0.right.equalToSuperview()
        }
        


        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(welcomeLabel.snp.bottom).offset(ZTScaleValue(36))
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        areaTipsLabel.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(ZTScaleValue(36))
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }

        
        tableView.snp.makeConstraints {
            $0.bottom.equalTo(confirmButton.snp.top).offset(-25)
            $0.top.equalTo(areaTipsLabel.snp.bottom).offset(14)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(cancelButton.snp.top).offset(-19.5)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(50)
        }

        cancelButton.snp.makeConstraints {
            $0.top.equalTo(confirmButton.snp.bottom).offset(19.5)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-25)
        }

    }

}

extension NasAuthorizationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AuthAreaItemCell.reusableIdentifier, for: indexPath) as! AuthAreaItemCell
        let area = areas[indexPath.row]
        
        cell.area = area
        if let id = area.id,
           let state = authStateDict[id] {
            cell.authState = state
            cell.retryBtn.clickCallBack = { [weak self] _ in
                guard let self = self else { return }
                Task { [weak self] in
                    guard let self = self else { return }
                    if let authModel = await self.authorizeArea(area: area) {
                        self.authAreas.append(authModel)
                    }
                }
            }
        }

        return cell
    }
    
    
}

extension NasAuthorizationViewController {
    @objc private func confirm() {
        Task {
            await toAuthorize()
        }
    }
    
}

extension NasAuthorizationViewController {
    private func getAreaList() {
        if UserManager.shared.isLogin { // 如果登录情况下 授权该sc账户所有存在实体SA的家庭/公司
            areas = AreaCache.areaList().filter({ $0.is_bind_sa && !$0.needRebindCloud })
            
        } else { // 如果非登录状态下 授权当前局域网下的家庭/公司
            areas = AreaCache.areaList().filter({ $0.bssid == NetworkStateManager.shared.getWifiBSSID() && $0.bssid != nil })
            
        }
        
        areas.compactMap(\.id).forEach { id in
            authStateDict[id] = .waiting
        }
        
        if areas.count == 0 {
            confirmButton.setTitleColor(.custom(.gray_94a5be), for: .disabled)
            confirmButton.alpha = 0.5
            confirmButton.isUserInteractionEnabled = false
        } else {
            confirmButton.setTitleColor(.custom(.white_ffffff), for: .disabled)
            confirmButton.alpha = 1
            confirmButton.isUserInteractionEnabled = true
        }
        
    }
    
    /// 尝试授权所有家庭
    @MainActor
    private func tryAuthorizeAll() async {
        checkAuthBtnEnable()
        /// 异步获取每个家庭的scopeToken
        await withTaskGroup(of: AuthedAreaModel?.self) { group in
            
            areas.forEach { area in
                group.addTask {
                    await self.authorizeArea(area: area)
                }
            }
            

            for await authArea in group {
                if let authArea = authArea {
                    self.authAreas.append(authArea)
                }
            }
            
        }
    }
    
    /// 开始授权
    @MainActor
    private func toAuthorize() async {
        guard authAreas.count > 0 else {
            confirmButton.selectedChangeView(isLoading: false)
            showToast(string: "授权失败".localizedString)
            return
        }
        
        let result = ResultModel()
        result.areas = authAreas
        result.cloud_url = cloudUrl
        result.nickname = UserManager.shared.currentUser.nickname

        if UserManager.shared.isLogin { /// 登录情况下将sc用户信息也带上
            result.cloud_user_id = UserManager.shared.currentUser.user_id
            result.cloud_phone = UserManager.shared.currentPhoneNumber
            if let cookie = HTTPCookieStorage.shared.cookies?.first(where: { cloudUrl.contains($0.domain)  }) {
                result.sessionCookie = cookie.value
            }
        }

        guard let json = result.toJSONString(),
              let data = try? NSKeyedArchiver.archivedData(withRootObject: json, requiringSecureCoding: true)
        else {
            confirmButton.selectedChangeView(isLoading: false)
            return
        }

        try? data.write(to: shareTokenURL, options: .atomic)

        confirmButton.selectedChangeView(isLoading: false)

        if let url = URL(string: "zhitingNas://operation?action=auth") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        dismiss(animated: true, completion: nil)
    }
    
    /// 单个授权家庭过程
    @MainActor
    private func authorizeArea(area: Area) async -> AuthedAreaModel? {
        do {
            let scopes = try await AsyncApiService.getAreaScopeList(area: area)
            let scopeTokenModel = try await AsyncApiService.getAreaScopeToken(area: area, scopes: scopes)
            if let id = area.id {
                authStateDict[id] = .done
                tableView.reloadData()
                checkAuthBtnEnable()
            }
            
            return transferToAuthedArea(from: area, scopeTokenModel: scopeTokenModel)

        } catch {
            guard let error = error as? AsyncApiError else { return nil }
            if (error.code == 5012 || error.code == 5027) && UserManager.shared.isLogin {
                /// token失效尝试找回
                if let response = try? await AsyncApiService.getSAToken(area: area) {
                    area.sa_user_token = response.sa_token
                    AreaCache.cacheArea(areaCache: area.toAreaCache())
                    checkAuthBtnEnable()
                    return await authorizeArea(area: area)
                } else {
                    if let id = area.id {
                        authStateDict[id] = .fail
                        tableView.reloadData()
                        checkAuthBtnEnable()
                    }
                    return nil
                }
            } else {
                if let id = area.id {
                    authStateDict[id] = .fail
                    tableView.reloadData()
                    checkAuthBtnEnable()
                }
                return nil
            }
            
        }
    }
    
    func checkAuthBtnEnable() {
        if authStateDict.values.count == 0 {
            confirmButton.backgroundColor = .custom(.gray_f6f8fd)
            confirmButton.isUserInteractionEnabled = false
            confirmButton.title.textColor = .custom(.gray_94a5be)
            return
        }
        
        confirmButton.isUserInteractionEnabled = true
        authStateDict.values.filter({ $0 == .waiting }).count == 0 ? confirmButton.selectedChangeView(isLoading: false) : confirmButton.selectedChangeView(isLoading: true)
    }

}


// MARK: - Models
extension NasAuthorizationViewController {
        
    private class ResultModel: BaseModel {
        var cloud_user_id: Int?
        var cloud_url: String?
        var cloud_phone: String?
        var nickname = ""
        var sessionCookie: String?
        var areas = [AuthedAreaModel]()
    }
    
    private class AuthedAreaModel: BaseModel {
        /// id
        var id = ""
        /// 名称
        var name = ""
        /// sa的id
        var sa_id: String?
        /// sa的地址
        var sa_lan_address: String?
        /// sa的mac地址
        var bssid: String?
        /// smartAssistant's user_id
        var sa_user_id = 1
        
        var sa_user_token = ""
        
        var scope_token = ""
        
        var expires_in = 0
    }
    
    private func transferToAuthedArea(from area: Area, scopeTokenModel: ScopeTokenModel) -> AuthedAreaModel {
        let model = AuthedAreaModel()
        model.id = area.id ?? ""
        model.name = area.name
        model.sa_id = area.sa_id
        model.sa_user_id = area.sa_user_id
        model.bssid = area.bssid
        model.sa_lan_address = area.sa_lan_address
        model.scope_token = scopeTokenModel.token
        model.expires_in = scopeTokenModel.expires_in
        model.sa_user_token = area.sa_user_token
        return model
    }

}
