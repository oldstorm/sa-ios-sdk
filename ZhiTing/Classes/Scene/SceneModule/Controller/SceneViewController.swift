//
//  SceneViewController.swift
//  ZhiTing
//
//  Created by mac on 2021/4/12.
//

import UIKit
import Combine
import JXSegmentedView

class SceneViewController: BaseViewController {
    
    var needSwitchToCurrentSASituation = true
    var viewTap = SceneType.manual
    
    /// 子控制器
    private lazy var subVCs = [SceneSubViewController]() {
        didSet {
            subVCs.forEach { vc in
                vc.superCanScrollCallback = { [weak self] superCanScroll in
                    guard let self = self else { return }
                    self.superCanScroll = superCanScroll
                }
            }
        }
    }
    
    private lazy var noTokenEmptyView = EmptyStyleView(frame: .zero, style: .noToken).then {
        $0.isHidden = true
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
        $0.refreshBtn.isHidden = false
    }

    
    private lazy var noTokenTipsView = NoTokenTipsView().then {
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noTokenTapAction)))
        $0.isUserInteractionEnabled = true
    }

    private lazy var sceneHeader = HomeHeader().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private var switchAreaView =  SwitchAreaView()
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
    
    var isEditingCell = false {
        didSet {
            if isEditingCell {
                editButton.setTitle("完成".localizedString, for: .normal)
                segmentedView?.isUserInteractionEnabled = false
            } else {
                editButton.setTitle("排序".localizedString, for: .normal)
                segmentedView?.isUserInteractionEnabled = true

            }
            self.listContainerView?.scrollView.isScrollEnabled = !self.isEditingCell

            if let vc = listContainerView?.validListDict[self.segmentedView?.selectedIndex ?? 0] as? SceneSubViewController {
                vc.isEditingCell = isEditingCell
            }
        }
    }
    
    private lazy var editButton = Button().then {
        $0.setTitle("排序".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }

    
    private var segmentedDataSource: JXSegmentedTitleDataSource?
    private var segmentedView: JXSegmentedView?
    private var listContainerView: JXSegmentedListContainerView?
    
    
    /// 吸顶的offset
    var stickyOffset = Screen.k_nav_height - Screen.statusBarHeight - ZTScaleValue(10)

    /// 父vc是否可以滚动
    var superCanScroll = true
    
    private lazy var scrollView = CustomScrollView(frame: CGRect(x: 0, y: Screen.statusBarHeight, width: Screen.screenWidth, height: Screen.screenHeight)).then {
        $0.showsVerticalScrollIndicator = false
        $0.isDirectionalLockEnabled = true
        $0.alwaysBounceVertical = false
        $0.delegate = self
        $0.direction = .vertical
    }

    private lazy var scrollViewContainerView = UIView()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableSideSliding = true
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContainerView)
        scrollViewContainerView.addSubview(sceneHeader)
        scrollViewContainerView.addSubview(tableView)
        tableView.addSubview(noTokenEmptyView)
        setupSegmentDataSource()

        createSceneCell.reconnectBtn.clickCallBack = { [weak self] in
            guard let self = self else { return }
            self.createSceneCell.reconnectBtn.startAnimate()
            self.checkAuthState()
        }
        
        noAuthTipsView.labelCallback = { [weak self] in
            guard let self = self else { return }
            let vc = WKWebViewController(linkEnum: .offlineHelp)
            vc.webViewTitle = "离线帮助".localizedString
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        noAuthTipsView.refreshBtn.clickCallBack = { [weak self] in
            guard let self = self else { return }
            self.noAuthTipsView.refreshBtn.startAnimate()
            self.checkAuthState()
        }

//        let header = ZTGIFRefreshHeader()
//        tableView.mj_header = header
//        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(reloadAll))


        switchAreaView.selectCallback = { [weak self] area in
            guard let self = self else { return }
            self.authManager.currentArea = area
            self.isEditingCell = false
        }

        sceneHeader.switchAreaCallButtonCallback = { [weak self] in
            guard let self = self else { return }
            self.showSwitchAreaView()
        }
        
        sceneHeader.plusBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            
            self.isEditingCell = false
            let vc = EditSceneViewController(type: .create)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        sceneHeader.historyBtn.clickCallBack = { _ in
            print("点击了历史按钮")
            self.isEditingCell = false
            let vc = HistoryViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    override func setupConstraints() {
        
        scrollViewContainerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.bottom.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth)
        }
        
        sceneHeader.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview().offset(-Screen.statusBarHeight)
            $0.height.equalTo(Screen.k_nav_height)
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] area in
                guard let self = self else { return }
                if self.view.window != nil && self.isViewLoaded {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count == 0 || currentSceneList == nil){//无数据
            return
        }else if(currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count != 0){//仅有手动数据
            viewTap = .manual
        }else if(currentSceneList?.auto_run.count != 0 && currentSceneList?.manual.count == 0){//仅有自动数据
            viewTap = .auto_run
        }else if(currentSceneList?.auto_run.count != 0 && currentSceneList?.manual.count != 0){//手动和自动都有数据
            switch segmentedView?.selectedIndex {
            case 0:
                viewTap = .manual
            default:
                viewTap = .auto_run
            }
        }

    }
}

