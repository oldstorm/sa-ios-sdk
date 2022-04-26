//
//  HomeViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit
import JXSegmentedView

class HomeSubViewController: BaseViewController {
    var area: Area {
        return authManager.currentArea
    }
    
    lazy var location_id: Int = -1
    lazy var department_id: Int = -1
    
    /// 子控制器的唯一标识
    var identifier = ""
    
    var devices = [Device]() {
        didSet {
            requestNetwork()
        }
    }
    
    /// 是否可以滚动
    var canScroll = true
    /// 父vc是否可以滚动回调
    var superCanScrollCallback: ((Bool) -> ())?
    
    private lazy var emptyView = HomeEmptyDeviceView()
    private lazy var noTokenEmptyView = EmptyStyleView(frame: .zero, style: .noToken)
    
    private lazy var noNetworkView = EmptyStyleView(frame: .zero, style: .noNetwork)
    
    var refreshLocationsCallback: (() -> ())?
    
    private lazy var checkStatusOperationQueue = OperationQueue().then {
        $0.maxConcurrentOperationCount = 1
    }
    
    private lazy var flowLayout = UICollectionViewFlowLayout().then {
        let sizeW = (Screen.screenWidth - 45) / 2
        let sizeH = sizeW * 120 / 165
        $0.itemSize = CGSize(width: sizeW, height: sizeH)
        $0.minimumLineSpacing = 15
        $0.minimumInteritemSpacing = 15
        $0.headerReferenceSize = CGSize(width: Screen.screenWidth - 30, height: 15)
        $0.footerReferenceSize = CGSize(width: Screen.screenWidth - 30, height: 15)
        
    }
    
    private lazy var listLayout = UICollectionViewFlowLayout().then {
        let sizeW = Screen.screenWidth - 30
        let sizeH: CGFloat = 70
        $0.itemSize = CGSize(width: sizeW, height: sizeH)
        $0.minimumLineSpacing = 10
        $0.minimumInteritemSpacing = 15
        $0.headerReferenceSize = CGSize(width: Screen.screenWidth - 30, height: 15)
        $0.footerReferenceSize = CGSize(width: Screen.screenWidth - 30, height: 15)
    }

    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewLayout
        let style = appPreference.deviceListStyle ?? .flow
        switch style {
        case .list:
            layout = listLayout
        case .flow:
            layout = flowLayout
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.alwaysBounceHorizontal = false
        cv.register(HomeDeviceCell.self, forCellWithReuseIdentifier: HomeDeviceCell.reusableIdentifier)
        cv.register(HomeAddDeviceCell.self, forCellWithReuseIdentifier: HomeAddDeviceCell.reusableIdentifier)
        return cv
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func setupViews() {
        view.backgroundColor = .clear
        view.addSubview(collectionView)
        collectionView.addSubview(emptyView)
        collectionView.addSubview(noTokenEmptyView)
        collectionView.addSubview(noNetworkView)
        
        
        emptyView.addCallback = { [weak self] in
            guard let self = self else { return }
            
            if !self.authManager.currentRolePermissions.add_device && !self.authManager.currentArea.sa_user_token.contains("unbind") { // 非本地创建的家庭且没有权限时
                self.showToast(string: "没有权限".localizedString)
                return
            }
            
            let vc = DiscoverViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        noNetworkView.buttonCallback = { [weak self] in
            guard let self = self else { return }
            self.noNetworkView.button.buttonState = .waiting
            self.requestNetwork()
        }
        
        emptyView.isHidden = true
        noNetworkView.isHidden = true
        
        let header = ZTGIFRefreshHeader()
        collectionView.mj_header = header
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(reloadAll))
        
    }
    
    override func setupConstraints() {
        emptyView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 30)
            $0.height.equalTo(collectionView.snp.height).offset(-30)
            $0.top.equalToSuperview().offset(15)
        }
        
        noTokenEmptyView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 30)
            $0.height.equalTo(collectionView.snp.height).offset(-30)
            $0.top.equalToSuperview().offset(15)
        }
        
        noNetworkView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 30)
            $0.height.equalTo(collectionView.snp.height).offset(-30)
            $0.top.equalToSuperview().offset(15)
            
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-15)
            $0.left.equalToSuperview().offset(15).priority(.high)
            $0.right.equalToSuperview().offset(-15).priority(.high)
            $0.bottom.equalToSuperview().offset(-Screen.tabbarHeight).priority(.high)
        }
    }
    
    override func setupSubscriptions() {
        appPreference.deviceListStylePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] style in
                guard let self = self else { return }
                switch style {
                case .flow:
                    self.collectionView.setCollectionViewLayout(self.flowLayout, animated: true) { _ in
                        self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                    }
                    
                case .list:
                    self.collectionView.setCollectionViewLayout(self.listLayout, animated: true) { _ in
                        self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                    }
                }
                
            }
            .store(in: &cancellables)
        

        websocket.deviceStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result, success in
                guard let self = self else { return }
                
                for (index, device) in self.devices.enumerated() {
                    if device.iid == result.iid {
                        device.device_status = success ? result : nil
                        self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                        
                    }
                }
                
            }
            .store(in: &cancellables)
        
        
        
        
        websocket.deviceStatusChangedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stateResponse in
                guard let self = self else { return }
                for (index, device) in self.devices.enumerated() {
                    if let instance = device.device_status?.instances.first(where: { $0.iid == stateResponse.attr.iid }) {
                        instance.services.forEach { service in
                            if let attr = service.attributes.first(where: { $0.aid == stateResponse.attr.aid }) {
                                attr.val = stateResponse.attr.val
                                self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                            }
                        }
                    }
                    
                }
            }
            .store(in: &cancellables)
        
        
        websocket.socketDidConnectedPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.requestNetwork()
            }
            .store(in: &cancellables)
        
        authManager.roleRefreshPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.noTokenEmptyView.isHidden = self.area.isAllowedGetToken
                
                /// auth
                if self.area.id == nil || self.authManager.currentRolePermissions.add_device {
                    self.emptyView.addButton.isHidden = false
                } else {
                    self.emptyView.addButton.isHidden = true
                }
                self.collectionView.reloadData()
                
            }
            .store(in: &cancellables)
    }
    
}



