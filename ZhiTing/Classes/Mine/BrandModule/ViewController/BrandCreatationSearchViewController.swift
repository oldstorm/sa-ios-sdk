//
//  BrandCreatationSearchViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/5.
//


import UIKit
import Alamofire


class BrandCreationSearchViewController: BaseViewController {
    private lazy var plugins = [Plugin]()

    
    var selectCallback: ((Plugin) -> ())?

    lazy var search = ""

    private lazy var searchView = BrandSearchView()

    private lazy var emptyView = EmptyStyleView(frame: .zero, style: .noContent)
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.white_ffffff)
        $0.register(BrandCreationCell.self, forCellReuseIdentifier: BrandCreationCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 80
        $0.delegate = self
        $0.dataSource = self
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        requestNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(searchView)
        view.addSubview(tableView)
        
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
        tableView.addSubview(emptyView)
        emptyView.isHidden = true
        
        searchView.searchCallback = { [weak self] str in
            guard let self = self else { return }
            self.search = str
            self.requestNetwork()
        }
        
        searchView.clickCancelCallback = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func setupConstraints() {
        searchView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.statusBarHeight)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview().offset(-15)
        }


        tableView.snp.makeConstraints {
            $0.top.equalTo(searchView.snp.bottom).offset(15)
            $0.left.right.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.width.equalTo(tableView)
            $0.height.equalTo(tableView)
            $0.center.equalToSuperview()
        }
    }
    
    @objc func requestNetwork() {
        ApiServiceManager.shared.plugins(list_type: 1) { [weak self] (response) in
            guard let self = self else { return }
            if self.search != "" {
                self.plugins = response.plugins.filter({ $0.name.contains(self.search.lowercased()) })
            } else {
                self.plugins = response.plugins
            }
            self.emptyView.isHidden = self.plugins.count != 0
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
            
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.emptyView.isHidden = self.plugins.count != 0
            self.tableView.mj_header?.endRefreshing()
        }

    }
    
}


extension BrandCreationSearchViewController {
    private func deletePlugin(plugin: Plugin) {
        self.showLoadingView()
        ApiServiceManager.shared.deletePluginById(id: plugin.id) { [weak self] _ in
            guard let self = self else { return }
            self.showToast(string: "删除成功".localizedString)
            self.hideLoadingView()
            self.requestNetwork()
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.hideLoadingView()
            self.showToast(string: err)
        }
    }


}

extension BrandCreationSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plugins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BrandCreationCell.reusableIdentifier, for: indexPath) as! BrandCreationCell
        let plugin = plugins[indexPath.row]
        cell.plugin = plugin
        
        cell.deleteCallback = { [weak self] in
            guard let self = self else { return }
            if plugin.build_status == -1 {
                var message = "确定要删除该插件吗？"
                if getCurrentLanguage() == .english {
                    message = "Do you want to uninstall this plugin? "
                }
                TipsAlertView.show(message: message) { [weak self] in
                    guard let self = self else { return }
                    self.deletePlugin(plugin: plugin)
                }
            } else {
                self.deletePlugin(plugin: plugin)
            }
            

            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if plugins[indexPath.row].build_status != 1 {
            return
        }

        selectCallback?(plugins[indexPath.row])
        self.dismiss(animated: false, completion: nil)
        
    }
    
    
}

