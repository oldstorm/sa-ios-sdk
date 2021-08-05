//
//  BrandDetailViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/26.
//

import UIKit

class BrandDetailViewController: BaseViewController {
    var brand_name = ""
    
    var brand = Brand() {
        didSet {
            refresh()
        }
    }

    lazy var tableViewHeader = BrandDetailHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 200))
    
    lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.register(BrandDetailDeviceCell.self, forCellReuseIdentifier: BrandDetailDeviceCell.reusableIdentifier)
        $0.estimatedRowHeight = 70
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.tableHeaderView = tableViewHeader
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.mj_header?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "品牌详情".localizedString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        
        tableViewHeader.heightChangeCallback = { [weak self] height in
            self?.tableViewHeader.frame.size.height = height
            self?.tableView.reloadData()
        }
        
        tableViewHeader.pluginClickCallback = { [weak self] index in
            guard let self = self else { return }
            let vc = PluginDetailViewController()
            vc.plugin = self.brand.plugins[index]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        tableViewHeader.header.installAllCallback = { [weak self] in
            guard let self = self else { return }
            self.brand.is_updating = true
            let plugins = self.brand.plugins
            plugins.forEach {
                $0.is_updating = true
                self.websocket.executeOperation(operation: .installPlugin(plugin_id: $0.id))
            }
            self.refresh()
        }
        
        tableViewHeader.header.updateAllCallback = { [weak self] in
            guard let self = self else { return }
            self.brand.is_updating = true
            let plugins = self.brand.plugins
            plugins.forEach {
                $0.is_updating = true
                self.websocket.executeOperation(operation: .installPlugin(plugin_id: $0.id))
            }
            self.refresh()
        }
        
        tableViewHeader.installPluginCallback = { [weak self] index in
            guard let self = self else { return }
            let plugin = self.brand.plugins[index]
            plugin.is_updating = true
            self.brand.is_updating = true
            self.refresh()
            self.websocket.executeOperation(operation: .installPlugin(plugin_id: plugin.id))
        }
        
        tableViewHeader.updatePluginCallback = { [weak self] index in
            guard let self = self else { return }
            let plugin = self.brand.plugins[index]
            plugin.is_updating = true
            self.brand.is_updating = true
            self.refresh()
            self.websocket.executeOperation(operation: .updatePlugin(plugin_id: plugin.id))
        }
        
        tableViewHeader.deletePluginCallback = { [weak self] index in
            guard let self = self else { return }
            var message = "确定要删除该插件吗,该插件包含的设备也将一起被删除"
            if getCurrentLanguage() == .english {
                message = "Do you want to uninstall this plugin? The devices contained in this plugin will be removed as well."
            }
            TipsAlertView.show(message: message) { [weak self] in
                guard let self = self else { return }
                let plugin = self.brand.plugins[index]
                self.websocket.executeOperation(operation: .removePlugin(plugin_id: plugin.id))
                plugin.is_added = false
                self.brand.is_added = false
                self.refresh()
            }
            
        }
        
        
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
        
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setupSubscriptions() {
        websocket.installPluginPublisher
            .sink { [weak self] (plugin_id, success) in
                guard let self = self else { return }
                self.pluginInstalled(plugin_id: plugin_id, success: success)
                
            }
            .store(in: &cancellables)
        
        
    }
    
    func pluginInstalled(plugin_id: String, success: Bool) {
        brand.plugins.forEach { (plugin) in
            if plugin.id == plugin_id {
                plugin.is_updating = false
                if success {
                    plugin.is_added = true
                    plugin.is_newest = true
                }
            }
        }
        
        let uninstall = brand.plugins.filter({ $0.is_added == false })
        let updating = brand.plugins.filter({ $0.is_updating == true })
        if uninstall.count == 0 && updating.count == 0 {
            brand.is_added = true
            brand.is_newest = true
            brand.is_updating = false
        } else if uninstall.count != 0 && updating.count == 0 {
            brand.is_updating = false
        }

        refresh()
        
    }
    
    private func refresh() {
        tableViewHeader.brand = brand
        tableView.reloadData()
    }
    
}


extension BrandDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return BrandDetailDeiviceSectionHeader()
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brand.support_devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BrandDetailDeviceCell.reusableIdentifier, for: indexPath) as! BrandDetailDeviceCell
        cell.device = brand.support_devices[indexPath.row]
        return cell
    }
    
        
}

extension BrandDetailViewController {
    @objc private func requestNetwork() {
        ApiServiceManager.shared.brandDetail(name: brand_name) { [weak self] response in
            guard let self = self else { return }
            self.tableView.mj_header?.endRefreshing()
            
            self.brand = response.brand
            
            
        } failureCallback: { [weak self] (code, err) in
            self?.tableView.mj_header?.endRefreshing()
        }

    }
    
}

