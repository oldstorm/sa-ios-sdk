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
    
    private lazy var header = HomeHeader().then {
        $0.backgroundColor = .clear
    }
    
    
    private var switchAreaView =  SwtichAreaView()
    
    private var currentArea: Area {
        return authManager.currentArea
    }
    private var currentLocations = [Location]()
    
    private lazy var bgView = ImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = .assets(.home_bg)
    }
    
    private var segmentedDataSource: JXSegmentedTitleDataSource?
    private var segmentedView: JXSegmentedView?
    private var listContainerView: JXSegmentedListContainerView?
    
    private lazy var noAuthTipsView = NoAuthTipsView().then {
        $0.refreshBtn.isHidden = false
    }
    
    private lazy var noTokenTipsView = NoTokenTipsView().then {
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noTokenTapAction)))
        $0.isUserInteractionEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableSideSliding = true
        setupSegmentDataSource()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestInfoDatas()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(bgView)
        view.addSubview(header)
        
        switchAreaView.selectCallback = { [weak self] area in
            guard let self = self else { return }
            self.authManager.currentArea = area
        }
        
        header.switchAreaCallButtonCallback = { [weak self] in
            guard let self = self else { return }
            SceneDelegate.shared.window?.addSubview(self.switchAreaView)
        }
        
        header.plusBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            
            if !self.authManager.currentRolePermissions.add_device && !self.authManager.isLogin && !self.currentArea.sa_user_token.contains("unbind") {
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
        
        noAuthTipsView.refreshBtn.clickCallBack = { [weak self] in
            self?.noAuthTipsView.refreshBtn.startAnimate()
            self?.requestInfoDatas()
        }
    }
    
    
    override func setupConstraints() {
        bgView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Screen.tabbarHeight + ZTScaleValue(3.0))
        }
        
        header.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(Screen.k_nav_height + ZTScaleValue(10))
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
                self.requestInfoDatas()
                
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
    
    
}

extension HomeViewController {
    private func setupSegmentDataSource() {
        let titles = ["全部"]
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
        
        view.addSubview(segmentedView!)
        view.addSubview(listContainerView!)
        
        segmentedView?.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(50.0))
        }
        
        listContainerView?.snp.makeConstraints {
            $0.top.equalTo(segmentedView!.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
}

extension HomeViewController {
    private func checkAuthState() {
        if !authManager.isSAEnviroment && !authManager.isLogin && currentArea.id != nil {
            view.addSubview(noAuthTipsView)
            noAuthTipsView.snp.makeConstraints {
                $0.top.equalTo(segmentedView!.snp.bottom)
                $0.left.equalToSuperview().offset(ZTScaleValue(15.0))
                $0.right.equalToSuperview().offset(-ZTScaleValue(15.0))
                $0.height.equalTo(ZTScaleValue(40.0))
            }
            
            listContainerView?.snp.remakeConstraints {
                $0.top.equalTo(noAuthTipsView.snp.bottom).offset(ZTScaleValue(15.0))
                $0.left.right.bottom.equalToSuperview()
            }
            
            
            
        } else {
            if currentArea.isAllowedGetToken {
                noTokenTipsView.removeFromSuperview()
                noAuthTipsView.removeFromSuperview()
                
                listContainerView?.snp.remakeConstraints {
                    $0.top.equalTo(segmentedView!.snp.bottom)
                    $0.left.right.bottom.equalToSuperview()
                }
            }else{
                self.view.addSubview(self.noTokenTipsView)
                self.noTokenTipsView.snp.makeConstraints {
                    $0.top.equalTo(self.segmentedView!.snp.bottom)
                    $0.left.equalToSuperview().offset(ZTScaleValue(15.0))
                    $0.right.equalToSuperview().offset(-ZTScaleValue(15.0))
                    $0.height.equalTo(ZTScaleValue(40.0))
                }
                
                self.listContainerView?.snp.remakeConstraints {
                    $0.top.equalTo(self.noTokenTipsView.snp.bottom).offset(ZTScaleValue(15.0))
                    $0.left.right.bottom.equalToSuperview()
                }
            }
            
            
        }
        
        if currentArea.sa_user_token.contains("unbind") || currentArea.sa_user_token == "" {
            if currentArea.cloud_user_id > 0 {
                if authManager.isLogin {
                    header.setBtns(btns: [.add, .scan])
                } else {
                    header.setBtns(btns: [.add, .scan])
                }
            } else {
                header.setBtns(btns: [.add, .scan])
            }
        } else {
            if !authManager.currentRolePermissions.add_device {
                header.setBtns(btns: [.scan])
                
            } else {
                header.setBtns(btns: [.add, .scan])
            }
        }
        
    }
}

extension HomeViewController: JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView?.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let vc = HomeSubViewController()
        vc.refreshLocationsCallback = { [weak self] in
            self?.requestInfoDatas()
            //            self?.requestLocations()
        }
        if currentLocations.count > 0 {
            vc.location_id = currentLocations[index].id
        }
        
        
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
}


