//
//  DiscoverViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/2.
//

import UIKit

class DiscoverViewController: BaseViewController {
    private lazy var header = DiscoverHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth / 2, height: 400)).then { $0.clipsToBounds = false }
    
    private lazy var scanBtn = DiscoverScanButton()
    

    /// sa发现的设备
    private lazy var devices = [DiscoverDeviceModel]()
    /// sa
    private lazy var saArray = [DiscoverSAModel]()
    
    

    var area = Area()
    
    // MARK: - espBlufi
    /// espBlufi扫描过滤内容
    private lazy var filterContent = ESPDataConversion.loadBlufiScanFilter()
    /// espBLE设备
    private lazy var bleDevices = [ESPPeripheral]()
    
    let espBleHelper = ESPFBYBLEHelper.share()
    ///
    
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.rowHeight = UITableView.automaticDimension
        $0.dataSource = self
        $0.delegate = self
        $0.separatorStyle = .none
        $0.register(DiscoverDeviceCell.self, forCellReuseIdentifier: DiscoverDeviceCell.reusableIdentifier)
    }

    
    private lazy var discoverBottomView = DiscoverBottomView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "添加设备".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: scanBtn)
        beginScan()
    }
    

    override func setupViews() {
        view.addSubview(tableView)
        view.addSubview(header)
//        view.addSubview(discoverBottomView)
        
        scanBtn.callback = { [weak self] in
            guard let self = self else { return }
            self.websocket.executeOperation(operation: .discoverDevice(domain: "yeelight"))
            self.header.frame.size.height = 350
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                self.checkSearching()
            }
        }
        
        discoverBottomView.selectCallback = { [weak self] in
            guard let self = self else { return }
            let vc = ResetDeviceViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(header.snp.edges)
        }
        
        header.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
//        discoverBottomView.snp.makeConstraints {
//            $0.bottom.left.right.equalToSuperview()
//            $0.top.equalTo(header.snp.bottom)
//        }
    }
    
    override func setupSubscriptions() {
        websocket.discoverDevicePublisher
            .sink { [weak self] device in
                guard let self = self else { return }
                self.devices.append(device)
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func beginScan() {
        bleDevices.removeAll()
        devices.removeAll()
        saArray.removeAll()
        tableView.reloadData()

        header.status = .searching
        if scanBtn.state != .searching {
            scanBtn.state = .searching
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let self = self else { return }
            self.checkSearching()
        }

        if !area.sa_user_token.contains("unbind") {
            websocket.executeOperation(operation: .discoverDevice(domain: "yeelight"))
        } else {
            addFakeSA()
        }
        
        scanBleDevices()
    }

    private func checkSearching() {
        if devices.count == 0 && saArray.count == 0 && bleDevices.count == 0 {
            header.status = .failed
            header.frame.size.height = 400
            scanBtn.state = .normal
        }
    }
    

}

extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if devices.count == 0 && saArray.count == 0 && bleDevices.count == 0 {
            header.isHidden = false
        } else {
            header.isHidden = true
        }
    
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // device
            return devices.count
        } else if section == 1 { //sa
            if area.sa_user_token.contains("unbind") {
                return saArray.count
            }
            return 0
        } else { //espBLE
            return bleDevices.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { //device
            let cell = tableView.dequeueReusableCell(withIdentifier: DiscoverDeviceCell.reusableIdentifier, for: indexPath) as! DiscoverDeviceCell
            let device = devices[indexPath.row]
            cell.device = device
            cell.line0.isHidden = !(indexPath.row == 0)

            cell.addButtonCallback = { [weak self] in
                guard let self = self else { return }
                if !self.authManager.currentRolePermissions.add_device {
                    self.showToast(string: "没有权限".localizedString)
                    return
                }

                let vc = ConnectDeviceViewController()
                vc.area = self.area
                vc.device = device
                vc.removeCallback = { [weak self] in
                    guard let self = self else { return }
                    self.devices.removeAll(where: { $0.identity == device.identity })
                    self.tableView.reloadData()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        } else if indexPath.section == 1 { //sa
            let cell = tableView.dequeueReusableCell(withIdentifier: DiscoverDeviceCell.reusableIdentifier, for: indexPath) as! DiscoverDeviceCell
            let device = saArray[indexPath.row]
            cell.sa_device = device

            if device.is_bind {
                cell.addButtonCallback = { [weak self] in
                    guard let self = self else { return }
                    let vc = ScanQRCodeViewController()
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                cell.addButtonCallback = { [weak self] in
                    guard let self = self else { return }
                    let vc = ConnectDeviceViewController()
                    vc.area = self.area
                    vc.device = device
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            
            return cell
            
            

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: DiscoverDeviceCell.reusableIdentifier, for: indexPath) as! DiscoverDeviceCell
            cell.nameLabel.text = bleDevices[indexPath.row].name
            cell.addButton.setTitle("置网".localizedString, for: .normal)
            cell.addButtonCallback = { [weak self] in
                guard let self = self else { return }
                let vc = BlufiConfigViewController()
                vc.device = self.bleDevices[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            return cell
        }
        
    }
    
    
}

extension DiscoverViewController {
    
    private func addFakeSA() {
        
        let device3 = DiscoverSAModel()
        device3.name = "测试服的SA"
        device3.model = "smart_assistant"
        device3.address = "http://192.168.0.123:9020"



        saArray.append(device3)
        tableView.reloadData()
        
        checkSAIsBinded()
    }
    
    private func checkSAIsBinded() {
        saArray.forEach { sa in
            ApiServiceManager.shared.checkSABindState(url: sa.address) { [weak self] (response) in
                guard let self = self else { return }
                sa.is_bind = response.is_bind
                self.tableView.reloadData()
            } failureCallback: { code, err in
                
            }
        }
        

    }
    
}


/// MARK: ESP-BLE 蓝牙搜索
extension DiscoverViewController {
    /// 扫描esp蓝牙设备
    private func scanBleDevices() {
        espBleHelper.startScan { [weak self] bleDevice in
            guard let self = self else { return }
            if self.shouldAddToSource(device: bleDevice) {
                self.bleDevices.append(bleDevice)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    private func shouldAddToSource(device: ESPPeripheral) -> Bool {
        if filterContent.count > 0 {
            if device.name.isEmpty || !device.name.hasPrefix(filterContent) {
                return false
            }
        }
        
        var flag = true
        /// check exist
        bleDevices.forEach {
            if device.uuid == $0.uuid {
                /// the device already exists in dataSource
                flag = false
                return
            }
        }
        
        return flag

    }
}

