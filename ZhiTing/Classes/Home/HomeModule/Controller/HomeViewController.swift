//
//  HomeViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/16.
//

import UIKit
import Combine
import JXSegmentedView

class HomeViewController: BaseViewController {
    /// 网络请求任务
    var task: Task<(), Never>?
    
    /// 上一次请求时的家庭id
    var lastAreaId: String?

    /// 顶部headerview
    private lazy var header = HomeHeader().then {
        $0.backgroundColor = .clear
    }
    
    /// 切换家庭view
    private lazy var switchAreaView =  SwitchAreaView()
    
    /// 当前家庭/公司
    private var currentArea: Area {
        return authManager.currentArea
    }
    
    /// 房间、部门列表
    private lazy var currentLocations = [Location]()
    
    /// 设备列表
    private lazy var devices = [Device]()
    
    /// 背景图
    private lazy var bgView = ImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = .assets(.home_bg)
    }
    /// 背景图遮罩
    private lazy var bgViewCover = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    /// 父ScrollView
    private lazy var scrollView = CustomScrollView(frame: CGRect(x: 0, y: Screen.statusBarHeight, width: Screen.screenWidth, height: Screen.screenHeight)).then {
        $0.showsVerticalScrollIndicator = false
        $0.isDirectionalLockEnabled = true
        $0.alwaysBounceVertical = false
        $0.direction = .vertical
        $0.delegate = self
    }

    private lazy var scrollViewContainer = UIView()
    
    /// 吸顶高度
    lazy var stickyOffset = Screen.k_nav_height + ZTScaleValue(10) - Screen.statusBarHeight
    /// 父vc是否可以滚动
    var superCanScroll = true
    
    private lazy var segmentContainerView = UIView()

    private var segmentedDataSource: JXSegmentedTitleDataSource?
    private var segmentedView: JXSegmentedView?
    private var listContainerView: JXSegmentedListContainerView?
    
    /// 列表模式按钮
    private lazy var listStyleBtn = Button().then {
        $0.setImage(.assets(.icon_list_style), for: .normal)
        $0.setImage(.assets(.icon_flow_style), for: .selected)
        $0.addTarget(self, action: #selector(styleBtnClick), for: .touchUpInside)
        $0.isSelected = appPreference.deviceListStyle == .list
    }
    
    /// 首页设置按钮
    private lazy var settingBtn = Button().then {
        $0.setImage(.assets(.icon_setting), for: .normal)
        $0.addTarget(self, action: #selector(settingBtnClick), for: .touchUpInside)
    }

    /// 设置浮窗
    private lazy var homeSettingAlert = HomeSettingAlert()

    /// 子控制器
    private lazy var subVCs = [HomeSubViewController]() {
        didSet {
            subVCs.forEach { vc in
                vc.superCanScrollCallback = { [weak self] superCanScroll in
                    guard let self = self else { return }
                    self.superCanScroll = superCanScroll
                }
            }
        }
    }
    
    /// SA断开连接view
    private lazy var noAuthTipsView = NoAuthTipsView().then {
        $0.refreshBtn.isHidden = false
    }
    
    /// 没有凭证view
    private lazy var noTokenTipsView = NoTokenTipsView().then {
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noTokenTapAction)))
        $0.isUserInteractionEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableSideSliding = true
        setupSegmentDataSource()
        if traitCollection.userInterfaceStyle == .dark {
            bgView.addSubview(bgViewCover)
            bgViewCover.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        task?.cancel()
        task = Task { [weak self] in
            guard let self = self else { return }
            if self.lastAreaId != currentArea.id {
                self.showLoadingView()
            }
            await self.asyncRequest()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            bgView.addSubview(bgViewCover)
            bgViewCover.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        } else {
            bgViewCover.removeFromSuperview()
        }
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(bgView)
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(header)
        scrollViewContainer.addSubview(segmentContainerView)
        segmentContainerView.addSubview(settingBtn)
        segmentContainerView.addSubview(listStyleBtn)
        #warning("暂时隐藏按钮")
        settingBtn.isHidden = true
        listStyleBtn.isHidden = true
        
        /// homeSettingAlert callbacks
        homeSettingAlert.items = [.roomManage, .deviceSorting, .hideOfflineDevice, .commonDeviceSetting]

        homeSettingAlert.selectCallback = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case .roomManage: /// 房间管理
                switch self.currentArea.areaType {
                case .family:
                    let vc = RoomsManagementViewController()
                    vc.area = self.currentArea
                    self.navigationController?.pushViewController(vc, animated: true)
                case .company:
                    let vc = DepartmentsManagementViewController()
                    vc.area = self.currentArea
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .deviceSorting: /// 设备排序
                let vc = DeviceSortingViewController()
                vc.area = self.currentArea
                if let idx = self.segmentedView?.selectedIndex {
                    let location = self.currentLocations[idx]
                    vc.location = location
                    vc.devices = location.id == -1 ? self.devices : self.devices.filter({ $0.location_id == location.id })
                }
                self.navigationController?.pushViewController(vc, animated: true)
            case .showAllDevice: /// 显示所有设备
                break
            case .hideOfflineDevice: /// 隐藏离线设备
                break
            case .commonDeviceSetting: /// 常用设备设置
                let vc = CommonlyDeviceSettingViewController()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        /// noAuthTipsView callbacks
        noAuthTipsView.labelCallback = { [weak self] in
            guard let self = self else { return }
            let vc = WKWebViewController(linkEnum: .offlineHelp)
            vc.webViewTitle = "离线帮助".localizedString
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        noAuthTipsView.refreshBtn.clickCallBack = { [weak self] in
            self?.noAuthTipsView.refreshBtn.startAnimate()
            Task { [weak self] in
                guard let self = self else { return }
                await self.asyncRequest()
            }
        }
        
        /// switchAreaView callbacks
        switchAreaView.selectCallback = { [weak self] area in
            guard let self = self else { return }
            self.showLoadingView()
            self.authManager.currentArea = area
        }
        
        /// header callbacks
        header.switchAreaCallButtonCallback = { [weak self] in
            guard let self = self else { return }
            self.showSwitchAreaView()
            
        }
        
        header.plusBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
//
            if !self.authManager.currentRolePermissions.add_device && !UserManager.shared.isLogin && !self.currentArea.sa_user_token.contains("unbind") {
                self.showToast(string: "没有权限".localizedString)
                return
            }

            let vc = DiscoverViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
                        
        }
        
        header.scanBtn.clickCallBack = { [weak self] _ in
            let vc = ScanQRCodeViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    
    override func setupConstraints() {
        bgView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Screen.tabbarHeight + ZTScaleValue(3.0))
        }
        
        scrollViewContainer.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth)
            
        }

        header.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview().offset(-Screen.statusBarHeight)
            $0.height.equalTo(Screen.k_nav_height + ZTScaleValue(10))
        }
        
        segmentContainerView.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(50.0))
        }
        
        settingBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(16))
            $0.right.equalToSuperview().offset(-19)
        }
        
        listStyleBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(16))
            $0.right.equalTo(settingBtn.snp.left).offset(-15)
        }
        
    }
    
    override func setupSubscriptions() {
        networkStateManager.networkStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                if state == .reachable {
                    self.authManager.updateCurrentArea()
                    
                }
            }
            .store(in: &cancellables)
        
        authManager.currentAreaPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (area) in
                guard let self = self else { return }
                if self.view.window != nil && self.isViewLoaded { // 当前页面正在最上面显示才刷新
                    self.task?.cancel()
                    self.task = Task { [weak self] in
                        guard let self = self else { return }
                        await self.asyncRequest()
                    }
                }
            }
            .store(in: &cancellables)
        
        authManager.roleRefreshPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.checkAuthState()
            }
            .store(in: &cancellables)
        
    }
    
    
    //点击查看允许找回权限方法
    @objc private func noTokenTapAction() {
        let vc = GuideTokenViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    /// 弹出选择家庭view
    /// - Parameter canDismiss: 是否可以点击关闭
    private func showSwitchAreaView(canDismiss: Bool = true) {
        switchAreaView.canDismiss = canDismiss
        SceneDelegate.shared.window?.addSubview(switchAreaView)
        
    }
    
    /// 列表展示模式切换
    @objc private func styleBtnClick() {
        if appPreference.deviceListStyle == .list {
            appPreference.deviceListStyle = .flow
            listStyleBtn.isSelected = false
        } else {
            appPreference.deviceListStyle = .list
            listStyleBtn.isSelected = true
        }
    }
    
    /// 弹出设置浮窗
    @objc private func settingBtnClick() {
        homeSettingAlert.setContainerTopOffset(Screen.k_nav_height + ZTScaleValue(50) - scrollView.contentOffset.y)
        SceneDelegate.shared.window?.addSubview(homeSettingAlert)
    }
    
}

