//
//  SceneViewController.swift
//  ZhiTing
//
//  Created by mac on 2021/4/12.
//

import UIKit


class SceneViewController: BaseViewController {
    
    var needSwitchToCurrentSASituation = true
    
    private lazy var noTokenEmptyView = EmptyStyleView(frame: .zero, style: .noToken)
    
    private lazy var createSceneCell = CreatSceneCell().then { cell in
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.title.text = "暂无场景".localizedString
        cell.icon.image = .assets(.noScene)
        cell.creatSceneBtn.setTitle("点击添加场景".localizedString, for: .normal)
        cell.creatSceneBtn.clickCallBack = { [weak self] _ in
            let vc = EditSceneViewController(type: .create)
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private lazy var noAuthTipsView = NoAuthTipsView().then {
        $0.refreshBtn.isHidden = false
    }

    
    private lazy var noTokenTipsView = NoTokenTipsView().then {
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noTokenTapAction)))
        $0.isUserInteractionEnabled = true
    }


    private lazy var sceneHeader = HomeHeader().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    
    private var switchAreaView =  SwtichAreaView()
    private var gifDuration = 0.0

    private var currentArea: Area {
        return authManager.currentArea
    }
    
    private var currentSceneList: SceneListModel?

    lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.estimatedSectionHeaderHeight = 10
        $0.estimatedSectionFooterHeight = 0
        $0.sectionFooterHeight = 0
        $0.separatorStyle = .none
        $0.contentInset.bottom = ZTScaleValue(10)
        $0.rowHeight = UITableView.automaticDimension
        //创建场景Cell
        $0.register(CreatSceneCell.self, forCellReuseIdentifier: CreatSceneCell.reusableIdentifier)
        //教程Cell
        $0.register(CourseCell.self, forCellReuseIdentifier: CourseCell.reusableIdentifier)
        //场景Cell
        $0.register(SceneCell.self, forCellReuseIdentifier: SceneCell.reusableIdentifier)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableSideSliding = true
    }
    
    override func setupViews() {
        view.addSubview(sceneHeader)
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        tableView.addSubview(noTokenEmptyView)

        createSceneCell.reconnectBtn.clickCallBack = { [weak self] in
            guard let self = self else { return }
            self.createSceneCell.reconnectBtn.startAnimate()
            self.checkAuthState()
        }

        noAuthTipsView.refreshBtn.clickCallBack = { [weak self] in
            guard let self = self else { return }
            self.noAuthTipsView.refreshBtn.startAnimate()
            self.checkAuthState()
        }

        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(getDatasInfo))


        switchAreaView.selectCallback = { [weak self] area in
            guard let self = self else { return }
            self.authManager.currentArea = area
        }

        sceneHeader.switchAreaCallButtonCallback = { [weak self] in
            guard let self = self else { return }
            SceneDelegate.shared.window?.addSubview(self.switchAreaView)
        }
        
        sceneHeader.plusBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }

            let vc = EditSceneViewController(type: .create)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        sceneHeader.historyBtn.clickCallBack = { _ in
            print("点击了历史按钮")
            let vc = HistoryViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    override func setupConstraints() {
        sceneHeader.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(Screen.k_nav_height + ZTScaleValue(10))
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(sceneHeader.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        noTokenEmptyView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 30)
            $0.height.equalTo(tableView.snp.height).offset(-ZTScaleValue(120))
            $0.top.equalToSuperview().offset(15)
        }
    }
    
    override func setupSubscriptions() {
        
        authManager.currentAreaPublisher
            .sink { [weak self] area in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.reloadArea(by: area)
                }
                
            }
            .store(in: &cancellables)
        
    }
    
    //点击查看允许找回权限方法
    @objc private func noTokenTapAction() {
        let vc = GuideTokenViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        reloadArea(by: authManager.currentArea)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        tableView.reloadData()
    }
}