extension HomeViewController {
    
    private func requestInfoDatas() {
        self.showLoadingView()
        //初始化状态
        noTokenTipsView.removeFromSuperview()
        noAuthTipsView.removeFromSuperview()
        
        //数据获取队列
        let semaphore = DispatchSemaphore(value: 1)
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            // MARK: - 获取家庭列表信息
            semaphore.wait()
            if !self.authManager.isLogin { //用户未登陆
                semaphore.signal()
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
                }
                
            } else { //用户已登陆，请求数据
                self.switchAreaView.selectedArea = self.currentArea
                ApiServiceManager.shared.areaList { [weak self] response in
                    guard let self = self else { return }
                    semaphore.signal()
                    DispatchQueue.main.async {
                        response.areas.forEach { $0.cloud_user_id = self.authManager.currentUser.user_id }
                        AreaCache.cacheAreas(areas: response.areas)
                        let areas = AreaCache.areaList()
                        
                        /// 如果在对应的局域网环境下,将局域网内绑定过SA但未绑定到云端的家庭绑定到云端
                        if areas.filter({ $0.needRebindCloud && $0.bssid == NetworkStateManager.shared.getWifiBSSID() && $0.bssid != nil }).count > 0 {
                            AuthManager.shared.syncLocalAreasToCloud { [weak self] in
                                guard let self = self else { return }
                                self.switchAreaView.areas = AreaCache.areaList()
                            }
                        } else {
                            self.switchAreaView.areas = areas
                        }
                    }
                    
                } failureCallback: { [weak self] code, err in
                    guard let self = self else { return }
                    semaphore.signal()
                    DispatchQueue.main.async {
                        let areas = AreaCache.areaList()
                        self.switchAreaView.areas = areas
                        self.switchAreaView.selectedArea = self.currentArea
                    }
                    
                    
                }
                
            }
            
            
            // MARK: - 请求房间详情信息
            semaphore.wait()
            if (!self.authManager.isSAEnviroment && !self.authManager.isLogin) {
                semaphore.signal()
                
                DispatchQueue.main.async {
                    var locations = LocationCache.areaLocationList(area_id: self.currentArea.id, sa_token: self.currentArea.sa_user_token)
                    let all = Location()
                    all.id = -1
                    all.sort = -1
                    all.name = "全部"
                    all.area_id = self.currentArea.id
                    all.sa_user_token = self.currentArea.sa_user_token
                    locations.insert(all, at: 0)
                    
                    let titles = locations.sorted(by: {$0.sort < $1.sort}).map(\.name)
                    self.currentLocations = locations.sorted(by: {$0.sort < $1.sort})
                    self.segmentedDataSource?.titles = titles
                    
                    
                }
                
            } else {
                ApiServiceManager.shared.areaLocationsList(area: self.currentArea) { [weak self] (response) in
                    guard let self = self else { return }
                    semaphore.signal()
                    DispatchQueue.main.async {
                        self.listContainerView?.snp.remakeConstraints {
                            $0.top.equalTo(self.segmentedView!.snp.bottom)
                            $0.left.right.bottom.equalToSuperview()
                        }
                        
                        response.locations.forEach {
                            $0.area_id = self.currentArea.id
                            $0.sa_user_token = self.currentArea.sa_user_token
                        }
                        LocationCache.cacheLocations(locations: response.locations, token: self.currentArea.sa_user_token)
                        
                        var locations = LocationCache.areaLocationList(area_id: self.currentArea.id, sa_token: self.currentArea.sa_user_token)
                        
                        let all = Location()
                        all.name = "全部"
                        all.id = -1
                        all.sort = -1
                        all.sa_user_token = self.currentArea.sa_user_token
                        locations.insert(all, at: 0)
                        
                        let titles = locations.sorted(by: {$0.sort < $1.sort}).map(\.name)
                        self.currentLocations = locations.sorted(by: {$0.sort < $1.sort})
                        self.segmentedDataSource?.titles = titles
                        
                        
                        
                    }
                    
                }  failureCallback: { [weak self] (code, err) in
                    guard let self = self else { return }
                    semaphore.signal()
                    DispatchQueue.main.async {
                        var locations = LocationCache.areaLocationList(area_id: self.currentArea.id, sa_token: self.currentArea.sa_user_token)
                        let all = Location()
                        all.name = "全部"
                        all.id = -1
                        all.sa_user_token = self.currentArea.sa_user_token
                        locations.insert(all, at: 0)
                        
                        let titles = locations.map(\.name)
                        
                        if locations.isDifferentFrom(another: self.currentLocations) {
                            self.currentLocations = locations
                            self.segmentedDataSource?.titles = titles
                            
                        }
                    }
                }
                
            }
            
