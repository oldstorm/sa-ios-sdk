//
//  DiskAuthorizationViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/5/26.
//

import UIKit

class DiskAuthorizationViewController: BaseViewController {
    let shareTokenURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.zhiting.tech")!.appendingPathComponent("shareToken.plist")
    
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
        $0.addTarget(self, action: #selector(confirm), for: .touchUpInside)
    }

    private lazy var protocolLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(11), type: .medium)
        $0.textColor = .custom(.gray_94a5be)
        $0.textAlignment = .center
        $0.text = "确认授权即视为同意《用户授权协议》"
        $0.numberOfLines = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requestNetwork()
    }

    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(containerView)
        containerView.addSubview(avatar)
        containerView.addSubview(nickNameLabel)
        containerView.addSubview(welcomeLabel)
        containerView.addSubview(tipsLabel)
        containerView.addSubview(tableView)
        containerView.addSubview(confirmButton)
        view.addSubview(protocolLabel)
        
        
        ///test
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(test)))
        avatar.isUserInteractionEnabled = true
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

        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(avatar.snp.bottom).offset(ZTScaleValue(65))
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
            $0.bottom.equalToSuperview()
        }

        protocolLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-(10 + Screen.bottomSafeAreaHeight))
            $0.centerX.equalToSuperview()
        }

    }

}

extension DiskAuthorizationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AuthItemCell.reusableIdentifier, for: indexPath) as! AuthItemCell
        cell.authItem = authItems[indexPath.row]
        return cell
    }
    
    
}

extension DiskAuthorizationViewController {
    private func requestNetwork() {

        requestScopeList()
    }
    
    @objc private func confirm() {
        confirmButton.selectedChangeView(isLoading: true)
        if authManager.isLogin { /// 登录时请求所有家庭scopeToken
            requestAreasScopeToken()
        } else { /// 请求当前家庭scopeToken
           requestAreaScopeToken()
        }
        
    }
}


fileprivate class AuthItemCell: UITableViewCell, ReusableView {
    var authItem: AuthItemModel? {
        didSet {
            guard let item = authItem else { return }
            label.text = item.description
        }
    }
    
    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.selected_tick)
        $0.alpha = 0.5
    }
    
    private lazy var label = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .regular)
        $0.textColor = .custom(.black_333333)
        $0.text = " "
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(icon)
        contentView.addSubview(label)
        
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().priority(.high)
            $0.height.width.equalTo(ZTScaleValue(16)).priority(.high)
            $0.bottom.equalToSuperview().offset(-10)
        }

        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(icon.snp.right).offset(10.5)
            $0.right.equalToSuperview().priority(.high)
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Network
extension DiskAuthorizationViewController {

    /// 获取授权scope列表
    private func requestScopeList() {
//        let requestEnv: RequestEnvironment = authManager.isLogin ? .cloud : .sa
//
//        apiService.requestModel(.scopeList(area: authManager.currentArea), requestEnv: requestEnv, allowSwitchEnv: false, modelType: ScopesListResponse.self) { [weak self] response in
//            guard let self = self else { return }
//            self.authItems = response.scopes
//            self.tableView.reloadData()
//
//        } failureCallback: { [weak self] code, err in
//            self?.showToast(string: err)
//            /// test
//            let item1 = AuthItemModel()
//            item1.description = "获取你的登录状态"
//            item1.name = "user"
//            let item2 = AuthItemModel()
//            item2.description = "获取你的家庭信息"
//            item2.name = "area"
//            self?.authItems = [item1, item2]
//            self?.tableView.reloadData()
//        }

        let item1 = AuthItemModel()
        item1.description = "获取你的登录状态"
        item1.name = "user"
        let item2 = AuthItemModel()
        item2.description = "获取你的家庭信息"
        item2.name = "area"
        authItems = [item1, item2]
        tableView.reloadData()
    }
    
    /// 登录时授权所有绑定SA的家庭
    private func requestAreasScopeToken() {
        let areas = AreaCache.areaList().filter({ $0.is_bind_sa })
        let scopes = authItems.filter({ $0.isSelected }).map(\.name)
        
        var finishTaskCount = 0
        var authAreas = [AuthedAreaModel]()
        
        areas.forEach { area in
            let requestOperation = BlockOperation { [weak self] in
                guard let self = self else { return }
                self.requestAuthLock.wait()
                DispatchQueue.main.async {
                    ApiServiceManager.shared.scopeToken(area: area, scopes: scopes) { [weak self] response in
                        guard let self = self else { return }
                        let area = self.transferToAuthedArea(from: self.authManager.currentArea, scopeTokenModel: response.scope_token)
                        authAreas.append(area)
                        finishTaskCount += 1
                        if finishTaskCount == areas.count {
                            self.returnAuthResult(cloud_user_id: self.authManager.currentUser.user_id, cloud_url: cloudUrl, areas: authAreas)
                        }

                        self.requestAuthLock.signal()

                    } failureCallback: { [weak self] code, err in
                        guard let self = self else { return }
                        finishTaskCount += 1
                        if finishTaskCount == areas.count {
                            self.returnAuthResult(cloud_user_id: self.authManager.currentUser.user_id, cloud_url: cloudUrl, areas: authAreas)
                        }
                        self.requestAuthLock.signal()
                    }

                }
                
            }
            
            requestAuthQueue.addOperation(requestOperation)
            
        }
        
        
        
        

    }
    