extension SceneViewController{
    
    
    @objc private func getDatasInfo(){
        let semaphore = DispatchSemaphore(value: 1)
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {return}
            
        // MARK: - 获取家庭信息
            semaphore.wait()
            if !self.authManager.isLogin {
                //未登陆获取缓存数据
                DispatchQueue.main.async {
                    let areas = AreaCache.areaList()
                    self.switchAreaView.areas = areas
                    if let selected = areas.first(where: { $0.sa_user_token == self.currentArea.sa_user_token }) {
                        self.switchAreaView.selectedArea = selected
                        self.currentArea.name = selected.name
                    } else {
                        if let area = areas.first {
                            self.switchAreaView.selectedArea = area
                            self.authManager.currentArea = area
                            return
                        }
                    }
                    semaphore.signal()
                }
                
            }else{
                //用户已登陆，直接请求数据
                self.switchAreaView.selectedArea = self.currentArea
                ApiServiceManager.shared.areaList { [weak self] response in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        response.areas.forEach { $0.cloud_user_id = self.authManager.currentUser.user_id }
                        AreaCache.cacheAreas(areas: response.areas)
                        let areas = AreaCache.areaList()
                        
                        /// 如果在对应的局域网环境下,将局域网内绑定过SA但未绑定到云端的家庭绑定到云端
                        if areas.filter({ $0.needRebindCloud }).count > 0 {
                            AuthManager.shared.syncLocalAreasToCloud { [weak self] in
                                guard let self = self else { return }
                                self.switchAreaView.areas = AreaCache.areaList()
                            }
                        } else {
                            self.switchAreaView.areas = areas
                        }
                        semaphore.signal()
                    }
                    
                } failureCallback: { [weak self] code, err in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        let areas = AreaCache.areaList()
                        self.switchAreaView.areas = areas
                        self.switchAreaView.selectedArea = self.currentArea
                        semaphore.signal()
                    }
                }
            }
        // MARK: - 获取家庭详情
            semaphore.wait()
            if (self.authManager.isSAEnviroment || self.authManager.isLogin) && self.currentArea.sa_lan_address != nil {
                
                ApiServiceManager.shared.areaDetail(area: self.currentArea) { [weak self] response in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.currentArea.name = response.name
                        self.sceneHeader.titleLabel.text = response.name
                        self.switchAreaView.selectedArea?.name = response.name
                        let cache = self.currentArea.toAreaCache()
                        AreaCache.cacheArea(areaCache: cache)
                        semaphore.signal()
                    }
                    
                    
                } failureCallback: { [weak self] (code, err) in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        self.sceneHeader.titleLabel.text = self.switchAreaView.selectedArea?.name
                    }
                    
                    if code == 5012 { //token失效(用户被删除)
                        //获取SA凭证
                        ApiServiceManager.shared.getSAToken(area: self.currentArea) { [weak self] response in
                            guard let self = self else { return }
                            //凭证获取成功
                            DispatchQueue.main.async {
                                self.currentArea.isAllowedGetToken = true
                                self.noTokenTipsView.removeFromSuperview()
                                self.tableView.snp.remakeConstraints {
                                    $0.top.equalTo(self.sceneHeader.snp.bottom)
                                    $0.left.right.bottom.equalToSuperview()
                                }

                                //移除旧数据库
                                AreaCache.deleteArea(id: self.currentArea.id, sa_token: self.currentArea.sa_user_token)
                                self.switchAreaView.areas.removeAll(where: { $0.sa_user_token == self.currentArea.sa_user_token })
                                //更新数据库token
                                self.currentArea.sa_user_token = response.sa_token
                                AreaCache.cacheArea(areaCache: self.currentArea.toAreaCache())
                                semaphore.signal()
                            }
                            
                            
                        } failureCallback: {[weak self] code, error in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                if code == 2011 || code == 2010 {
                                    //凭证获取失败，2010 登录的用户和找回token的用户不是同一个；2011 不允许找回凭证
                                    self.currentArea.isAllowedGetToken = false
                                    self.view.addSubview(self.noTokenTipsView)
                                    self.noTokenTipsView.snp.makeConstraints {
                                        $0.top.equalTo(self.sceneHeader.snp.bottom).offset(ZTScaleValue(10))
                                        $0.left.equalToSuperview().offset(ZTScaleValue(15))
                                        $0.right.equalToSuperview().offset(ZTScaleValue(-15))
                                        $0.height.equalTo(40)
                                    }
                                    self.tableView.snp.remakeConstraints {
                                        $0.top.equalTo(self.noTokenTipsView.snp.bottom)
                                        $0.left.right.bottom.equalToSuperview()
                                    }
                                    
                                    //页面刷新
                                    self.tableView.reloadData()
                                    semaphore.signal()
                                    
                                } else if code == 3002 {
                                    //状态码3002，提示被管理员移除家庭
                                    WarningAlert.show(message: "你已被管理员移出家庭".localizedString + "\"\(self.currentArea.name)\"")
                                                                    
                                    AreaCache.removeArea(area: self.currentArea)
                                    self.switchAreaView.areas.removeAll(where: { $0.sa_user_token == self.currentArea.sa_user_token })
                                    
                                    if let currentArea = self.switchAreaView.areas.first {
                                        self.authManager.currentArea = currentArea
                                        self.switchAreaView.selectedArea = currentArea
                                        semaphore.signal()
                                    } else {
                                        /// 如果被移除后已没有家庭则自动创建一个
                                        let area = AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)").transferToArea()
                                        self.authManager.currentArea = area
                                        
                                        if self.authManager.isLogin { /// 若已登录同步到云端
                                            ApiServiceManager.shared.createArea(name: area.name, locations_name: []) { [weak self] response in
                                                guard let self = self else { return }
                                                area.id = response.id
                                                AreaCache.cacheArea(areaCache: area.toAreaCache())
                                                self.switchAreaView.areas = [area]
                                                self.switchAreaView.selectedArea = area
                                                self.authManager.currentArea = area
                                                semaphore.signal()
                                            } failureCallback: { code, err in
                                                semaphore.signal()
                                            }
                                        }
                                    }
                                } else if code == 2008 || code == 2009 { /// 在SA环境下且未登录, 用户被移除家庭
                                    #warning("TODO: 暂未有这种情况的说明")
                                    self.showToast(string: "家庭可能被移除或token失效,请先登录")
                                }
                            }
                        }
                    } else if code == 5003 { /// 用户已被移除家庭
                            /// 提示被管理员移除家庭
                            WarningAlert.show(message: "你已被管理员移出家庭".localizedString + "\"\(self.currentArea.name)\"")
                            
                            AreaCache.removeArea(area: self.currentArea)
                            self.switchAreaView.areas.removeAll(where: { $0.sa_user_token == self.currentArea.sa_user_token })
                            
                            if let currentArea = self.switchAreaView.areas.first {
                                self.authManager.currentArea = currentArea
                                self.switchAreaView.selectedArea = currentArea
                            } else {
                                /// 如果被移除后已没有家庭则自动创建一个
                                let area = AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)").transferToArea()
                                self.authManager.currentArea = area
                                
                                if self.authManager.isLogin { /// 若已登录同步到云端
                                    ApiServiceManager.shared.createArea(name: area.name, locations_name: []) { [weak self] response in
                                        guard let self = self else { return }
                                        area.id = response.id
                                        AreaCache.cacheArea(areaCache: area.toAreaCache())
                                        self.switchAreaView.areas = [area]
                                        self.switchAreaView.selectedArea = area
                                        self.authManager.currentArea = area
                                    } failureCallback: { code, err in
                                        
                                    }
                                }
                            }
                    }
                }

            }else{
                DispatchQueue.main.async {
                    self.sceneHeader.titleLabel.text = self.currentArea.name
                    semaphore.signal()
                }
                
            }
        // MARK: - 获取场景列表
            semaphore.wait()
            
            if self.currentArea.isAllowedGetToken {
                if (!self.authManager.isSAEnviroment && !self.authManager.isLogin) {
                    self.currentSceneList = nil
                    DispatchQueue.main.async {
                        self.getDataFromDB(area_id: self.currentArea.id, sa_token: self.currentArea.sa_user_token)
                        self.checkAuthState()
                        self.tableView.reloadData()
                        semaphore.signal()
                    }
                }else{
                    ApiServiceManager.shared.sceneList(type: 0) {[weak self]  (respond) in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            
                            let list = SceneListModel()
                            list.auto_run = respond.auto_run
                            list.manual = respond.manual
                            self.currentSceneList = list
                            if respond.manual.count != 0 {
                                //存储手动数据
                                SceneCache.cacheScenes(scenes: respond.manual, area_id: self.currentArea.id, sa_token: self.currentArea.sa_user_token, is_auto: 0)
                            }
                            
                            if respond.auto_run.count != 0 {
                                //存储自动数据
                                SceneCache.cacheScenes(scenes: respond.auto_run, area_id: self.currentArea.id, sa_token: self.currentArea.sa_user_token, is_auto: 1)
                            }
                            
                            self.tableView.mj_header?.endRefreshing()
                            self.checkAuthState()
                            self.tableView.reloadData()
                            semaphore.signal()
                        }
                    } failureCallback: {[weak self] (code, err) in
                        guard let self = self else { return }
                        
                        DispatchQueue.main.async {
                            self.tableView.mj_header?.endRefreshing()
                            self.checkAuthState()
                            self.tableView.reloadData()
                            semaphore.signal()
                        }
                    }
                }
                
            }else{
                DispatchQueue.main.async {
                    self.tableView.mj_header?.endRefreshing()
                    self.checkAuthState()
                    self.currentSceneList = nil
                    self.tableView.reloadData()
                    semaphore.signal()
                }
            }
            
        }
    }
    
    
    private func getDataFromDB(area_id: String? ,sa_token: String){
        //从本地获取数据
        let manualData = SceneCache.sceneList(area_id: area_id, sa_token: sa_token, is_auto: 0)
        let autoRunData = SceneCache.sceneList(area_id: area_id, sa_token: sa_token, is_auto: 1)
        let sceneListModel = SceneListModel()
        sceneListModel.manual = manualData
        sceneListModel.auto_run = autoRunData
        self.currentSceneList = sceneListModel
    }
        
        
    private func checkAuthState() {
        
        createSceneCell.reconnectBtn.stopAnimate()
        noAuthTipsView.refreshBtn.stopAnimate()
        noTokenTipsView.removeFromSuperview()
        if !authManager.isSAEnviroment && !authManager.isLogin && currentArea.id != nil {//与智慧中心断开链接

            sceneHeader.setBtns(btns: [])
            
            view.addSubview(noAuthTipsView)
            noAuthTipsView.snp.makeConstraints {
                $0.top.equalTo(sceneHeader.snp.bottom).offset(ZTScaleValue(10))
                $0.left.equalToSuperview().offset(ZTScaleValue(15))
                $0.right.equalToSuperview().offset(ZTScaleValue(-15))
                $0.height.equalTo(40)
            }
            
            tableView.snp.remakeConstraints {
                $0.top.equalTo(noAuthTipsView.snp.bottom)
                $0.left.right.bottom.equalToSuperview()
            }
            
            createSceneCell.creatSceneCellType = .noAuth
            if !currentArea.is_bind_sa {
                createSceneCell.creatSceneBtn.isUserInteractionEnabled = false
                createSceneCell.creatSceneBtn.backgroundColor = .custom(.gray_eeeeee)
            } else {
                createSceneCell.creatSceneBtn.isUserInteractionEnabled = true
                createSceneCell.creatSceneBtn.backgroundColor = .custom(.blue_2da3f6)
            }
            

        } else {
            
            if currentArea.isAllowedGetToken {
                
                noTokenTipsView.removeFromSuperview()
                noAuthTipsView.removeFromSuperview()
                self.noTokenEmptyView.isHidden = true
                tableView.snp.remakeConstraints {
                    $0.top.equalTo(sceneHeader.snp.bottom)
                    $0.left.right.bottom.equalToSuperview()
                }

            }else{
                self.view.addSubview(self.noTokenTipsView)
                self.noTokenEmptyView.isHidden = false

                self.noTokenTipsView.snp.makeConstraints {
                    $0.top.equalTo(self.sceneHeader.snp.bottom).offset(ZTScaleValue(10))
                    $0.left.equalToSuperview().offset(ZTScaleValue(15))
                    $0.right.equalToSuperview().offset(ZTScaleValue(-15))
                    $0.height.equalTo(40)
                }
                
                self.tableView.snp.remakeConstraints {
                    $0.top.equalTo(self.noTokenTipsView.snp.bottom)
                    $0.left.right.bottom.equalToSuperview()
                }
            }
            
            createSceneCell.creatSceneCellType = .normal
            if !currentArea.is_bind_sa {
                createSceneCell.creatSceneBtn.isUserInteractionEnabled = false
                createSceneCell.creatSceneBtn.backgroundColor = .custom(.gray_eeeeee)
            } else {
                createSceneCell.creatSceneBtn.isUserInteractionEnabled = true
                createSceneCell.creatSceneBtn.backgroundColor = .custom(.blue_2da3f6)
            }
            
            if !authManager.currentRolePermissions.add_scene {
                sceneHeader.setBtns(btns: [.history])
            } else {
                sceneHeader.setBtns(btns: [.add, .history])
            }
        }
        
        self.hideLoadingView()

    }

}