extension SceneViewController: UIScrollViewDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            if !superCanScroll {
                scrollView.contentOffset.y = stickyOffset
                subVCs.forEach { $0.canScroll = true }
            } else if scrollView.contentOffset.y >= stickyOffset {
                scrollView.contentOffset.y = stickyOffset
                if subVCs.count > 0 {
                    superCanScroll = false
                }
                subVCs.forEach { $0.canScroll = true }
            }else if scrollView.contentOffset.y <= 0 {
                scrollView.contentOffset.y = 0
            }
        }
    }
}

extension SceneViewController {
    
    private func updateSegmentView(){
        var segmentTap = 0
        var titles = [""]
        if (currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count == 0 || currentSceneList == nil){//无数据
            subVCs.removeAll()
            tableView.isHidden = false
            segmentedView?.isHidden = true
            listContainerView?.isHidden = true
            editButton.isHidden = true
            self.hideLoadingView()
            return
        }else if(currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count != 0){//仅有手动数据
            if subVCs.count > 0 {
                if subVCs[0].sceneType == .manual{
                    subVCs[0].dataSource = currentSceneList!.manual
                    subVCs[0].tableView.mj_header?.endRefreshing()
                }else{
                    //自动和手动变化，则刷新所有数据
                    subVCs.removeAll()
                    let vc = SceneSubViewController()
                    vc.sceneType = .manual
                    vc.dataSource = currentSceneList!.manual
                    vc.superCanScrollCallback = { [weak self] superCanScroll in
                        guard let self = self else { return }
                        self.superCanScroll = superCanScroll
                    }
                    subVCs.append(vc)
                }
            }
            
            titles = ["手动".localizedString]
            segmentTap = 0

        }else if(currentSceneList?.auto_run.count != 0 && currentSceneList?.manual.count == 0){//仅有自动数据
            if subVCs.count > 0 {
                if subVCs[0].sceneType == .auto_run{
                    subVCs[0].dataSource = currentSceneList!.auto_run
                    subVCs[0].tableView.mj_header?.endRefreshing()
                }else{
                    //自动和手动变化，则刷新所有数据
                    subVCs.removeAll()
                    let vc = SceneSubViewController()
                    vc.sceneType = .auto_run
                    vc.dataSource = currentSceneList!.auto_run
                    vc.superCanScrollCallback = { [weak self] superCanScroll in
                        guard let self = self else { return }
                        self.superCanScroll = superCanScroll
                    }
                    subVCs.append(vc)
                }
            }
            
            titles = ["自动".localizedString]
            segmentTap = 0

        }else if(currentSceneList?.auto_run.count != 0 && currentSceneList?.manual.count != 0){//手动和自动都有数据
            titles = ["手动".localizedString,"自动".localizedString]
            
            if subVCs.count == 2 {
                subVCs[0].dataSource = currentSceneList!.manual
                subVCs[0].tableView.mj_header?.endRefreshing()
                subVCs[1].dataSource = currentSceneList!.auto_run
                subVCs[1].tableView.mj_header?.endRefreshing()
            }else{
                //自动和手动变化，则刷新所有数据
                subVCs.removeAll()
                let vc = SceneSubViewController()
                vc.sceneType = .manual
                vc.dataSource = currentSceneList!.manual
                vc.superCanScrollCallback = { [weak self] superCanScroll in
                    guard let self = self else { return }
                    self.superCanScroll = superCanScroll
                }
                
                let vc2 = SceneSubViewController()
                vc2.sceneType = .auto_run
                vc2.dataSource = currentSceneList!.auto_run
                vc2.superCanScrollCallback = { [weak self] superCanScroll in
                    guard let self = self else { return }
                    self.superCanScroll = superCanScroll
                }
                subVCs.append(vc)
                subVCs.append(vc2)
            }

            switch viewTap {
            case .manual:
                segmentTap = 0
            case .auto_run:
                segmentTap = 1
            }
        }
        
        
        //有数据，则隐藏原本的tableview，展示segmentView
        tableView.isHidden = true
        segmentedView?.isHidden = false
        listContainerView?.isHidden = false
        //判断是否有修改权限

        if authManager.currentRolePermissions.update_scene{
            editButton.isHidden = false
            self.segmentedView?.snp.remakeConstraints{
                $0.top.equalTo(sceneHeader.snp.bottom)
                $0.left.equalToSuperview()
                $0.right.equalToSuperview().offset(-ZTScaleValue(50))
                $0.height.equalTo(ZTScaleValue(50.0))
            }
        }else{
            editButton.isHidden = true
            self.segmentedView?.snp.remakeConstraints {
                $0.top.equalTo(sceneHeader.snp.bottom)
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
                $0.height.equalTo(ZTScaleValue(50.0))
            }
        }
        segmentedDataSource?.titles = titles
        self.segmentedDataSource?.reloadData(selectedIndex: segmentTap)
        self.segmentedView?.reloadData()
        self.listContainerView?.reloadData()
        self.hideLoadingView()
    }
    