    @objc
    private func test() {
        let area = Area()
        area.sa_user_id = 1
        area.is_bind_sa = true
        area.name = "demo"
        area.sa_lan_address = "sa.zhitingtech.com"
        

        let scopeTokenModel = ScopeTokenModel()
        scopeTokenModel.expires_in = 480000
        scopeTokenModel.token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Mjk1MTAwNTksInNhX2lkIjoidGVzdC1zYSIsInNjb3BlcyI6InVzZXIsYXJlYSIsInVpZCI6MX0.NvG2YUTc50R-ZyBADleTAaWX5biFNuYv5TAdxDBzsuo"
        let areas = [area]
        
        var finishTaskCount = 0
        var authAreas = [AuthedAreaModel]()
        areas.forEach { area in
            let requestOperation = BlockOperation { [weak self] in
                guard let self = self else { return }
                self.requestAuthLock.wait()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    authAreas.append(self.transferToAuthedArea(from: area, scopeTokenModel: scopeTokenModel))
                    finishTaskCount += 1
                    print(area.name)
                    if finishTaskCount == areas.count {
                        self.returnAuthResult(cloud_user_id: self.authManager.currentUser.user_id, cloud_url: cloudUrl, areas: authAreas)
                    }
                    self.requestAuthLock.signal()
                }
                
            }
            
            requestAuthQueue.addOperation(requestOperation)
            
        }
    }
    
    
    
    /// 未登录时只授权当前绑定SA的家庭
    private func requestAreaScopeToken() {
        let scopes = authItems.filter({ $0.isSelected }).map(\.name)
        if !authManager.currentArea.is_bind_sa {
            showToast(string: "当前家庭未绑定SA")
            confirmButton.selectedChangeView(isLoading: false)
            return
        }

        ApiServiceManager.shared.scopeToken(area: authManager.currentArea, scopes: scopes) { [weak self] response in
            guard let self = self else { return }
            let area = self.transferToAuthedArea(from: self.authManager.currentArea, scopeTokenModel: response.scope_token)
            area.id = 0
            self.returnAuthResult(cloud_user_id: nil, cloud_url: nil, areas: [area])

        } failureCallback: { [weak self] code, err in
            self?.showToast(string: err)
            self?.confirmButton.selectedChangeView(isLoading: false)
        }


    }
    
    private func returnAuthResult(cloud_user_id: Int?, cloud_url: String?, areas: [AuthedAreaModel]) {
        let result = ResultModel()
        result.cloud_url = cloud_url
        result.cloud_user_id = cloud_user_id
        result.nickname = authManager.currentUser.nickname
        result.areas = areas
        if let cloudUrl = cloud_url, let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.domain == cloudUrl }) {
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
        
        if let url = URL(string: "zhitingcloud://operation?action=auth") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        dismiss(animated: true, completion: nil)

    }
}

// MARK: - Models
extension DiskAuthorizationViewController {
    private class ScopesListResponse: BaseModel {
        var scopes = [AuthItemModel]()
    }
        
    private class ResultModel: BaseModel {
        var cloud_user_id: Int?
        var cloud_url: String?
        var nickname = ""
        var sessionCookie: String?
        var areas = [AuthedAreaModel]()
    }
    
    private class AuthedAreaModel: BaseModel {
        /// id
        var id = 0
        /// 名称
        var name = ""
        /// sa的地址
        var sa_lan_address: String?
        /// sa的mac地址
        var macAddr: String?
        /// smartAssistant's user_id
        var sa_user_id = 1
        
        var sa_user_token = ""
        
        var scope_token = ""
        
        var expires_in = 0
    }
    
    private func transferToAuthedArea(from area: Area, scopeTokenModel: ScopeTokenModel) -> AuthedAreaModel {
        let model = AuthedAreaModel()
        model.id = area.id
        model.name = area.name
        model.sa_user_id = area.sa_user_id
        model.macAddr = area.macAddr
        model.sa_lan_address = area.sa_lan_address
        model.scope_token = scopeTokenModel.token
        model.expires_in = scopeTokenModel.expires_in
        model.sa_user_token = area.sa_user_token
        return model
    }

}
