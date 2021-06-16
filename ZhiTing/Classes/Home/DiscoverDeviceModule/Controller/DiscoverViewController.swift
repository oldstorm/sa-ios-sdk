//
//  DiscoverViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/2.
//

import UIKit

class DiscoverViewController: BaseViewController {
    private lazy var header = DiscoverHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth / 2, height: 350))
    
    private lazy var devices = [DiscoverDeviceModel]()
    
    private lazy var saArray = [DiscoverSAModel]()
    
    var area: Area?

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.rowHeight = UITableView.automaticDimension
        $0.dataSource = self
        $0.delegate = self
        $0.tableHeaderView = header
        $0.separatorStyle = .none
        $0.register(DiscoverDeviceCell.self, forCellReuseIdentifier: DiscoverDeviceCell.reusableIdentifier)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if !(area?.sa_token.contains("unbind") ?? true) {
            websocket.executeOperation(operation: .discoverDevice(domain: "yeelight"))
        } else {
            addFakeSA()
        }
        
        
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "添加设备".localizedString
    }

    override func setupViews() {
        view.addSubview(tableView)
        
        header.status = .searching
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let self = self else { return }
            self.checkSearching()
        }
        
        header.retryCallback = { [weak self] in
            guard let self = self else { return }
            self.websocket.executeOperation(operation: .discoverDevice(domain: "yeelight"))
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                self.checkSearching()
            }
        }
        
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
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

    private func checkSearching() {
        if devices.count == 0 && saArray.count == 0 {
            header.status = .failed
        }
    }
    

}

extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { // device
            return devices.count
        } else { //sa
            if let area = area, area.sa_token.contains("unbind") {
                return saArray.count
            }
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 { //device
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
        } else { //sa
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
            
            

        }
        
    }
    
    
}

extension DiscoverViewController {
    
    private func addFakeSA() {
        let device1 = DiscoverSAModel()
        device1.name = "LH's SA"
        device1.model = "smart_assistant"
        device1.address = "192.168.0.159:8088"
        
        let device2 = DiscoverSAModel()
        device2.name = "WJ's SA"
        device2.model = "smart_assistant"
        device2.address = "192.168.0.166:8088"
        
        let device4 = DiscoverSAModel()
        device4.name = "MJ's SA"
        device4.model = "smart_assistant"
        device4.address = "192.168.0.110:8088"
        
        let device3 = DiscoverSAModel()
        device3.name = "测试服's SA"
        device3.model = "smart_assistant"
        device3.address = "sa.zhitingtech.com"
        
        saArray.append(device1)
        saArray.append(device2)
        saArray.append(device4)
        saArray.append(device3)
        tableView.reloadData()
        
        checkSAIsBinded()
    }
    
    private func checkSAIsBinded() {
        saArray.forEach { sa in
            apiService.requestModel(.checkSABindState(url: sa.address), modelType: SABindResponse.self) { [weak self] (response) in
                guard let self = self else { return }
                sa.is_bind = response.is_bind
                self.tableView.reloadData()
            }
        }
        

    }
    
    private class SABindResponse: BaseModel {
        var is_bind = false
    }
}