    private func setupSegmentDataSource() {
        segmentedView?.removeFromSuperview()
        listContainerView?.removeFromSuperview()
        editButton.removeFromSuperview()
        let titles = [""]
        //配置数据源
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.titles = titles
        dataSource.titleNormalColor = .custom(.gray_94a5be)
        dataSource.titleSelectedColor = .custom(.black_3f4663)
        dataSource.titleNormalFont = .font(size: ZTScaleValue(16.0), type: .bold)
        dataSource.isItemSpacingAverageEnabled = false
        
        segmentedDataSource = dataSource
        //配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.verticalOffset = 10
        indicator.indicatorWidthIncrement = -10
        indicator.indicatorColor = .custom(.blue_2da3f6)
        
        
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        segmentedView = JXSegmentedView()
        segmentedView!.indicators = [indicator]
        
        segmentedView!.dataSource = segmentedDataSource
        segmentedView!.delegate = self
        listContainerView = JXSegmentedListContainerView(dataSource: self)
        
        segmentedView!.listContainer = listContainerView
        segmentedView!.backgroundColor = .custom(.gray_f6f8fd)
        
        scrollViewContainerView.addSubview(segmentedView!)
        scrollViewContainerView.addSubview(listContainerView!)
        scrollViewContainerView.addSubview(editButton)
        
        editButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.isEditingCell = !self.isEditingCell
            //编辑状态时，列表不能切换
            if let vc = self.listContainerView?.validListDict[self.segmentedView?.selectedIndex ?? 0] as? SceneSubViewController {
                if !self.isEditingCell {
                    vc.updateSceneSort()
                }
            }

        }
        