extension HomeViewController {
    /// 初始化SegmentView
    private func setupSegmentDataSource() {
        let titles = ["全部".localizedString]
        let subVc = HomeSubViewController()
        subVc.refreshLocationsCallback = { [weak self] in
            guard let self = self else { return }
            self.task?.cancel()
            self.task = Task { [weak self] in
                guard let self = self else { return }
                await self.asyncRequest()
            }
        }
        subVCs = [subVc]

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
        
        segmentContainerView.addSubview(segmentedView!)
        
        scrollViewContainer.addSubview(listContainerView!)
        
        #warning("暂时隐藏按钮")
        segmentedView?.snp.makeConstraints {
            $0.top.bottom.left.equalToSuperview()
//            $0.right.equalTo(listStyleBtn.snp.left).offset(-13)
            $0.right.equalToSuperview()
        }
        
        listContainerView?.snp.makeConstraints {
            $0.top.equalTo(segmentContainerView.snp.bottom)
            $0.height.equalTo(view.bounds.height - Screen.k_nav_height)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
}

extension HomeViewController {
    private func checkAuthState() {
        if !authManager.isSAEnviroment && !UserManager.shared.isLogin && currentArea.id != nil || (UserManager.shared.isLogin && currentArea.needRebindCloud && !authManager.isSAEnviroment) {
            view.addSubview(noAuthTipsView)
            noAuthTipsView.snp.makeConstraints {
                $0.top.equalTo(segmentContainerView.snp.bottom)
                $0.left.equalToSuperview().offset(ZTScaleValue(15.0))
                $0.right.equalToSuperview().offset(-ZTScaleValue(15.0))
                $0.height.equalTo(ZTScaleValue(40.0))
            }
            
            listContainerView?.snp.remakeConstraints {
                $0.top.equalTo(noAuthTipsView.snp.bottom).offset(ZTScaleValue(15.0))
                $0.left.right.bottom.equalToSuperview()
                $0.height.equalTo(view.bounds.height - Screen.k_nav_height)
            }
            
            
            
        } else {
            if currentArea.isAllowedGetToken {
                noTokenTipsView.removeFromSuperview()
                noAuthTipsView.removeFromSuperview()
                
                listContainerView?.snp.remakeConstraints {
                    $0.top.equalTo(segmentContainerView.snp.bottom)
                    $0.height.equalTo(view.bounds.height - Screen.k_nav_height)
                    $0.left.right.bottom.equalToSuperview()
                }
            }else{
                self.view.addSubview(self.noTokenTipsView)
                self.noTokenTipsView.snp.makeConstraints {
                    $0.top.equalTo(self.segmentContainerView.snp.bottom)
                    $0.left.equalToSuperview().offset(ZTScaleValue(15.0))
                    $0.right.equalToSuperview().offset(-ZTScaleValue(15.0))
                    $0.height.equalTo(ZTScaleValue(40.0))
                }
                
                self.listContainerView?.snp.remakeConstraints {
                    $0.top.equalTo(self.noTokenTipsView.snp.bottom).offset(ZTScaleValue(15.0))
                    $0.height.equalTo(view.bounds.height - Screen.k_nav_height)
                    $0.left.right.bottom.equalToSuperview()
                }
            }
            
            
        }
        
        if currentArea.sa_user_token.contains("unbind") {
            header.setBtns(btns: [.add, .scan])
        } else {
            if !authManager.currentRolePermissions.add_device {
                header.setBtns(btns: [.scan])
                
            } else {
                header.setBtns(btns: [.add, .scan])
            }
        }
        
    }
}

// MARK: - JXSegmentedViewDelegate
extension HomeViewController: JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView?.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {

        let vc = subVCs[index]
        return vc
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

// MARK: - ScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate {
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
                superCanScroll = false
                subVCs.forEach { $0.canScroll = true }
            } else if scrollView.contentOffset.y <= 0 {
                scrollView.contentOffset.y = 0
            }
            
        }
    }

    
}

