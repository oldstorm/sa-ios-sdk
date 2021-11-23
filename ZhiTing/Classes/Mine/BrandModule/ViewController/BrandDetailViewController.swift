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
            let plugin = self.brand.plugins[index]
            vc.pluginId = plugin.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        tableViewHeader.header.installAllCallback = { [weak self] in
            guard let self = self else { return }
            self.brand.is_updating = true
            self.installPlugin(plugins: self.brand.plugins)
        }
        
        tableViewHeader.header.updateAllCallback = { [weak self] in
            guard let self = self else { return }
            self.brand.is_updating = true
            self.installPlugin(plugins: self.brand.plugins)
        }
        
        tableViewHeader.installPluginCallback = { [weak self] index in
            guard let self = self else { return }
            let plugin = self.brand.plugins[index]
//            plugin.is_updating = true
            self.brand.is_updating = true
//            self.refresh()
//            self.websocket.executeOperation(operation: .installPlugin(plugin_id: plugin.id))
            self.installPlugin(plugins: [plugin])
        }
        
        tableViewHeader.updatePluginCallback = { [weak self] index in
            guard let self = self else { return }
            let plugin = self.brand.plugins[index]
            self.brand.is_updating = true
            self.installPlugin(plugins: [plugin])
        }
        
        tableViewHeader.deletePluginCallback = { [weak self] index in
            guard let self = self else { return }
            var message = "确定要删除该插件吗？"
            if getCurrentLanguage() == .english {
                message = "Do you want to uninstall this plugin? "
            }
            TipsAlertView.show(message: message) { [weak self] in
                guard let self = self else { return }
                let plugin = self.brand.plugins[index]
                self.deletePlugin(plugins: [plugin])
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
    

    
    private func refresh() {
        tableViewHeader.brand = brand
        tableView.reloadData()
    }
    
}


extension BrandDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return BrandDetailDeiviceSectionHeader()
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0//brand.support_devices.count
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
    
    private func installPlugin(plugins: [Plugin]) {
        plugins.forEach {
            $0.is_updating = true
        }
        self.refresh()
        ApiServiceManager.shared.installPlugin(name: brand_name, plugins: plugins.map(\.id)) { [weak self] resp in
            guard let self = self else { return }
            plugins.forEach {
                $0.is_updating = false
            }

            resp.success_plugins.forEach { successPluginId in
                if let plugin = plugins.first(where: { $0.id == successPluginId }) {
                    plugin.is_added = true
                    plugin.is_newest = true
                }
            }
            
            var updateFlag = false
            var addedFlag = true
            self.brand.plugins.forEach {
                if $0.is_updating {
                    updateFlag = true
                }
                
                if !$0.is_added || !$0.is_newest {
                    addedFlag = false
                }
            }
            
            self.brand.is_updating = updateFlag
            self.brand.is_added = addedFlag
            self.brand.is_newest = addedFlag
            
            self.refresh()
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.showToast(string: err)
            plugins.forEach {
                $0.is_updating = false
            }
            if self.brand.plugins.filter({ $0.is_updating == true }).count == 0 {
                self.brand.is_updating = false
            }
            self.refresh()
        }
    }
    
    private func deletePlugin(plugins: [Plugin]) {
        plugins.forEach {
            $0.is_updating = true
        }
        self.refresh()
        ApiServiceManager.shared.deletePlugin(name: brand_name, plugins: plugins.map(\.id)) { [weak self] _ in
            guard let self = self else { return }
            plugins.forEach {
                $0.is_updating = false
                $0.is_added = false
                $0.is_newest = false
            }
            if self.brand.plugins.filter({ $0.is_updating == true }).count == 0 {
                self.brand.is_added = false
                self.brand.is_newest = false
                self.brand.is_updating = false
            }
            self.showToast(string: "删除成功".localizedString)
            self.refresh()
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.showToast(string: err)
            plugins.forEach {
                $0.is_updating = false
            }
            if self.brand.plugins.filter({ $0.is_updating == true }).count == 0 {
                self.brand.is_updating = false
            }
            self.refresh()
        }
    }
    
}