        segmentedView?.snp.makeConstraints {
            $0.top.equalTo(sceneHeader.snp.bottom)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview().offset(-ZTScaleValue(50))
            $0.height.equalTo(ZTScaleValue(50.0))
        }
        
        editButton.snp.makeConstraints {
            $0.centerY.equalTo(segmentedView!)
            $0.left.equalTo(segmentedView!.snp.right)
            $0.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(50.0))
        }
        
        listContainerView?.snp.makeConstraints {
            $0.top.equalTo(segmentedView!.snp.bottom)
            $0.height.equalTo(view.bounds.height - Screen.k_nav_height)
            $0.left.right.bottom.equalToSuperview()
        }

        tableView.isHidden = false
        segmentedView?.isHidden = true
        listContainerView?.isHidden = true
        editButton.isHidden = true
    }
    
}


extension SceneViewController{
    
    @MainActor
    func asyncRequest() async {
        /// 初始化状态
        noTokenTipsView.removeFromSuperview()
        noAuthTipsView.removeFromSuperview()
        self.currentSceneList = nil
        /// 获取家庭公司列表
        await getAreaList()
        /// 获取家庭公司详情
        await getAreaDetail()
        /// 检查SA版本
        let isSupportSA = await checkSAVersion()
        if !isSupportSA {
            self.hideLoadingView()
            return
        }
        /// 数据刷新
        self.checkAuthState()
        self.switchAreaView.tableView.reloadData()
        self.getSceneData()
        
    }
    

    /// 获取家庭列表
    @MainActor
    func getAreaList() async {
        if !UserManager.shared.isLogin { //用户未登陆
            let areas = AreaCache.areaList()
            self.switchAreaView.areas = areas
            if let selected = areas.first(where: { ($0.sa_user_token == currentArea.sa_user_token && $0.sa_user_token != "") || ($0.id == currentArea.id && $0.id != nil) }) {
                switchAreaView.selectedArea = selected
                currentArea.name = selected.name
            } else {
                if let area = areas.first {
                    switchAreaView.selectedArea = area
                    authManager.currentArea = area
                    return
                }
            }
            
            
        } else { //用户已登陆，请求数据
            self.switchAreaView.selectedArea = self.currentArea
            do {
                let responseAreas = try await AsyncApiService.getAreaList()
                responseAreas.forEach { $0.cloud_user_id = UserManager.shared.currentUser.user_id }
                AreaCache.cacheAreas(areas: responseAreas)

                await syncLocalAreasToCloud()
                self.switchAreaView.areas = AreaCache.areaList()
                
            } catch {
                let areas = AreaCache.areaList()
                switchAreaView.areas = areas
                switchAreaView.selectedArea = self.currentArea
            }
        }
    }
    
    /// 如果在对应的局域网环境下,将局域网内绑定过SA但未绑定到云端的家庭绑定到云端
    @MainActor
    func syncLocalAreasToCloud() async {
        let areas = AreaCache.areaList()
        guard areas.filter({ $0.needRebindCloud || $0.id == nil }).count > 0 else {
            return
        }
        
        await withCheckedContinuation { continuation in
            AuthManager.shared.syncLocalAreasToCloud {
                continuation.resume(returning: ())
            }
        }
       
    }
    
