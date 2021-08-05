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
    var needSwitchToCurrentSAArea = true

    private lazy var header = HomeHeader().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var loadingView = LodingView().then {
        $0.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight - Screen.k_nav_height)
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
        requestAreas()
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
            vc.area = self.currentArea
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
            self?.requestAreas()
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
            .sink { [weak self] state in
                guard let self = self else { return }
                if state == .reachable {
                    DispatchQueue.main.async {
                        self.authManager.updateCurrentArea()
                    }
                    
                }
            }
            .store(in: &cancellables)
        
        authManager.currentAreaPublisher
            .sink { [weak self] (area) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.requestAreas()
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
    
    private func reloadLocations(by area: Area) {
        switchAreaView.selectedArea = area
//        authManager.currentArea = area
        header.titleLabel.text = area.name
        
        requestLocations()
        
       
    }
    
    private func showLodingView() {
        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        loadingView.show()
    }
    
     private func hideLodingView(){
         loadingView.hide()
         loadingView.removeFromSuperview()
     }

    
    
}

extension HomeViewController {
    private func checkAuthState() {
        if !authManager.isSAEnviroment && !authManager.isLogin && currentArea.is_bind_sa {
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
            noAuthTipsView.removeFromSuperview()
            listContainerView?.snp.remakeConstraints {
                $0.top.equalTo(segmentedView!.snp.bottom)
                $0.left.right.bottom.equalToSuperview()
            }
      
        }
        
        if currentArea.sa_user_token.contains("unbind") {
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
            self?.requestLocations()
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
    private func requestAreas() {
        if !authManager.isLogin {
            let areas = AreaCache.areaList()
            self.switchAreaView.areas = areas
            self.switchAreaView.selectedArea = currentArea
            self.noAuthTipsView.refreshBtn.stopAnimate()
            requestLocations()
            requestAreaDetail()
            return
        } else {
            self.switchAreaView.selectedArea = currentArea
            ApiServiceManager.shared.areaList { [weak self] response in
                guard let self = self else { return }
                self.noAuthTipsView.refreshBtn.stopAnimate()
                response.areas.forEach { $0.cloud_user_id = self.authManager.currentUser.user_id }
                AreaCache.cacheAreas(areas: response.areas)
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
                self.requestLocations()
                self.requestAreaDetail()
                
            } failureCallback: { [weak self] code, err in
                guard let self = self else { return }
                print(err)
                self.noAuthTipsView.refreshBtn.stopAnimate()
                if self.switchAreaView.areas.isEmpty {
                    let areas = AreaCache.areaList()
                    self.switchAreaView.areas = areas
                    self.switchAreaView.selectedArea = self.currentArea
                    self.noAuthTipsView.refreshBtn.stopAnimate()
                    self.requestLocations()
                    self.requestAreaDetail()
                }
                
            }

        }

    }

    private func requestAreaDetail() {
        guard (authManager.isSAEnviroment || authManager.isLogin) && currentArea.sa_lan_address != nil else {
            self.header.titleLabel.text = currentArea.name
            return
            
        }
        
        ApiServiceManager.shared.areaDetail(area: currentArea) { [weak self] response in
            guard let self = self else { return }
            self.currentArea.name = response.name
            self.header.titleLabel.text = response.name
            self.switchAreaView.selectedArea.name = response.name
            self.switchAreaView.tableView.reloadData()
            let cache = self.currentArea.toAreaCache()
            AreaCache.cacheArea(areaCache: cache)
            
            
        } failureCallback: { [weak self] (code, err) in
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

                return
            }
            
        }

    }
    
    
    private func requestLocations() {
        let area_id = currentArea.id
        
        /// cache
        if (!authManager.isSAEnviroment && !authManager.isLogin) {
            var locations = LocationCache.areaLocationList(area_id: area_id, sa_token: currentArea.sa_user_token)
            let all = Location()
            all.id = -1
            all.name = "全部"
            all.sa_user_token = currentArea.sa_user_token
            locations.insert(all, at: 0)
            
            let titles = locations.map(\.name)
            
            if locations.isDifferentFrom(another: self.currentLocations) {
                self.currentLocations = locations
                self.segmentedDataSource?.titles = titles
                self.segmentedDataSource?.reloadData(selectedIndex: self.segmentedView?.selectedIndex ?? 0)
                self.segmentedView?.reloadData()
            }
            
            /// auth
            checkAuthState()
            return
        }

        ApiServiceManager.shared.areaLocationsList(area: currentArea) { [weak self] (response) in
            guard let self = self else { return }
            
            self.noAuthTipsView.removeFromSuperview()
            self.listContainerView?.snp.remakeConstraints {
                $0.top.equalTo(self.segmentedView!.snp.bottom)
                $0.left.right.bottom.equalToSuperview()
            }
            
            response.locations.forEach {
                $0.area_id = area_id
                $0.sa_user_token = self.currentArea.sa_user_token
            }
            LocationCache.cacheLocations(locations: response.locations, token: self.currentArea.sa_user_token)

            var locations = LocationCache.areaLocationList(area_id: area_id, sa_token: self.currentArea.sa_user_token)
            
            let all = Location()
            all.name = "全部"
            all.id = -1
            all.sa_user_token = self.currentArea.sa_user_token
            locations.insert(all, at: 0)
            
            let titles = locations.map(\.name)
            
            if locations.isDifferentFrom(another: self.currentLocations) {
                self.currentLocations = locations
                self.segmentedDataSource?.titles = titles
                self.segmentedDataSource?.reloadData(selectedIndex: self.segmentedView?.selectedIndex ?? 0)
                self.segmentedView?.reloadData()
            }

            
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
//            self.hideLodingView()
            
            self.checkAuthState()
            var locations = LocationCache.areaLocationList(area_id: area_id, sa_token: self.currentArea.sa_user_token)
            let all = Location()
            all.name = "全部"
            all.id = -1
            all.sa_user_token = self.currentArea.sa_user_token
            locations.insert(all, at: 0)
            
            let titles = locations.map(\.name)
            
            if locations.isDifferentFrom(another: self.currentLocations) {
                self.currentLocations = locations
                self.segmentedDataSource?.titles = titles
                self.segmentedDataSource?.reloadData(selectedIndex: self.segmentedView?.selectedIndex ?? 0)
                self.segmentedView?.reloadData()
            }
            return
        }
        /// auth
        checkAuthState()

    }
    
    
}

