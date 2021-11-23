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
    
    private lazy var switchAreaView =  SwtichAreaView()
    
    lazy var nickname = "\(String(authManager.currentUser.nickname.prefix(1)))******"
    
    lazy var authItems = [AuthItemModel]()
    
    lazy var requestAuthQueue = OperationQueue().then {
        $0.maxConcurrentOperationCount = 1
    }
    
    lazy var requestAuthLock = DispatchSemaphore(value: 1)

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
        $0.text = "欢迎加入智汀家庭云盘".localizedString
    }
    
    private lazy var nasAuthAreaView = NasAuthAreaView()
    
    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .regular)
        $0.textColor = .custom(.black_333333)
        $0.text = "同意将智汀家庭云(\(nickname))的以下信息授权给智汀家庭云盘"
        $0.numberOfLines = 0
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.register(AuthItemCell.self, forCellReuseIdentifier: AuthItemCell.reusableIdentifier)
        $0.delegate = self
        $0.dataSource = self
        $0.estimatedRowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
        $0.isUserInteractionEnabled = false
        
    }
    
    private lazy var confirmButton = CustomButton(buttonType:
                                                .leftLoadingRightTitle(
                                                    normalModel:
                                                        .init(
                                                            title: "确认授权".localizedString,
                                                            titleColor: UIColor.custom(.white_ffffff),
                                                            font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                            bagroundColor: UIColor.custom(.blue_427aed)
                                                        ),
                                                    lodingModel:
                                                        .init(
                                                            title: "授权中...".localizedString,
                                                            titleColor: UIColor.custom(.gray_94a5be),
                                                            font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                            bagroundColor: UIColor.custom(.gray_f6f8fd)
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
        
    }

    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(containerView)
        containerView.addSubview(avatar)
        containerView.addSubview(nickNameLabel)
        containerView.addSubview(welcomeLabel)
        containerView.addSubview(tipsLabel)
        containerView.addSubview(nasAuthAreaView)
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
        
        switchAreaView.selectCallback = { [weak self] area in
            guard let self = self else { return }
            self.nasAuthAreaView.label.text = area.name
            self.requestScopeList()
        }
        
        nasAuthAreaView.clickCallback = { [weak self] in
            guard let self = self else { return }
            SceneDelegate.shared.window?.addSubview(self.switchAreaView)
        }
        
        switchAreaView.areas = AreaCache.areaList()
        switchAreaView.selectedArea = authManager.currentArea
        nasAuthAreaView.label.text = authManager.currentArea.name
        self.requestScopeList()

    }

    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - ZTScaleValue(100))
        }
        
        avatar.snp.makeConstraints {
            $0.height.width.equalTo(ZTScaleValue(60))
            $0.top.left.equalToSuperview()
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(3))
            $0.left.equalTo(avatar.snp.right).offset(16.5)
            $0.right.equalToSuperview()
        }
        
        welcomeLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom)
            $0.left.equalTo(nickNameLabel.snp.left)
            $0.right.equalToSuperview()
        }
        
        nasAuthAreaView.snp.makeConstraints {
            $0.top.equalTo(avatar.snp.bottom).offset(ZTScaleValue(40))
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }


        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(nasAuthAreaView.snp.bottom).offset(ZTScaleValue(27))
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        

        
        tableView.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(ZTScaleValue(25))
            $0.height.equalTo(ZTScaleValue(120))
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        
        
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(ZTScaleValue(175))
            $0.left.right.equalToSuperview()
            $0.height.equalTo(50)
        }

        cancelButton.snp.makeConstraints {
            $0.top.equalTo(confirmButton.snp.bottom).offset(19.5)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview()
        }

    }

}

extension NasAuthorizationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AuthItemCell.reusableIdentifier, for: indexPath) as! AuthItemCell
        cell.authItem = authItems[indexPath.row]
        return cell
    }
    
    
}

extension NasAuthorizationViewController {
    private func requestNetwork() {
        requestScopeList()
    }
    
    @objc private func confirm() {
        confirmButton.selectedChangeView(isLoading: true)
        requestAreaScopeToken()
        
        
    }
}




// MARK: - Network
extension NasAuthorizationViewController {