    /// 获取家庭详情
    @MainActor
    func getAreaDetail() async {
        guard authManager.isSAEnviroment || UserManager.shared.isLogin && currentArea.id != nil else {
            sceneHeader.titleLabel.text = currentArea.name
            return
        }
        
        var errorCode: Int?
        do {
            let areaResponse = try await AsyncApiService.areaDetail(area: currentArea)
            currentArea.name = areaResponse.name
            sceneHeader.titleLabel.text = areaResponse.name
            switchAreaView.selectedArea?.name = areaResponse.name
            let cache = currentArea.toAreaCache()
            AreaCache.cacheArea(areaCache: cache)
        } catch {
            sceneHeader.titleLabel.text = switchAreaView.selectedArea?.name
            guard let error = error as? AsyncApiError else { return }
            errorCode = error.code
        }
        
        if errorCode == 5012 || errorCode == 5027 { /// token失效(用户被删除)
            do {
                let response = try await AsyncApiService.getSAToken(area: currentArea)
                currentArea.isAllowedGetToken = true
                noTokenTipsView.removeFromSuperview()
                self.tableView.snp.remakeConstraints {
                    $0.top.equalTo(self.sceneHeader.snp.bottom)
                    $0.left.right.bottom.equalToSuperview()
                }

                //移除旧数据库
                AreaCache.deleteArea(id: currentArea.id, sa_token: currentArea.sa_user_token)
                switchAreaView.areas.removeAll(where: { $0.sa_user_token == currentArea.sa_user_token })
                //更新数据库token
                currentArea.sa_user_token = response.sa_token
                AreaCache.cacheArea(areaCache: currentArea.toAreaCache())
                /// 再次请求. 页面刷新
                AuthManager.shared.updateCurrentArea()
            } catch {
                if let error = error as? AsyncApiError {
                    if error.code == 2011 || error.code == 2010 || error.code == 2008 {
                                                
                        //凭证获取失败，2010 登录的用户和找回token的用户不是同一个；2011 不允许找回凭证
                        currentArea.isAllowedGetToken = false
                        scrollViewContainerView.addSubview(noTokenTipsView)
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
                        
                    } else if error.code == 5003 || error.code == 3002 { /// 用户已被移除家庭
                        if currentArea.needRebindCloud { // 未成功绑定到云端的家庭暂不移除
                            return
                        }
                        /// 提示被管理员移除家庭
                        WarningAlert.show(message: "你已被管理员移出家庭".localizedString + "\"\(currentArea.name)\"")
                        
                        AreaCache.removeArea(area: currentArea)
                        self.switchAreaView.areas.removeAll(where: { $0.sa_user_token == currentArea.sa_user_token || ($0.id == currentArea.id && $0.id != nil) })
                        
                        if let currentArea = switchAreaView.areas.first {
                            authManager.currentArea = currentArea
                            switchAreaView.selectedArea = currentArea
                        } else {
                            /// 如果被移除后已没有家庭则自动创建一个
                            if UserManager.shared.isLogin { /// 若已登录同步到云端
                                ApiServiceManager.shared.createArea(name: "我的家", location_names: [], department_names: [], area_type: .family) { [weak self] response in
                                    guard let self = self else { return }
                                    let area = Area()
                                    area.id = response.id
                                    AreaCache.cacheArea(areaCache: area.toAreaCache())
                                    self.switchAreaView.areas = [area]
                                    self.switchAreaView.selectedArea = area
                                    self.authManager.currentArea = area
                                } failureCallback: { [weak self] code, err in
                                    guard let self = self else { return }
                                    let area = AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family).transferToArea()
                                    self.authManager.currentArea = area
                                }
                            } else {
                                let area = AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family).transferToArea()
                                authManager.currentArea = area
                            }
                        }
                    } else {
                        showToast(string: error.err)
 
                    }
                    
                }
            }
        } else if errorCode == 5003 || errorCode == 3002 { /// 用户已被移除家庭
            if currentArea.needRebindCloud { // 未成功绑定到云端的家庭暂不移除
                return
            }
            /// 提示被管理员移除家庭
            WarningAlert.show(message: "你已被管理员移出家庭".localizedString + "\"\(currentArea.name)\"")
            
            AreaCache.removeArea(area: currentArea)
            self.switchAreaView.areas.removeAll(where: { $0.sa_user_token == currentArea.sa_user_token || ($0.id == currentArea.id && $0.id != nil) })
            
            if let currentArea = switchAreaView.areas.first {
                authManager.currentArea = currentArea
                switchAreaView.selectedArea = currentArea
            } else {
                /// 如果被移除后已没有家庭则自动创建一个
                if UserManager.shared.isLogin { /// 若已登录同步到云端
                    ApiServiceManager.shared.createArea(name: "我的家", location_names: [], department_names: [], area_type: .family) { [weak self] response in
                        guard let self = self else { return }
                        let area = Area()
                        area.id = response.id
                        AreaCache.cacheArea(areaCache: area.toAreaCache())
                        self.switchAreaView.areas = [area]
                        self.switchAreaView.selectedArea = area
                        self.authManager.currentArea = area
                    } failureCallback: { [weak self] code, err in
                        guard let self = self else { return }
                        let area = AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family).transferToArea()
                        self.authManager.currentArea = area
                    }
                } else {
                    let area = AreaCache.createArea(name: "我的家", locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family).transferToArea()
                    authManager.currentArea = area
                }
            }
        } else if errorCode == 100001 { // 云端家庭已迁移
            /// 重新获取临时通道
            /// 置空本地存储的临时通道地址
            let key = AuthManager.shared.currentArea.sa_user_token
            UserDefaults.standard.setValue("", forKey: key)
            /// 再次请求. 页面刷新
            AuthManager.shared.updateCurrentArea()
            
        }

    }
    
    //获取场景信息
    private func getSceneData(){
        if self.currentArea.isAllowedGetToken {
            if (!self.authManager.isSAEnviroment && !UserManager.shared.isLogin) {
                self.currentSceneList = nil
                DispatchQueue.main.async {
                    self.tableView.mj_header?.endRefreshing()
                    self.getDataFromDB(area_id: self.currentArea.id, sa_token: self.currentArea.sa_user_token)
                    self.checkAuthState()
                    self.updateSegmentView()
                    self.tableView.reloadData()
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
                        
                        self.updateSegmentView()
                        self.checkAuthState()
                        self.tableView.reloadData()
                    }
                } failureCallback: {[weak self] (code, err) in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        self.updateSegmentView()
                        self.checkAuthState()
                        self.tableView.reloadData()
                    }
                }
            }
            
        }else{
            DispatchQueue.main.async {
                self.hideLoadingView()
                self.tableView.mj_header?.endRefreshing()
                self.checkAuthState()
                self.currentSceneList = nil
                self.tableView.reloadData()
            }
        }
    }
    
    /// 检查SA版本是否符合使用要求
    /// - Returns: 是否符合
    @MainActor
    func checkSAVersion() async -> Bool {
        guard authManager.isSAEnviroment || UserManager.shared.isLogin && currentArea.id != nil else {
            sceneHeader.titleLabel.text = currentArea.name
            return true
        }
        
        
        do {
            /// 获取SA支持的最低Api版本(走SA)
            let sa_status = try await AsyncApiService.getSAStatus()
            
            guard
                let sa_lowest_api_version = sa_status.min_version,
                let sa_current_api_version = sa_status.version
            else {
                return true
                
            }
            
            /// 比较app的api版本与当前SA支持的最低api版本是否符合要求
            if ZTVersionTool.compareVersionIsNewBigger(nowVersion: apiVersion, newVersion: sa_lowest_api_version) {
                /// 当前app的api版本比SA支持的要低
                SAUpdateAlert.show(message: "APP版本过低，无法访问当前家庭/公司的智慧中心 ，需要升级到最新版。".localizedString, rightBtnTitle: "现在升级".localizedString) { [weak self] in
                    guard let self = self else { return }
                    self.showSwitchAreaView(canDismiss: false)
                    
                } rightBtnCallback: {
                    //跳转去appstore
                    let str = "itms-apps://itunes.apple.com/app/id1591550488"
                    guard let url = URL(string: str) else { return }
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
                
                return false
            }
            
            /// 获取App支持的最低Api版本(走SC)
            let app_lowest_api_response = try await AsyncApiService.getAppSupportApiVersion(version: sa_current_api_version)
            
            guard let app_lowest_api_version = app_lowest_api_response.min_api_version else { return true }
            /// 比较当前sa支持的最低api版本是否符合要求
            if ZTVersionTool.compareVersionIsNewBigger(nowVersion: sa_lowest_api_version, newVersion: app_lowest_api_version) {
                /// APP版本低于当前家庭SA最低支持版本
                SAUpdateAlert.show(message: "当前家庭/公司的智慧中心软件版本过低，APP暂无法访问，你可以通过专业版访问，请尽快联系拥有者升级。".localizedString) { [weak self] in
                    guard let self = self else { return }
                    self.showSwitchAreaView(canDismiss: false)
                    
                } rightBtnCallback: { [weak self] in
                    guard let self = self else { return }
                    let vc = ProEditionViewController(linkEnum: .proEdition)
                    let nav = BaseProNavigationViewController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                }
                
                return false
            }
            
            return true
            
            
            
        } catch {
            return true
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
        
    /// 弹出选择家庭view
    /// - Parameter canDismiss: 是否可以点击关闭
    private func showSwitchAreaView(canDismiss: Bool = true) {
        switchAreaView.canDismiss = canDismiss
        SceneDelegate.shared.window?.addSubview(switchAreaView)
    }
        
    private func checkAuthState() {
        
        createSceneCell.reconnectBtn.stopAnimate()
        noAuthTipsView.refreshBtn.stopAnimate()
        noTokenTipsView.removeFromSuperview()
        sceneHeader.setBtns(btns: [.add, .history])
        sceneHeader.plusBtn.isUserInteractionEnabled = false
        sceneHeader.plusBtn.alpha = 0.5
        sceneHeader.historyBtn.isUserInteractionEnabled = false
        sceneHeader.historyBtn.alpha = 0.5

        if !authManager.isSAEnviroment && !UserManager.shared.isLogin && currentArea.id != nil {//与智慧中心断开链接

            scrollViewContainerView.addSubview(noAuthTipsView)
            if (currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count == 0 || currentSceneList == nil) {//无数据
                noAuthTipsView.snp.remakeConstraints {
                    $0.top.equalTo(sceneHeader.snp.bottom).offset(ZTScaleValue(10))
                    $0.left.equalToSuperview().offset(ZTScaleValue(15))
                    $0.right.equalToSuperview().offset(ZTScaleValue(-15))
                    $0.height.equalTo(40)
                }
                
                tableView.snp.remakeConstraints {
                    $0.top.equalTo(noAuthTipsView.snp.bottom)
                    $0.left.right.bottom.equalToSuperview()
                }
            }else{//有数据
                noAuthTipsView.snp.remakeConstraints {
                    $0.top.equalTo(segmentedView!.snp.bottom).offset(ZTScaleValue(10))
                    $0.left.equalToSuperview().offset(ZTScaleValue(15))
                    $0.right.equalToSuperview().offset(ZTScaleValue(-15))
                    $0.height.equalTo(40)
                }
                
                listContainerView?.snp.remakeConstraints {
                    $0.top.equalTo(noAuthTipsView.snp.bottom)
                    $0.height.equalTo(view.bounds.height - Screen.k_nav_height)
                    $0.left.right.bottom.equalToSuperview()
                }
            }

            
            createSceneCell.creatSceneCellType = .noAuth
            if !currentArea.is_bind_sa {
                createSceneCell.creatSceneBtn.isUserInteractionEnabled = false
                createSceneCell.creatSceneBtn.alpha = 0.5
            } else {
                createSceneCell.creatSceneBtn.isUserInteractionEnabled = true
                createSceneCell.creatSceneBtn.alpha = 1
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
                
                
                sceneHeader.historyBtn.isUserInteractionEnabled = true
                sceneHeader.historyBtn.alpha = 1
                
                
                
                createSceneCell.creatSceneCellType = .normal
                if currentArea.id == nil {
                    createSceneCell.creatSceneBtn.isUserInteractionEnabled = false
                    createSceneCell.creatSceneBtn.alpha = 0.5
                    sceneHeader.historyBtn.isUserInteractionEnabled = false
                    sceneHeader.historyBtn.alpha = 0.5
                } else {
                    createSceneCell.creatSceneBtn.isUserInteractionEnabled = true
                    createSceneCell.creatSceneBtn.alpha = 1
                }
                
                if !authManager.currentRolePermissions.add_scene {
                    sceneHeader.plusBtn.isUserInteractionEnabled = false
                    sceneHeader.plusBtn.alpha = 0.5
                } else {
                    sceneHeader.plusBtn.isUserInteractionEnabled = true
                    sceneHeader.plusBtn.alpha = 1
                }

            } else {
                scrollViewContainerView.addSubview(self.noTokenTipsView)
                self.noTokenEmptyView.isHidden = false
                if (currentSceneList?.auto_run.count == 0 && currentSceneList?.manual.count == 0 || currentSceneList == nil) {//无数据
                    self.noTokenTipsView.snp.remakeConstraints {
                        $0.top.equalTo(self.sceneHeader.snp.bottom).offset(ZTScaleValue(10))
                        $0.left.equalToSuperview().offset(ZTScaleValue(15))
                        $0.right.equalToSuperview().offset(ZTScaleValue(-15))
                        $0.height.equalTo(40)
                    }
                    
                    self.tableView.snp.remakeConstraints {
                        $0.top.equalTo(self.noTokenTipsView.snp.bottom)
                        $0.left.right.bottom.equalToSuperview()
                    }

                } else {
                    
                    self.noTokenTipsView.snp.remakeConstraints {
                        $0.top.equalTo(segmentedView!.snp.bottom).offset(ZTScaleValue(10))
                        $0.left.equalToSuperview().offset(ZTScaleValue(15))
                        $0.right.equalToSuperview().offset(ZTScaleValue(-15))
                        $0.height.equalTo(40)
                    }
                    
                    listContainerView?.snp.remakeConstraints {
                        $0.top.equalTo(noAuthTipsView.snp.bottom)
                        $0.height.equalTo(view.bounds.height - Screen.k_nav_height)
                        $0.left.right.bottom.equalToSuperview()
                    }

                }
            }
            

        }
        
//        self.hideLoadingView()

    }

}

extension SceneViewController{
    
    private func reloadArea(by area: Area) {
        switchAreaView.selectedArea = area
        sceneHeader.titleLabel.text = area.name
        self.showLoadingView()
        // 刷新场景列表
        reloadAll()
    }
    
    @objc private func reloadAll(){
        Task {
            await asyncRequest()
        }
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
        }else{
            return UITableViewCell()
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
        }

        
    }
    
}


extension SceneViewController: JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView?.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if subVCs.count > 0 {
            let vc = subVCs[index]
            vc.refreshDatasCallback = { [weak self] in
                Task { [weak self] in
                    guard let self = self else { return }
                    await self.asyncRequest()
                }
            }
            
            vc.endEditCallBack = { [weak self] in
                self?.isEditingCell = false
            }

            return vc
        }
        
        return SceneSubViewController()
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let dotDataSource = segmentedDataSource as? JXSegmentedDotDataSource {
            //update the datasource first
            dotDataSource.dotStates[index] = false
            //then reloadItem(at: index)
            segmentedView.reloadItem(at: index)
        }
    }
    
    func scrollViewClass(in listContainerView: JXSegmentedListContainerView) -> AnyClass {
        return CustomScrollView.self
    }

}