extension SceneViewController{
    private func reloadArea(by area: Area) {
        switchAreaView.selectedArea = area
        sceneHeader.titleLabel.text = area.name
        
        self.showLoadingView()
        // 刷新场景列表
        self.getDatasInfo()
        
    }
    
}


extension SceneViewController: UITableViewDelegate, UITableViewDataSource{
        
    func numberOfSections(in tableView: UITableView) -> Int {
        if (currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count == 0) || (currentSceneList?.auto_run.count != 0 && currentSceneList?.manual.count != 0) || currentSceneList == nil {//无数据
            if currentArea.isAllowedGetToken {
                return 2
            }else{
                return 0
            }
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count == 0 || currentSceneList == nil){//无数据
            return 1
        }else if(currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count != 0){//仅有手动数据
            return currentSceneList?.manual.count ?? 0
        }else if(currentSceneList?.auto_run.count != 0 && currentSceneList?.manual.count == 0){//仅有自动数据
            return currentSceneList?.auto_run.count ?? 0
        }else if(currentSceneList?.auto_run.count != 0 && currentSceneList?.manual.count != 0){//手动和自动都有数据
            switch section {
            case 0:
                return currentSceneList?.manual.count ?? 0
            case 1:
                return currentSceneList?.auto_run.count ?? 0
            default:
                return 0
            }
        }else{
            return 0
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count == 0 || currentSceneList == nil) {//无数据
            if indexPath.section == 0 {//添加场景
                
                return createSceneCell
            }else{//快速教程
                let cell = tableView.dequeueReusableCell(withIdentifier: CourseCell.reusableIdentifier, for: indexPath) as! CourseCell
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.title.text = "教你快速入门职能场景".localizedString
                cell.icon.image = .assets(.course_bg)
                
                return cell
            }
        }else{//有数据
            let cell = tableView.dequeueReusableCell(withIdentifier: SceneCell.reusableIdentifier, for: indexPath) as! SceneCell
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            if (currentSceneList?.manual.count != 0 && currentSceneList?.auto_run.count == 0) {//仅有手动
                cell.setModelAndTypeWith(model: (currentSceneList?.manual[indexPath.row])!, type: .manual)
            }else if(currentSceneList?.manual.count == 0 && currentSceneList?.auto_run.count != 0){//仅有自动
                cell.setModelAndTypeWith(model: (currentSceneList?.auto_run[indexPath.row])!, type: .auto_run)
            }else{//手动和自动都有数据
                if indexPath.section == 0 {//手动
                    cell.setModelAndTypeWith(model: (currentSceneList?.manual[indexPath.row])!, type: .manual)
                }else{//自动
                    cell.setModelAndTypeWith(model: (currentSceneList?.auto_run[indexPath.row])!, type: .auto_run)
                }
            }
            
            cell.executiveCallback = {[weak self] result in
                guard let self = self else {
                    return
                }
                //提示执行结果
                self.showToast(string: result)
                //重新刷新列表，更新执行后状态
                self.getDatasInfo()
            }
            
            return cell
        }
    }

    
    //header
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.frame = CGRect(x: ZTScaleValue(15.0), y: 0, width: Screen.screenWidth - ZTScaleValue(30.0), height: ZTScaleValue(53.0))
        let lable = UILabel()
        lable.font = .font(size: ZTScaleValue(13.0))
        lable.textColor = .custom(.gray_94a5be)
        lable.frame = view.frame
        view.addSubview(lable)
        