            // MARK: - 请求家庭详情信息
            semaphore.wait()
            if self.authManager.isSAEnviroment || self.authManager.isLogin {
                
                ApiServiceManager.shared.areaDetail(area: self.currentArea) { [weak self] response in
                    guard let self = self else { return }
                    semaphore.signal()
                    
                    DispatchQueue.main.async {
                        self.currentArea.name = response.name
                        self.header.titleLabel.text = response.name
                        self.switchAreaView.selectedArea.name = response.name
                        let cache = self.currentArea.toAreaCache()
                        AreaCache.cacheArea(areaCache: cache)
                    }
                    
                    
                } failureCallback: { [weak self] (code, err) in
                    guard let self = self else { return }
                    semaphore.signal()
                    
                    DispatchQueue.main.async {
                        self.header.titleLabel.text = self.switchAreaView.selectedArea.name
                    }
                    
                    if code == 5012 { //token失效(用户被删除)
                        //获取SA凭证
                        ApiServiceManager.shared.getSAToken(area: self.currentArea) { [weak self] response in
                            guard let self = self else { return }
                            //凭证获取成功
                            DispatchQueue.main.async {
                                self.currentArea.isAllowedGetToken = true
                                self.noTokenTipsView.removeFromSuperview()
                                self.listContainerView?.snp.remakeConstraints {
                                    $0.top.equalTo(self.segmentedView!.snp.bottom)
                                    $0.left.right.bottom.equalToSuperview()
                                }
                                
                                //移除旧数据库
                                AreaCache.deleteArea(id: self.currentArea.id, sa_token: self.currentArea.sa_user_token)
                                self.switchAreaView.areas.removeAll(where: { $0.sa_user_token == self.currentArea.sa_user_token })
                                //更新数据库token
                                self.currentArea.sa_user_token = response.sa_token
                                AreaCache.cacheArea(areaCache: self.currentArea.toAreaCache())
                                /// 再次请求. 页面刷新
                                AuthManager.shared.updateCurrentArea()
                            }
                            
                            
                        } failureCallback: { [weak self] code, error in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                if code == 2011 || code == 2010 {
                                    //凭证获取失败，2010 登录的用户和找回token的用户不是同一个；2011 不允许找回凭证
                                    self.currentArea.isAllowedGetToken = false
                                    self.view.addSubview(self.noTokenTipsView)
                                    self.noTokenTipsView.snp.makeConstraints {
                                        $0.top.equalTo(self.segmentedView!.snp.bottom)
                                        $0.left.equalToSuperview().offset(ZTScaleValue(15.0))
                                        $0.right.equalToSuperview().offset(-ZTScaleValue(15.0))
                                        $0.height.equalTo(ZTScaleValue(40.0))
                                    }
                                    
                                    self.listContainerView?.snp.remakeConstraints {
                                        $0.top.equalTo(self.noTokenTipsView.snp.bottom).offset(ZTScaleValue(15.0))
                                        $0.left.right.bottom.equalToSuperview()
                                    }
                                    
                                    //页面刷新
                                    DispatchQueue.main.async {
                                        self.listContainerView?.reloadData()
                                    }
                                    
                                } else if code == 3002 {
                                    //状态码3002，提示被管理员移除家庭
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
                                } else if code == 2008 || code == 2009 { /// 在SA环境下且未登录, 用户被移除家庭
                                    #warning("TODO: 暂未有这种情况的说明")
                                    DispatchQueue.main.async {
                                        self.showToast(string: "家庭可能被移除或token失效,请先登录")
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                
            } else {
                semaphore.signal()
                DispatchQueue.main.async {
                    self.header.titleLabel.text = self.currentArea.name
                }
                
            }
            
            
            //页面刷新
            DispatchQueue.main.async {
                self.hideLoadingView()
                self.checkAuthState()
                self.switchAreaView.tableView.reloadData()
                self.segmentedDataSource?.reloadData(selectedIndex: self.segmentedView?.selectedIndex ?? 0)
                self.segmentedView?.reloadData()
                self.listContainerView?.reloadData()
                
            }
        }
    }
    
    
    
}

