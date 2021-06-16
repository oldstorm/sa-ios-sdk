//
//  PluginDetailViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/1.
//

import UIKit

class PluginDetailViewController: BaseViewController {
    var plugin = Plugin() {
        didSet {
            refresh()
        }
    }

    private lazy var pluginCell = PluginDetailHeaderCell()

    private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.register(BrandDetailDeviceCell.self, forCellReuseIdentifier: BrandDetailDeviceCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "插件详情".localizedString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        
        pluginCell.installPluginCallback = { [weak self] in
            guard let self = self else { return }
            self.plugin.is_updating = true
            self.refresh()
            self.websocket.executeOperation(operation: .installPlugin(plugin_id: self.plugin.id))
        }
        
        pluginCell.updatePluginCallback = { [weak self] in
            guard let self = self else { return }
            self.plugin.is_updating = true
            self.refresh()
            self.websocket.executeOperation(operation: .updatePlugin(plugin_id: self.plugin.id))
        }
        
        pluginCell.deletePluginCallback = { [weak self] in
            guard let self = self else { return }
            var message = "确定要删除该插件吗,该插件包含的设备也将一起被删除"
            if getCurrentLanguage() == .english {
                message = "Do you want to uninstall this plugin? The devices contained in this plugin will be removed as well."
            }
            
            TipsAlertView.show(message: message) { [weak self] in
                guard let self = self else { return }
                self.websocket.executeOperation(operation: .removePlugin(plugin_id: self.plugin.id))
                self.plugin.is_added = false
                self.refresh()
            }
            
        }
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
                if self.plugin.id == plugin_id {
                    self.plugin.is_updating = false
                    if success {
                        self.plugin.is_added = true
                        self.plugin.is_newest = true
                    }
                    self.refresh()
                }
                
                
            }
            .store(in: &cancellables)
    }
    
    private func refresh() {
        pluginCell.plugin = plugin
        tableView.reloadData()
    }
}


extension PluginDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return plugin.support_devices.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return pluginCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: BrandDetailDeviceCell.reusableIdentifier, for: indexPath) as! BrandDetailDeviceCell
            cell.device = plugin.support_devices[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            return BrandDetailDeiviceSectionHeader()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}