        if (currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count == 0 || currentSceneList == nil) {//无数据
            if section == 1 {
                lable.text = "如何创建场景".localizedString
            }
        }else{
            if (currentSceneList?.manual.count != 0 && currentSceneList?.auto_run.count == 0) {//手动
                lable.text = "手动".localizedString
            }else if(currentSceneList?.manual.count == 0 && currentSceneList?.auto_run.count != 0){//自动
                lable.text = "自动".localizedString
            }else{//手动自动均有
                switch section {
                case 0:
                    lable.text = "手动".localizedString
                case 1:
                    lable.text = "自动".localizedString
                default:
                    lable.text = " "
                }
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count == 0 || currentSceneList == nil) {
            if section == 0 {
                return ZTScaleValue(10.0)
            }else{
                return ZTScaleValue(40)
            }
        }else{
            return ZTScaleValue(40)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    ///click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //是否有数据
        if (currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count == 0 || currentSceneList == nil) {//无数据
            if indexPath.section == 0 {
                print("添加场景")
            }else{
                print("快速教程")
                let vc = SceneGuideViewController()
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            
            var scene_id: Int?
            if currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count != 0 {
                scene_id = currentSceneList?.manual[indexPath.row].id
            } else if currentSceneList?.auto_run.count != 0 && currentSceneList?.manual.count == 0 {
                scene_id = currentSceneList?.auto_run[indexPath.row].id
            } else {
                if indexPath.section == 0 {
                    scene_id = currentSceneList?.manual[indexPath.row].id
                } else {
                    scene_id = currentSceneList?.auto_run[indexPath.row].id
                }
            }
            
            //权限判断
            if !authManager.currentRolePermissions.update_scene {//无执行权限
                self.showToast(string: "暂无修改场景权限")
                return
            }

            let vc = EditSceneViewController(type: .edit)
            vc.scene_id = scene_id
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}


