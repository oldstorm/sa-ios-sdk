//
//  SceneViewController.swift
//  ZhiTing
//
//  Created by mac on 2021/4/12.
//

import UIKit


class SceneViewController: BaseViewController {
    
    var needSwitchToCurrentSASituation = true
    
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

    private lazy var sceneHeader = HomeHeader().then {
        $0.backgroundColor = .white
    }
    
    private lazy var loadingView = LodingView().then {
        $0.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight - Screen.k_nav_height)
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
        $0.backgroundColor = .custom(.gray_f6f8fd)
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
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))


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
        
        authManager.roleRefreshPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.checkAuthState()
                }
            }
            .store(in: &cancellables)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        reloadArea(by: authManager.currentArea)
        requestAreas()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        tableView.reloadData()
    }
}

extension SceneViewController{
    
    @objc private func requestNetwork() {
        if (!authManager.isSAEnviroment && !authManager.isLogin) {
            tableView.mj_header?.endRefreshing()
            currentSceneList = nil
            getDataFromDB(area_id: currentArea.id, sa_token: currentArea.sa_user_token)
            tableView.reloadData()
            hideLodingView()
            return
        }

        self.currentSceneList = nil
        self.tableView.isHidden = true
        
         
        ApiServiceManager.shared.sceneList(type: 0) {[weak self]  (respond) in
            guard let self = self else { return }
                self.tableView.isHidden = false
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
                self.tableView.reloadData()
                self.hideLodingView()

        } failureCallback: {(code, err) in
            print("\(err)")
//            self.showToast(string: err.localizedString)
            DispatchQueue.main.async {
                self.getDataFromDB(area_id: self.currentArea.id, sa_token: self.currentArea.sa_user_token)
                self.tableView.isHidden = false
                self.tableView.reloadData()
                self.tableView.mj_header?.endRefreshing()
                self.hideLodingView()
            }

        }
    }
    
    private func getDataFromDB(area_id:Int ,sa_token:String){
        //从本地获取数据
        let manualData = SceneCache.sceneList(area_id: area_id, sa_token: sa_token, is_auto: 0)
        let autoRunData = SceneCache.sceneList(area_id: area_id, sa_token: sa_token, is_auto: 1)
        let sceneListModel = SceneListModel()
        sceneListModel.manual = manualData
        sceneListModel.auto_run = autoRunData
        self.currentSceneList = sceneListModel
    }
    