extension HomeSubViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            if !canScroll {
                if scrollView.contentOffset.y > 0 {
                    scrollView.contentOffset.y = 0
                }
                
            } else {
                if scrollView.contentOffset.y <= 0 {
                    canScroll = false
                    superCanScrollCallback?(true)
                }
            }
        }

    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if authManager.currentRolePermissions.add_device || area.sa_user_token.contains("unbind") {
            return devices.count > 0 ? devices.count + 1 : devices.count
        } else {
            return devices.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == devices.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeAddDeviceCell.reusableIdentifier, for: indexPath) as! HomeAddDeviceCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeDeviceCell.reusableIdentifier, for: indexPath) as! HomeDeviceCell
            cell.layoutStyle = appPreference.deviceListStyle
            let device = devices[indexPath.row]
            cell.device = device
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == devices.count {
            let vc = DiscoverViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if devices[indexPath.row].is_sa {
            
            let vc = SADeviceViewController()
            vc.area = area
            vc.device_id = devices[indexPath.row].id
            vc.deviceImg.setImage(urlString: devices[indexPath.row].logo_url, placeHolder: .assets(.default_device))
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
            return
            
        }
        
        //检测插件包是否需要更新
        self.showLoadingView()
        ApiServiceManager.shared.checkPluginUpdate(id: devices[indexPath.row].plugin_id) { [weak self] response in
            guard let self = self else { return }
            let filepath = ZTZipTool.getDocumentPath() + "/" + self.devices[indexPath.row].plugin_id
            
            @UserDefaultWrapper(key: .plugin(id: self.devices[indexPath.row].plugin_id))
            var info: String?
            
            let cachePluginInfo = Plugin.deserialize(from: info ?? "")
            
            
            //检测本地是否有文件，以及是否为最新版本
            if ZTZipTool.fileExists(path: filepath) && cachePluginInfo?.version == response.plugin.version {
                self.hideLoadingView()
                //直接打开插件包获取信息
                let urlPath = "file://" + ZTZipTool.getDocumentPath() + "/" + self.devices[indexPath.row].plugin_id + "/" + self.devices[indexPath.row].control
                let vc = DeviceWebViewController(link: urlPath, device_id: self.devices[indexPath.row].id)
                vc.area = self.area
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                //根据路径下载最新插件包，存储在document
//                let downloadUrl = "http://192.168.22.120/zhiting/zhiting.zip"
                let downloadUrl = response.plugin.download_url ?? ""
                ZTZipTool.downloadZipToDocument(urlString: downloadUrl, fileName: self.devices[indexPath.row].plugin_id) { [weak self] success in
                    guard let self = self else { return }
                    self.hideLoadingView()
                    
                    if success {
                        //根据相对路径打开本地静态文件
                        let urlPath = "file://" + ZTZipTool.getDocumentPath() + "/" + self.devices[indexPath.row].plugin_id + "/" + self.devices[indexPath.row].control
                        let vc = DeviceWebViewController(link: urlPath, device_id: self.devices[indexPath.row].id)
                        vc.area = self.area
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(vc, animated: true)
                        //存储插件信息
                        info = response.plugin.toJSONString(prettyPrint:true)
                    } else {
                        self.showToast(string: "下载插件失败".localizedString)
                    }
                    
                }
                
            }
            
            
            
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.hideLoadingView()
            let link = self.devices[indexPath.row].plugin_url ?? ""
            let vc = DeviceWebViewController(link: link, device_id: self.devices[indexPath.row].id)
            vc.area = self.area
            vc.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension HomeSubViewController {
    
    @objc private func reloadAll(){
        collectionView.isUserInteractionEnabled = false
        refreshLocationsCallback?()
    }
    
    func requestNetwork() {
        if websocket.status != .connected {
            DispatchQueue.main.async {
                self.authManager.updateWebsocket()
            }
        }
        
        authManager.getRolePermissions()
        
        if area.isAllowedGetToken {
            self.noTokenEmptyView.isHidden = true
            self.emptyView.isHidden = true
            /// auth
            if area.id == nil || authManager.currentRolePermissions.add_device {
                emptyView.addButton.isHidden = false
            } else {
                emptyView.addButton.isHidden = true
            }
            
            if area.id == nil {
                noNetworkView.isHidden = true
                emptyView.isHidden = (devices.count != 0)
            } else {
                if self.networkStateManager.networkState == .reachable && self.devices.count == 0 {
                    self.emptyView.isHidden = false
                    self.noNetworkView.isHidden = true
                } else if self.networkStateManager.networkState == .noNetwork && self.devices.count == 0 {
                    self.emptyView.isHidden = true
                    self.noNetworkView.isHidden = false
                }
            }

            collectionView.mj_header?.endRefreshing()
            collectionView.isUserInteractionEnabled = true
            collectionView.reloadData()
            
        } else { //不允许找回凭证
            collectionView.mj_header?.endRefreshing()
            collectionView.isUserInteractionEnabled = true
            self.noTokenEmptyView.isHidden = false
            self.emptyView.isHidden = true
            return
        }
        
        
    }
    
}

extension HomeSubViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