// MARK: - Network
extension HomeViewController {
    
    @MainActor
    func asyncRequest() async {
        /// 初始化状态
        noTokenTipsView.removeFromSuperview()
        noAuthTipsView.removeFromSuperview()
        /// 获取家庭公司列表
        await getAreaList()
        /// 获取家庭公司详情
        await getAreaDetail()
        
        /// 与上次请求时的家庭不同时才请求(减少非必要请求)
        if lastAreaId != nil && lastAreaId != currentArea.id {
            /// 检查SA版本
            let isSupportSA = await checkSAVersion()
            listContainerView?.isHidden = !isSupportSA
            segmentedView?.isHidden = !isSupportSA
            if !isSupportSA {
                self.hideLoadingView()
                return
            }
            /// 将本地的用户昵称头像同步到SA
            UserManager.shared.updateCurrentSAUser()
        }
        lastAreaId = currentArea.id
        
        /// 获取家庭公司的房间部门
        await getLocations()
        /// 获取设备列表
        await getDeviceList()

        /// 数据刷新
        self.checkAuthState()
        self.switchAreaView.tableView.reloadData()
        
        
        /// 子控制器设置
        if subVCs.count != currentLocations.count { /// 房间部门数量不一致时 全部刷新
            subVCs.removeAll()
            for location in currentLocations {
                let vc = HomeSubViewController()
                vc.identifier = "\(authManager.currentArea.id ?? "")-\(authManager.currentArea.sa_user_token)-\(location.id)"

                vc.refreshLocationsCallback = { [weak self] in
                    guard let self = self else { return }
                    self.task?.cancel()
                    self.task = Task { [weak self] in
                        guard let self = self else { return }
                        await self.asyncRequest()
                    }
                }
                
                if currentLocations.count > 0 {
                    if currentArea.areaType == .family {
                        vc.location_id = location.id
                        vc.devices = vc.location_id == -1 ? devices : devices.filter({ $0.location_id == location.id })
                    } else {
                        vc.department_id = location.id
                        vc.devices = vc.location_id == -1 ? devices : devices.filter({ $0.department_id == location.id })
                    }
                }
                
                subVCs.append(vc)
            }
        } else { /// 房间部门数量一致时根据情况更新子vc
            for (index, location) in currentLocations.enumerated() {
                let vc = HomeSubViewController()
                vc.identifier = "\(authManager.currentArea.id ?? "")-\(authManager.currentArea.sa_user_token)-\(location.id)"

                vc.refreshLocationsCallback = { [weak self] in
                    guard let self = self else { return }
                    self.task?.cancel()
                    self.task = Task { [weak self] in
                        guard let self = self else { return }
                        await self.asyncRequest()
                    }
                }
                
                if currentLocations.count > 0 {
                    if currentArea.areaType == .family {
                        vc.location_id = location.id
                        vc.devices = vc.location_id == -1 ? devices : devices.filter({ $0.location_id == location.id })
                    } else {
                        vc.department_id = location.id
                        vc.devices = vc.location_id == -1 ? devices : devices.filter({ $0.department_id == location.id })
                    }
                }
                
                if vc.identifier != subVCs[index].identifier { /// 不是同一个控制器时更新子控制器
                    subVCs[index] = vc
                }
                    
                if currentArea.areaType == .family {
                    subVCs[index].devices = subVCs[index].location_id == -1 ? devices : devices.filter({ $0.location_id == location.id })
                } else {
                    subVCs[index].devices = subVCs[index].location_id == -1 ? devices : devices.filter({ $0.department_id == location.id })
                }
                
                subVCs[index].requestNetwork()
                
            }
        }
        
        
        

        /// 刷新子控制器
        self.segmentedDataSource?.reloadData(selectedIndex: self.segmentedView?.selectedIndex ?? 0)
        self.segmentedView?.reloadData()
        self.listContainerView?.reloadData()
        
        self.hideLoadingView()
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
            header.titleLabel.text = currentArea.name
            return
        }
        
