//
//  PluginDetailViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/1.
//

import UIKit

class PluginDetailViewController: BaseViewController {
    var pluginId = ""
    
    /// 是否系统插件详情 (否则没有更新插件选项)
    var isSys = true

    private var plugin = Plugin() {
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
        requestNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        
        pluginCell.installPluginCallback = { [weak self] in
            guard let self = self else { return }
            self.installPlugin(plugin: self.plugin)
        }
        
        pluginCell.updatePluginCallback = { [weak self] in
            guard let self = self else { return }
            self.installPlugin(plugin: self.plugin)
        }
        
        pluginCell.deletePluginCallback = { [weak self] in
            guard let self = self else { return }
            var message = "确定要删除该插件吗？"
            if getCurrentLanguage() == .english {
                message = "Do you want to uninstall this plugin? "
            }
            
            TipsAlertView.show(message: message) { [weak self] in
                guard let self = self else { return }
                self.deletePlugin()
            }
            
        }
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.left.right.bottom.equalToSuperview()
        }
    }

    
    private func installPlugin(plugin: Plugin) {
        plugin.is_updating = true
        self.refresh()
        ApiServiceManager.shared.installPlugin(name: plugin.brand, plugins: [plugin.id]) { [weak self] _ in
            guard let self = self else { return }
            plugin.is_updating = false
            plugin.is_added = true
            plugin.is_newest = true
            
            self.refresh()
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.showToast(string: err)
            plugin.is_updating = false
            self.refresh()
        }
    }
    
    private func deletePlugin() {
        plugin.is_updating = true
        self.refresh()
        ApiServiceManager.shared.deletePluginById(id: pluginId) { [weak self] _ in
            guard let self = self else { return }
            self.plugin.is_updating = false
            self.plugin.is_added = false
            self.plugin.is_newest = false
            self.refresh()
            self.navigationController?.popViewController(animated: true)
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.showToast(string: err)
            self.plugin.is_updating = false
            self.refresh()
        }
    }

    private func refresh() {
        pluginCell.plugin = plugin
        tableView.reloadData()
    }
    
    private func requestNetwork() {
        ApiServiceManager.shared.pluginDetail(id: pluginId) { [weak self] resp in
            guard let self = self else { return }
            if !self.isSys {
                resp.plugin.is_newest = true
            }
            self.plugin = resp.plugin

        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.showToast(string: err)
        }

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
            return 0//plugin.support_devices.count
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
            return nil//BrandDetailDeiviceSectionHeader()
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
