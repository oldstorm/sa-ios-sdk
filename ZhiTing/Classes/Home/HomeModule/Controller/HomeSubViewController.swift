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

    private lazy var devices = [Device]()
    
    private lazy var emptyView = HomeEmptyDeviceView()
    
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
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.alwaysBounceHorizontal = false
        $0.register(HomeDeviceCell.self, forCellWithReuseIdentifier: HomeDeviceCell.reusableIdentifier)
        $0.register(HomeAddDeviceCell.self, forCellWithReuseIdentifier: HomeAddDeviceCell.reusableIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.mj_header?.beginRefreshing()

        
    }
    
    
    override func setupViews() {
        view.backgroundColor = .clear
        view.addSubview(collectionView)
        collectionView.addSubview(emptyView)
        collectionView.addSubview(noNetworkView)

        
        emptyView.addCallback = { [weak self] in
            guard let self = self else { return }

            if !self.authManager.currentRolePermissions.add_device && !self.authManager.currentArea.sa_user_token.contains("unbind") { // 非本地创建的家庭且没有权限时
                self.showToast(string: "没有权限".localizedString)
                return
            }
            
            let vc = DiscoverViewController()
            vc.area = self.area
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
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
    }
    
    override func setupConstraints() {
        emptyView.snp.makeConstraints {
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
        websocket.deviceStatusPublisher
            .sink { [weak self] result in
                guard let self = self else { return }

                for (index, device) in self.devices.enumerated() {
                    if device.identity == result.device.identity {
                        device.is_online = true
                        DispatchQueue.main.async {
                            self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                        }
                        for instance in result.device.instances {
                            for attr in instance.attributes {
                                if attr.attribute == "power", let power = attr.val as? String {
                                    device.isOn = power == "on"
                                    device.is_permit = attr.can_control ?? false
                                    device.powerInstanceId = instance.instance_id
                                    DispatchQueue.main.async {
                                        self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                                    }
                                    return
                                }
                            }
                        }
                        
                        
                    }
                }
                
            }
            .store(in: &cancellables)
        
        
        
        
        websocket.deviceStatusChangedPublisher
            .sink { [weak self] stateResponse in
                guard let self = self else { return }
                for (index, device) in self.devices.enumerated() {
                    if device.identity == stateResponse.identity {
                        if let power = stateResponse.attr.val as? String, stateResponse.attr.attribute == "power" {
                            device.isOn = (power == "on")
                            DispatchQueue.main.async {
                                self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                            }
                            return
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        websocket.devicePowerPublisher
            .sink { [weak self] (power, identity) in
                guard let self = self else { return }
                for (index, device) in self.devices.enumerated() {
                    if device.identity == identity {
                        device.isOn = power
                        DispatchQueue.main.async {
                            self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                        }
                        return
                    }
                }
            }
            .store(in: &cancellables)
        
        websocket.socketDidConnectedPublisher
            .dropFirst()
            .sink { [weak self] in
                guard let self = self else { return }
                self.requestNetwork()
            }
            .store(in: &cancellables)
        
    }

}



extension HomeSubViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
            let device = devices[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeDeviceCell.reusableIdentifier, for: indexPath) as! HomeDeviceCell
            cell.device = device
            cell.statusButtonCallback = { [weak self] isOn in
                guard let self = self else { return }
                if isOn {
                    self.websocket.executeOperation(operation: .controlDevicePower(domain: device.plugin_id, identity: device.identity, instance_id: device.powerInstanceId ?? 0, power: false))
                } else {
                    self.websocket.executeOperation(operation: .controlDevicePower(domain: device.plugin_id, identity: device.identity, instance_id: device.powerInstanceId ?? 0, power: true))
                }
                device.isOn = isOn
            }

            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == devices.count {
            let vc = DiscoverViewController()
            vc.area = self.area
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

        let link = devices[indexPath.row].plugin_url ?? ""
        let vc = DeviceWebViewController(link: link, device_id: devices[indexPath.row].id)
        vc.area = area
        
        
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
        
}

extension HomeSubViewController {
    @objc private func requestNetwork() {
        refreshLocationsCallback?()
        devices.removeAll()
        collectionView.isUserInteractionEnabled = false
        
        /// auth
        if area.sa_user_token.contains("unbind") || authManager.currentRolePermissions.add_device {
            emptyView.addButton.isHidden = false
        } else {
            emptyView.addButton.isHidden = true
        }
        
        /// cache
        if area.sa_user_token.contains("unbind") || (!authManager.isSAEnviroment && !authManager.isLogin) {
            collectionView.mj_header?.endRefreshing()
            noNetworkView.button.buttonState = .normal
            var models = DeviceCache.getAreaHomeDevices(area_id: area.id, sa_token: area.sa_user_token)
            
            if location_id != -1 {
                models = models.filter { $0.location_id == location_id }
            }
            
            devices = models
            
            if area.sa_user_token.contains("unbind") {
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
            
            
            collectionView.reloadData()
            collectionView.isUserInteractionEnabled = true
            return
        }
        
        ApiServiceManager.shared.deviceList(area: area) { [weak self] response in
            self?.collectionView.mj_header?.endRefreshing()
            self?.noNetworkView.button.buttonState = .normal
            guard let self = self else { return }
            response.devices.forEach { device in
                device.area_id = self.area.id
                if let existDevice = self.devices.first(where: { $0.identity == device.identity }) {
                    device.isOn = existDevice.isOn
                    device.is_online = existDevice.is_online
                    device.is_permit = existDevice.is_permit
                }

            }
            var devices = response.devices
            if self.location_id != -1 {
                devices = devices.filter { $0.location_id == self.location_id }
            }
            self.devices = devices
            self.noNetworkView.isHidden = true
            self.emptyView.isHidden = (self.devices.count != 0)
            self.devices.forEach {
                if !$0.is_sa {
                    let domain = $0.plugin_id
                    self.websocket.executeOperation(operation: .getDeviceAttributes(domain: domain, identity: $0.identity))

                }
            }
            
            DeviceCache.cacheHomeDevices(homeDevices: self.devices, area_id: self.area.id, sa_token: self.area.sa_user_token)
            
            self.collectionView.reloadData()
            self.collectionView.isUserInteractionEnabled = true
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            var devices = DeviceCache.getAreaHomeDevices(area_id: self.area.id, sa_token: self.area.sa_user_token)
            if self.location_id != -1 {
                devices = devices.filter { $0.location_id == self.location_id }
            }
            self.devices = devices
            self.collectionView.mj_header?.endRefreshing()
            self.noNetworkView.button.buttonState = .normal
            if self.networkStateManager.networkState == .reachable && self.devices.count == 0 {
                self.emptyView.isHidden = false
                self.noNetworkView.isHidden = true
            } else if self.networkStateManager.networkState == .noNetwork && self.devices.count == 0 {
                self.emptyView.isHidden = true
                self.noNetworkView.isHidden = false
            }
            
            self.collectionView.reloadData()
            self.collectionView.isUserInteractionEnabled = true
        }
        
    }
    
}

extension HomeSubViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