    /// 获取授权scope列表
    private func requestScopeList() {
        confirmButton.alpha = 0.5
        confirmButton.isUserInteractionEnabled = false
        authItems.removeAll()
        tableView.reloadData()
        
        guard let area = switchAreaView.selectedArea else { return }
        if area.id == nil {
            showToast(string: "当前家庭无智慧中心，请添加智慧中心后重新授权".localizedString)
            return
        }
        
        /// 家庭不在局域网且未登录
        if area.bssid != networkStateManager.getWifiBSSID() && !authManager.isLogin {
            showToast(string: "请登录或在同一局域网下使用".localizedString)
            return
        }
        
        showLoadingView()
        ApiServiceManager.shared.scopeList(area: area) { [weak self] response in
            guard let self = self else { return }
            self.hideLoadingView()
            self.authItems = response.scopes
            self.tableView.reloadData()
            self.confirmButton.alpha = 1
            self.confirmButton.isUserInteractionEnabled = true
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            
            if code == 5012 { //token失效(用户被删除)
                //获取SA凭证
                ApiServiceManager.shared.getSAToken(area: area) { [weak self] response in
                    guard let self = self else { return }
                    
                    //凭证获取成功
                    //移除旧数据库
                    AreaCache.deleteArea(id: area.id, sa_token: area.sa_user_token)
                    //更新数据库token
                    area.sa_user_token = response.sa_token
                    AreaCache.cacheArea(areaCache: area.toAreaCache())
                    self.switchAreaView.areas = AreaCache.areaList()
                    
                    self.hideLoadingView()
                    /// 重新请求
                    self.requestScopeList()
                    
                    
                } failureCallback: { [weak self] code, error in
                    guard let self = self else { return }
                    self.hideLoadingView()
                    if code == 2011 || code == 2010 {
                        //凭证获取失败，2010 登录的用户和找回token的用户不是同一个；2011 不允许找回凭证
                        area.isAllowedGetToken = false
                        
                        TipsAlertView.show(message: "当前家庭无凭证，请找回凭证后重新授权。".localizedString,
                                           sureTitle: "如何找回".localizedString,
                                           sureCallback: { [weak self] in
                            guard let self = self else { return }
                            let vc = GuideTokenViewController()
                            self.navigationController?.pushViewController(vc, animated: true)
                        },
                                           cancelCallback: nil,
                                           removeWithSure: true)
                        
                    } else if code == 3002 {
                        //状态码3002，提示被管理员移除家庭
                        self.showToast(string: "你已退出该家庭，请重新选择一个家庭进行授权".localizedString)
                        
                        
                    } else if code == 2008 || code == 2009 { /// 在SA环境下且未登录, 用户被移除家庭
                        #warning("TODO: 暂未有这种情况的说明")
                        self.showToast(string: "家庭可能被移除或token失效,请先登录")
                    }
                    
                }
            } else if code == 5003 { /// 用户已被移除家庭
                self.hideLoadingView()
                self.showToast(string: "你已退出该家庭，请重新选择一个家庭进行授权".localizedString)
            } else {
                self.hideLoadingView()
                self.showToast(string: err)
            }
        }


    }
    
    
    /// 授权当前绑定SA的家庭
    private func requestAreaScopeToken() {
        guard let area = switchAreaView.selectedArea else { return }
        
        if area.id == nil {
            showToast(string: "当前家庭无智慧中心，请添加智慧中心后重新授权".localizedString)
            return
        }
        
        /// 家庭不在局域网且未登录
        if area.bssid != networkStateManager.getWifiBSSID() && !authManager.isLogin {
            showToast(string: "请登录或在同一局域网下使用".localizedString)
            return
        }

        let scopes = authItems.filter({ $0.isSelected }).map(\.name)

        ApiServiceManager.shared.scopeToken(area: area, scopes: scopes) { [weak self] response in
            guard let self = self else { return }
            let authArea = self.transferToAuthedArea(from: area, scopeTokenModel: response.scope_token)
            if self.authManager.isLogin {
                self.returnAuthResult(cloud_user_id: area.cloud_user_id, cloud_url: cloudUrl, areas: [authArea])
            } else {
                area.id = ""
                self.returnAuthResult(cloud_user_id: nil, cloud_url: nil, areas: [authArea])
            }
            
            

        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.confirmButton.selectedChangeView(isLoading: false)
            if code == 5012 { //token失效(用户被删除)
                //获取SA凭证
                ApiServiceManager.shared.getSAToken(area: area) { [weak self] response in
                    guard let self = self else { return }
                    
                    //凭证获取成功
                    //移除旧数据库
                    AreaCache.deleteArea(id: area.id, sa_token: area.sa_user_token)
                    //更新数据库token
                    area.sa_user_token = response.sa_token
                    AreaCache.cacheArea(areaCache: area.toAreaCache())
                    self.switchAreaView.areas = AreaCache.areaList()
                    /// 重新请求
                    self.requestAreaScopeToken()
                    
                    
                } failureCallback: { [weak self] code, error in
                    guard let self = self else { return }
                    if code == 2011 || code == 2010 {
                        //凭证获取失败，2010 登录的用户和找回token的用户不是同一个；2011 不允许找回凭证
                        area.isAllowedGetToken = false
                        
                        TipsAlertView.show(message: "当前家庭无凭证，请找回凭证后重新授权。".localizedString,
                                           sureTitle: "如何找回".localizedString,
                                           sureCallback: { [weak self] in
                            guard let self = self else { return }
                            let vc = GuideTokenViewController()
                            self.navigationController?.pushViewController(vc, animated: true)
                        },
                                           cancelCallback: nil,
                                           removeWithSure: true)
                        
                    } else if code == 3002 {
                        //状态码3002，提示被管理员移除家庭
                        self.showToast(string: "你已退出该家庭，请重新选择一个家庭进行授权".localizedString)
                        
                        
                    } else if code == 2008 || code == 2009 { /// 在SA环境下且未登录, 用户被移除家庭
                        #warning("TODO: 暂未有这种情况的说明")
                        self.showToast(string: "家庭可能被移除或token失效,请先登录")
                    }
                    
                }
            } else if code == 5003 { /// 用户已被移除家庭
                self.showToast(string: "你已退出该家庭，请重新选择一个家庭进行授权".localizedString)
            } else {
                self.showToast(string: err)
            }
        }
    }
    
    private func returnAuthResult(cloud_user_id: Int?, cloud_url: String?, areas: [AuthedAreaModel]) {
        let result = ResultModel()
        result.cloud_url = cloud_url
        result.cloud_user_id = cloud_user_id
        result.nickname = authManager.currentUser.nickname
        result.areas = areas
        
        if let cloudUrl = cloud_url, let cookie = HTTPCookieStorage.shared.cookies?.first(where: { cloudUrl.contains($0.domain)  }) {
            result.sessionCookie = cookie.value
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
}

// MARK: - Models
extension NasAuthorizationViewController {
        
    private class ResultModel: BaseModel {
        var cloud_user_id: Int?
        var cloud_url: String?
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
