//
//  SceneViewController.swift
//  ZhiTing
//
//  Created by zy on 2021/4/12.
//

import UIKit


class SceneViewController: BaseViewController {
    
    var needSwitchToCurrentSASituation = true
    
    private class AreaListReponse: BaseModel {
        var areas = [Area]()
    }
    
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
        $0.containerView.layer.cornerRadius = 0
        $0.refreshBtn.isHidden = false
    }

    private lazy var sceneHeader = HomeHeader().then {
        $0.backgroundColor = .white
    }
    
    private lazy var loadingView = LodingView().then {
        $0.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight)
    }
    
    private var switchAreaView =  SwtichAreaView()
    private var gifDuration = 0.0

    private var currentArea: Area?
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
    }
    
    override func setupViews() {
        view.addSubview(sceneHeader)
        view.backgroundColor = .custom(.white_ffffff)
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
            self.currentAreaManager.currentArea = area
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
        
        currentAreaManager.currentAreaPublisher
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
        reloadArea(by: currentAreaManager.currentArea)
        requestAreas()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        tableView.reloadData()
    }
}

extension SceneViewController{
    
    @objc private func requestNetwork() {
        guard let currentArea = currentArea else {
            tableView.mj_header?.endRefreshing()
            currentSceneList = nil
            tableView.reloadData()
            hideLodingView()
            return
        }
        
        if (currentArea.sa_token.contains("unbind") || currentArea.sa_token != authManager.currentSA.token) {//当连接上了SA才允许请求
            tableView.mj_header?.endRefreshing()
            currentSceneList = nil
            getDataFromDB(area_id: currentArea.id, sa_token: currentArea.sa_token)
            tableView.reloadData()
            hideLodingView()
            return
        }

        self.currentSceneList = nil
        self.tableView.isHidden = true
        
        apiService.requestModel(.sceneList(type: 0), modelType: SceneListModel.self) {[weak self]  (respond) in
            guard let self = self else { return }
                self.tableView.isHidden = false
                self.currentSceneList = respond
                if respond.manual.count != 0 {
                    //存储手动数据
                    SceneCache.cacheScenes(scenes: respond.manual, area_id: currentArea.id, sa_token: currentArea.sa_token, is_auto: 0)
                }
            
                if respond.auto_run.count != 0 {
                    //存储自动数据
                    SceneCache.cacheScenes(scenes: respond.auto_run, area_id: currentArea.id, sa_token: currentArea.sa_token, is_auto: 1)
                }
                self.tableView.mj_header?.endRefreshing()
                self.tableView.reloadData()
                self.hideLodingView()

        } failureCallback: {(code, err) in
            print("\(err)")
//            self.showToast(string: err.localizedString)
            DispatchQueue.main.async {
                self.getDataFromDB(area_id: currentArea.id, sa_token: currentArea.sa_token)
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
        apiService.requestModel(.areaList, modelType: AreaListReponse.self) { [weak self] (response) in
            guard let self = self else { return }
            
            response.areas.forEach { $0.sa_token = self.authManager.currentSA.token }
            AreaCache.cacheAreas(areas: response.areas)
            
            let areas = AreaCache.areaList()

            /// update the switchSituationView
            self.switchAreaView.areas = areas
            
            if self.switchAreaView.selectedArea.name == "" {
                if let area = areas.first(where: { $0.sa_token == self.authManager.currentSA.token }) {
                    self.currentAreaManager.currentArea = area
                } else {
                    if let area = areas.first {
                        self.currentAreaManager.currentArea = area
                    }
                }
                return
            }
            
            /// need switch to currentSA's situation
            if self.needSwitchToCurrentSASituation {
                if let area = areas.first(where: { $0.sa_token == self.authManager.currentSA.token }) {
                    self.currentAreaManager.currentArea = area
                }
                self.needSwitchToCurrentSASituation = false
                return
            }
            

        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            
            if code == 13 { //token失效(用户被删除)
                self.currentArea?.sa_token = AreaCache.unbindArea(sa_token: self.authManager.currentSA.token)
                if let currentArea = self.currentArea {
                    self.currentAreaManager.currentArea = currentArea
                }
                self.hideLodingView()
                return
            }
            
            let cacheAreas = AreaCache.areaList()
            self.switchAreaView.areas = cacheAreas
            if let area = cacheAreas.first,
               self.switchAreaView.selectedArea.name == ""
            {
                self.currentAreaManager.currentArea = area
                return

            }
            
            /// need switch to currentSA's situation
            if self.needSwitchToCurrentSASituation {
                if let area = cacheAreas.first(where: { $0.sa_token == self.authManager.currentSA.token }) {
                    self.currentAreaManager.currentArea = area
                }
                self.needSwitchToCurrentSASituation = false
                return
            }
            /// auth
            self.checkAuthState()
        }

    }
        
    private func checkAuthState() {
        createSceneCell.reconnectBtn.stopAnimate()
        noAuthTipsView.refreshBtn.stopAnimate()
        if let currentSituation = currentArea,
           (currentSituation.sa_token.contains("unbind") || !authManager.isSAEnviroment) {
            
            sceneHeader.setBtns(btns: [])
            
            view.addSubview(noAuthTipsView)
            noAuthTipsView.snp.makeConstraints {
                $0.top.equalTo(sceneHeader.snp.bottom)
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
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

    private func updateActionResult(_ id: Int,_ isOn: Bool,_ isAuto: Bool, indexPath: IndexPath){
        var model = SceneTypeModel()
        if (self.currentSceneList?.manual.count != 0 && self.currentSceneList?.auto_run.count == 0) {//仅有手动
            model = (self.currentSceneList?.manual[indexPath.row])!
        }else if(self.currentSceneList?.manual.count == 0 && self.currentSceneList?.auto_run.count != 0){//仅有自动
            model = (self.currentSceneList?.auto_run[indexPath.row])!
        }else{//手动和自动都有数据
            if indexPath.section == 0 {//手动
                model = (self.currentSceneList?.manual[indexPath.row])!
            }else{//自动
                model = (self.currentSceneList?.auto_run[indexPath.row])!
            }
        }
        //上传执行结果到服务器
        self.showLodingView()
        apiService.requestModel(.sceneExecute(scene_id: id, is_execute: isOn), modelType: isSuccessModel.self) { [weak self] (respond) in
            guard let self = self else {
                return
            }

            if respond.success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.hideLodingView()
                    print("执行成功")
                    if isAuto {
                        self.showToast(string: "自动执行\(isOn ? "开启":"关闭")成功")
                    }else{
                        self.showToast(string: "手动执行成功")
                    }
                    self.requestNetwork()
                }
            }
        } failureCallback: { [weak self] (code, error) in
            guard let self = self else {
                return
            }
            self.hideLodingView()
            print("执行失败")
            if isAuto {
                self.showToast(string: "自动执行\(isOn ? "开启":"关闭")失败")
            }else{
                self.showToast(string: "手动执行失败")
            }
            model.is_on = false
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

}

extension SceneViewController{
    private func reloadArea(by area: Area) {
        switchAreaView.selectedArea = area
        currentArea = area
        sceneHeader.titleLabel.text = area.name
        
        // switch according SA
        if let saCache = SmartAssistantCache.getSmartAssistantsFromCache().first(where: { $0.token == area.sa_token }) {
            authManager.currentSA = saCache
        }
        
        if area.sa_token.contains("unbind") {
            if let saCache = SmartAssistantCache.getSmartAssistantsFromCache().first(where: { $0.token == "" }) {
                authManager.currentSA = saCache
            }
        }
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
            
            cell.selectCallback = {[weak self] (isOn, isAuto) in
                guard let self = self else {
                    return
                }
                print("当前操作结果为", isOn ? "执行":"关闭")
                self.updateActionResult(cell.currentSceneModel!.id, isOn, isAuto, indexPath: indexPath)
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
                lable.text = "手动"
            }else if(currentSceneList?.manual.count == 0 && currentSceneList?.auto_run.count != 0){//自动
                lable.text = "自动"
            }else{//手动自动均有
                switch section {
                case 0:
                    lable.text = "手动"
                case 1:
                    lable.text = "自动"
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


