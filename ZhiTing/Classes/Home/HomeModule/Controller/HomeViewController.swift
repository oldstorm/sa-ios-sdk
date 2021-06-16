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
        $0.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight)
    }
    
    private var switchAreaView =  SwtichAreaView()
    
    private var currentArea: Area?
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
            self.currentAreaManager.currentArea = area
        }
        
        header.switchAreaCallButtonCallback = { [weak self] in
            guard let self = self else { return }
            SceneDelegate.shared.window?.addSubview(self.switchAreaView)
        }
        
        header.plusBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }

            if !self.authManager.currentRolePermissions.add_device && self.authManager.currentSA.token != "" {
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
        networkStatusPublisher
            .sink { [weak self] state in
                guard let self = self else { return }
                if state == .reachable {
                    DispatchQueue.main.async {
                        self.requestAreas()
                    }
                    
                }
            }
            .store(in: &cancellables)
        
        currentAreaManager.currentAreaPublisher
            .sink { [weak self] (area) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.reloadLocations(by: area)
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
        currentArea = area
        header.titleLabel.text = area.name
        
        // switch according SA
        if let saCache = SmartAssistantCache.getSmartAssistantsFromCache().first(where: { $0.token == area.sa_token }) {
            authManager.currentSA = saCache
        }
        
        if area.sa_token.contains("unbind") {
            if let saCache = SmartAssistantCache.getSmartAssistantsFromCache().first(where: { $0.token == "" }) {
                authManager.currentSA = saCache
            }
        }
        
        requestLocations()
        
       
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

extension HomeViewController {
    private func checkAuthState() {
        if !authManager.isSAEnviroment {
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
        
        if !authManager.currentRolePermissions.add_device && !(currentArea?.sa_token.contains("unbind") ?? true) {
            if authManager.isSAEnviroment {
                header.setBtns(btns: [.scan])
            } else {
                header.setBtns(btns: [])
            }
            
        } else {
            header.setBtns(btns: [.add, .scan])
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
        vc.area = currentArea
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
        
        showLodingView()
        apiService.requestModel(.areaList, modelType: AreaListReponse.self) { [weak self] (response) in
            guard let self = self else { return }
            self.noAuthTipsView.refreshBtn.stopAnimate()
            response.areas.forEach { $0.sa_token = self.authManager.currentSA.token }
            AreaCache.cacheAreas(areas: response.areas)
            
            let areas = AreaCache.areaList()

            /// update the switchAreaView
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
            
            
            /// need switch to currentSA's area
            if self.needSwitchToCurrentSAArea {
                if let area = areas.first(where: { $0.sa_token == self.authManager.currentSA.token }) {
                    self.currentAreaManager.currentArea = area
                } 
                self.needSwitchToCurrentSAArea = false
                return
            }

            self.requestLocations()

        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.noAuthTipsView.refreshBtn.stopAnimate()
            
            let cacheAreas = AreaCache.areaList()
            self.switchAreaView.areas = cacheAreas
            if let area = cacheAreas.first,
               self.switchAreaView.selectedArea.name == ""
            {
                self.currentAreaManager.currentArea = area
                return
            }
            
            /// need switch to currentSA's area
            if self.needSwitchToCurrentSAArea {
                if let area = cacheAreas.first(where: { $0.sa_token == self.authManager.currentSA.token }) {
                    self.currentAreaManager.currentArea = area
                } else {
                    if let area = cacheAreas.first {
                        self.currentAreaManager.currentArea = area
                    }
                    
                }
                self.needSwitchToCurrentSAArea = false
            }
            
            self.requestLocations()
        }

    }
    
    
    private func requestLocations() {
        guard let currentArea = currentArea else { return }
        
        showLodingView()

        let area_id = currentArea.id
        
        /// cache
        if !authManager.isSAEnviroment {
            hideLodingView()
            var cachedLocations = LocationCache.areaLocationList(area_id: area_id, sa_token: currentArea.sa_token)
            let all = Location()
            all.id = -1
            all.name = "全部"
            cachedLocations.insert(all, at: 0)
            
            let titles = cachedLocations.map(\.name)
            
            currentLocations = cachedLocations
            segmentedDataSource?.titles = titles
            segmentedDataSource?.reloadData(selectedIndex: self.segmentedView?.selectedIndex ?? 0)
            segmentedView?.reloadData()
            
            /// auth
            checkAuthState()
            return
        }

        apiService.requestModel(.areaLocationsList, modelType: AreaLocationListResponse.self) { [weak self] (response) in
            guard let self = self else { return }
            self.hideLodingView()
            
            //
            self.noAuthTipsView.removeFromSuperview()
            self.listContainerView?.snp.remakeConstraints {
                $0.top.equalTo(self.segmentedView!.snp.bottom)
                $0.left.right.bottom.equalToSuperview()
            }
            //
            
            response.locations.forEach {
                $0.area_id = area_id
                $0.sa_token = currentArea.sa_token
            }
            LocationCache.cacheLocations(locations: response.locations, token: currentArea.sa_token)

            var areas = LocationCache.areaLocationList(area_id: area_id, sa_token: currentArea.sa_token)
            
            let all = Location()
            all.name = "全部"
            all.id = -1
            areas.insert(all, at: 0)
            
            let titles = areas.map(\.name)
            
            self.currentLocations = areas
            self.segmentedDataSource?.titles = titles
            self.segmentedDataSource?.reloadData(selectedIndex: self.segmentedView?.selectedIndex ?? 0)
            self.segmentedView?.reloadData()
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.hideLodingView()
            
            if code == 13 { //token失效(用户被删除)
                self.currentArea?.sa_token = AreaCache.unbindArea(sa_token: self.authManager.currentSA.token)
                self.websocket.disconnect()
                if let currentArea = self.currentArea {
                    self.currentAreaManager.currentArea = currentArea
                }
                return
            }
            
            //
            self.view.addSubview(self.noAuthTipsView)
            self.noAuthTipsView.snp.makeConstraints {
                $0.top.equalTo(self.segmentedView!.snp.bottom)
                $0.left.equalToSuperview().offset(ZTScaleValue(15.0))
                $0.right.equalToSuperview().offset(-ZTScaleValue(15.0))
                $0.height.equalTo(ZTScaleValue(40.0))
            }
            
            self.listContainerView?.snp.remakeConstraints {
                $0.top.equalTo(self.noAuthTipsView.snp.bottom).offset(ZTScaleValue(15.0))
                $0.left.right.bottom.equalToSuperview()
            }
            //
            var cachedAreas = LocationCache.areaLocationList(area_id: area_id, sa_token: currentArea.sa_token)
            let all = Location()
            all.name = "全部"
            all.id = -1
            cachedAreas.insert(all, at: 0)
            
            let titles = cachedAreas.map(\.name)
            
            self.currentLocations = cachedAreas
            self.segmentedDataSource?.titles = titles
            self.segmentedDataSource?.reloadData(selectedIndex: self.segmentedView?.selectedIndex ?? 0)
            self.segmentedView?.reloadData()
            return
        }
        
        /// auth
        checkAuthState()

    }
    
    
}



extension HomeViewController {
    private class AreaListReponse: BaseModel {
        var areas = [Area]()
    }
    
    private class AreaLocationListResponse: BaseModel {
        var locations = [Location]()
    }
}