    private func requestAreas() {
        if !authManager.isLogin {//未登陆取缓存数据
            let areas = AreaCache.areaList()
            self.switchAreaView.areas = areas
            if self.switchAreaView.selectedArea.name == "" {
                if let area = areas.first(where: { $0.sa_user_token == self.authManager.currentArea.sa_user_token }) {
                    self.authManager.currentArea = area
                } else {
                    if let area = areas.first {
                        self.authManager.currentArea = area
                    }
                }
                return
            }

            /// auth
            checkAuthState()
            requestAreaDetail()
            return
        } else {
            //请求家庭列表
            ApiServiceManager.shared.areaList { [weak self] response in
                guard let self = self else { return }
                response.areas.forEach { $0.cloud_user_id = self.authManager.currentUser.user_id }
                AreaCache.cacheAreas(areas: response.areas)
                
                if self.switchAreaView.selectedArea.name == "" {
                    let areas = AreaCache.areaList()
                    if let area = areas.first(where: { $0.sa_user_token == self.authManager.currentArea.sa_user_token }) {
                        self.authManager.currentArea = area
                    } else {
                        if let area = areas.first {
                            self.authManager.currentArea = area
                        }
                    }
                    return
                }
                
                let areas = AreaCache.areaList()

                /// 如果在对应的局域网环境下,将局域网内绑定过SA但未绑定到云端的家庭绑定到云端
                let checkAreas = response.areas.filter({ !$0.is_bind_sa })
                checkAreas.forEach { area in
                    if let bindedArea = areas.first(where: { $0.id == area.id && $0.is_bind_sa }) {
                        /// 如果在对应的局域网内
                        if self.dependency.networkManager.getWifiBSSID() == bindedArea.macAddr {
                            ApiServiceManager.shared.bindCloud(area: bindedArea, cloud_user_id: self.authManager.currentUser.user_id, successCallback: nil, failureCallback: nil)
                        }
                    }
                }

                self.switchAreaView.areas = areas
                /// auth
                self.checkAuthState()
                self.requestAreaDetail()

            } failureCallback: { [weak self] code, err in
                print(err)
                guard let self = self else { return }
                let areas = AreaCache.areaList()
                self.switchAreaView.areas = areas
                if self.switchAreaView.selectedArea.name == "" {
                    if let area = areas.first(where: { $0.sa_user_token == self.authManager.currentArea.sa_user_token }) {
                        self.authManager.currentArea = area
                    } else {
                        if let area = areas.first {
                            self.authManager.currentArea = area
                        }
                    }
                    return
                }
            }
        }

    }
    
    
    private func requestAreaDetail() {
        
        guard (authManager.isSAEnviroment || authManager.isLogin) else { return }
        
        ApiServiceManager.shared.areaDetail(area: currentArea) { [weak self] response in
            guard let self = self else { return }
            self.currentArea.name = response.name
            self.sceneHeader.titleLabel.text = response.name
            self.switchAreaView.selectedArea.name = response.name
            self.switchAreaView.tableView.reloadData()
            AreaCache.cacheArea(areaCache: self.currentArea.toAreaCache())
            
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            if code == 5012 { //token失效(用户被删除)
                WarningAlert.show(message: "你已被管理员移出家庭".localizedString + "\"\(self.currentArea.name)\"")
                
                if self.authManager.isLogin { // 请求sc触发一下清除被移除的家庭逻辑
                    
                ApiServiceManager.shared.areaLocationsList(area: self.currentArea, successCallback: nil) { [weak self] _, _ in
                    self?.requestAreas()
                    }
                }
                
                AreaCache.removeArea(area: self.currentArea)
                self.switchAreaView.areas.removeAll(where: { $0.sa_user_token == self.currentArea.sa_user_token })
                self.switchAreaView.tableView.reloadData()
                
                
                if let currentArea = AreaCache.areaList().first {
                    self.authManager.currentArea = currentArea
                    self.switchAreaView.selectedArea = currentArea
                }  else {
                    /// 如果被移除后已没有家庭则自动创建一个
                    let area = AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)").transferToArea()
                    self.authManager.currentArea = area
                    
                    if self.authManager.isLogin { /// 若已登录同步到云端
                        ApiServiceManager.shared.createArea(name: area.name, locations_name: []) { [weak self] response in
                            guard let self = self else { return }
                            area.id = response.id
                            AreaCache.cacheArea(areaCache: area.toAreaCache())
                            self.authManager.currentArea = area
                            self.switchAreaView.areas = [area]
                            self.switchAreaView.selectedArea = area
                            self.requestAreas()
                        } failureCallback: { code, err in
                            
                        }
                    }
                    
                }
                return
            }
        }

    }
    
        
    private func checkAuthState() {
        createSceneCell.reconnectBtn.stopAnimate()
        noAuthTipsView.refreshBtn.stopAnimate()
        if (!authManager.isSAEnviroment && !authManager.isLogin && currentArea.is_bind_sa) || !currentArea.is_bind_sa {//与智慧中心断开链接
            
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
            
        } else {
            noAuthTipsView.removeFromSuperview()
            tableView.snp.remakeConstraints {
                $0.top.equalTo(sceneHeader.snp.bottom)
                $0.left.right.bottom.equalToSuperview()
            }
            
            
            createSceneCell.creatSceneCellType = .normal
        
            if !authManager.currentRolePermissions.add_scene {
                sceneHeader.setBtns(btns: [.history])
            } else {
                sceneHeader.setBtns(btns: [.add, .history])
            }
        }

    }

}

extension SceneViewController{
    private func reloadArea(by area: Area) {
        switchAreaView.selectedArea = area
        sceneHeader.titleLabel.text = area.name
        
        showLodingView()

        /// auth
        self.checkAuthState()
        
        // 刷新场景列表
        self.requestNetwork()
        
    }
    
    private func showLodingView(){
        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        loadingView.show()
    }
    
    private func hideLodingView(){
        loadingView.hide()
        loadingView.removeFromSuperview()
    }
}


extension SceneViewController: UITableViewDelegate, UITableViewDataSource{
        
    func numberOfSections(in tableView: UITableView) -> Int {
        if (currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count == 0) || (currentSceneList?.auto_run.count != 0 && currentSceneList?.manual.count != 0) || currentSceneList == nil {//无数据
            return 2
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
                self.requestNetwork()
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