        var errorCode: Int?
        do {
            let areaResponse = try await AsyncApiService.areaDetail(area: currentArea)
            currentArea.name = areaResponse.name
            header.titleLabel.text = areaResponse.name
            switchAreaView.selectedArea?.name = areaResponse.name
            let cache = currentArea.toAreaCache()
            AreaCache.cacheArea(areaCache: cache)
        } catch {
            header.titleLabel.text = switchAreaView.selectedArea?.name
            guard let error = error as? AsyncApiError else { return }
            errorCode = error.code
        }
        
        if errorCode == 5012 || errorCode == 5027 { /// token失效(用户被删除)
            do {
                let response = try await AsyncApiService.getSAToken(area: currentArea)
                currentArea.isAllowedGetToken = true
                noTokenTipsView.removeFromSuperview()
                listContainerView?.snp.remakeConstraints {
                    $0.top.equalTo(segmentContainerView.snp.bottom)
                    $0.height.equalTo(view.bounds.height - Screen.k_nav_height)
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
                        view.addSubview(noTokenTipsView)
                        noTokenTipsView.snp.makeConstraints {
                            $0.top.equalTo(segmentContainerView.snp.bottom)
                            $0.left.equalToSuperview().offset(ZTScaleValue(15.0))
                            $0.right.equalToSuperview().offset(-ZTScaleValue(15.0))
                            $0.height.equalTo(ZTScaleValue(40.0))
                        }
                        
                        listContainerView?.snp.remakeConstraints {
                            $0.top.equalTo(noTokenTipsView.snp.bottom).offset(ZTScaleValue(15.0))
                            $0.height.equalTo(view.bounds.height - Screen.k_nav_height)
                            $0.left.right.bottom.equalToSuperview()
                        }
                        
                        //页面刷新
                        listContainerView?.reloadData()
                        
                        
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
    
    /// 获取房间/部门列表
    @MainActor
    func getLocations() async {
        if (!self.authManager.isSAEnviroment && !UserManager.shared.isLogin) { // 未登录且不在SA环境
            var locations = LocationCache.areaLocationList(area_id: currentArea.id, sa_token: currentArea.sa_user_token)
            let all = Location()
            all.id = -1
            all.sort = -1
            all.name = "全部".localizedString
            all.area_id = self.currentArea.id
            all.sa_user_token = self.currentArea.sa_user_token
            locations.insert(all, at: 0)
            let titles = locations.sorted(by: {$0.sort < $1.sort}).map(\.name)
            currentLocations = locations.sorted(by: {$0.sort < $1.sort})
            segmentedDataSource?.titles = titles
        } else {
            var responseLocations: [Location]?
            if currentArea.areaType == .family {
                responseLocations = try? await AsyncApiService.locationList(area: currentArea)

            } else {
                responseLocations = try? await AsyncApiService.departmentList(area: currentArea)
            }
            
            if let responseLocations = responseLocations {
                listContainerView?.snp.remakeConstraints {
                    $0.top.equalTo(segmentContainerView.snp.bottom)
                    $0.left.right.bottom.equalToSuperview()
                    $0.height.equalTo(view.bounds.height - Screen.k_nav_height)
                }
                
                responseLocations.forEach {
                    $0.area_id = currentArea.id
                    $0.sa_user_token = currentArea.sa_user_token
                }
                LocationCache.cacheLocations(locations: responseLocations, token: currentArea.sa_user_token)
                
                var locations = LocationCache.areaLocationList(area_id: currentArea.id, sa_token: currentArea.sa_user_token)
                
                let all = Location()
                all.name = "全部".localizedString
                all.id = -1
                all.sort = -1
                all.sa_user_token = self.currentArea.sa_user_token
                locations.insert(all, at: 0)
                
                let titles = locations.sorted(by: {$0.sort < $1.sort}).map(\.name)
                self.currentLocations = locations.sorted(by: {$0.sort < $1.sort})
                self.segmentedDataSource?.titles = titles
            } else {
                var locations = LocationCache.areaLocationList(area_id: currentArea.id, sa_token: currentArea.sa_user_token)
                let all = Location()
                all.name = "全部".localizedString
                all.id = -1
                all.sa_user_token = self.currentArea.sa_user_token
                locations.insert(all, at: 0)
                let titles = locations.sorted(by: {$0.sort < $1.sort}).map(\.name)
                currentLocations = locations
                segmentedDataSource?.titles = titles
            }

        }

    }
    
    /// 获取设备列表
    @MainActor
    func getDeviceList() async {
        do {
            
            if self.devices.first?.area_id != currentArea.id || currentArea.id == nil { /// 如果内存里当前设备列表缓存与当前家庭不一致时 清空设备缓存
                self.devices.removeAll()
            } else {
                /// 如果同一个家庭 但是不在SA环境且未登录时 清空设备之前的在线状态信息
                if !authManager.isSAEnviroment && !UserManager.shared.isLogin {
                    self.devices.forEach { $0.device_status = nil }
                }
                
            }
            
            /// 本地家庭 或不在SA环境且未登录时 获取缓存
            if currentArea.id == nil || (!authManager.isSAEnviroment && !UserManager.shared.isLogin) {
                self.devices = DeviceCache.getAreaHomeDevices(area_id: currentArea.id, sa_token: currentArea.sa_user_token)
                if !currentArea.isAllowedGetToken {
                    self.devices.removeAll()
                }

                return
            }

            let devices = try await AsyncApiService.deviceList(area: currentArea)
            devices.forEach { device in
                device.area_id = currentArea.id
                
                if let existDevice = self.devices.first(where: { $0.iid == device.iid }) {
                    device.device_status = existDevice.device_status
                }
                
                if !device.is_sa {
                    let domain = device.plugin_id
                    self.websocket.executeOperation(operation: .getDeviceAttributes(domain: domain, iid: device.iid))
                }
            }
            
            DeviceCache.cacheHomeDevices(homeDevices: devices, area_id: currentArea.id, sa_token: currentArea.sa_user_token)
            
            self.devices = devices
           
            
        } catch {
            if devices.count == 0 {
                devices = DeviceCache.getAreaHomeDevices(area_id: currentArea.id, sa_token: currentArea.sa_user_token)
                if !currentArea.isAllowedGetToken {
                    devices.removeAll()
                }
            }
            
            
        }
        
    }

    
    /// 检查SA版本是否符合使用要求
    /// - Returns: 是否符合
    @MainActor
    func checkSAVersion() async -> Bool {
        guard authManager.isSAEnviroment || UserManager.shared.isLogin && currentArea.id != nil else {
            header.titleLabel.text = currentArea.name
            return true
        }
        
        
        do {
            /// 获取SA支持的最低Api版本(走SA)
            let sa_status = try await AsyncApiService.getSAStatus()
            guard let sa_current_api_version = sa_status.version else {
                return true
            }
            
            let saSupportVersionResponse = try await AsyncApiService.getSASupportApiVersion(version: sa_current_api_version)
            guard let sa_lowest_api_version = saSupportVersionResponse.min_api_version else {
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
            
            guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                return true
            }
            /// 获取App支持的最低Api版本(走SC)
            let app_lowest_api_response = try await AsyncApiService.getAppSupportApiVersion(version: appVersion)
            
            guard let app_lowest_api_version = app_lowest_api_response.min_api_version else {
                return true
            }
            /// 比较当前sa支持的最低api版本是否符合要求
            if ZTVersionTool.compareVersionIsNewBigger(nowVersion: sa_current_api_version, newVersion: app_lowest_api_version) {
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
    
    
    
    
    
    

}
