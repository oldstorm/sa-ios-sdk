//
//  BrandListViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/24.
//

import UIKit

class BrandListViewController: BaseViewController {
    private lazy var brands = [Brand]()
    lazy var name = ""
    private lazy var documentPicker = DocumentPicker(presentationController: self, delegate: self)

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.white_ffffff)
        $0.register(BrandCell.self, forCellReuseIdentifier: BrandCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 80
        $0.delegate = self
        $0.dataSource = self
    }

    private lazy var headerView = SupportedViewHeader()

    private lazy var navRightBtn = Button().then {
        $0.setTitle("添加插件".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        if getCurrentLanguage() == .chinese {
            $0.titleLabel?.font = .font(size: 14, type: .bold)
        } else {
            $0.titleLabel?.font = .font(size: 12, type: .bold)
        }
        $0.frame.size = CGSize(width: 22, height: 22)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.uploadClick()
        }
    }
    
    private var uploadAlert: UploadPluginAlertView?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header?.beginRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "支持品牌".localizedString
        #warning("暂未实现功能隐藏入口")
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        
        view.addSubview(headerView)
        view.addSubview(tableView)
        
        headerView.clickTextFieldCallback = { [weak self] in
            self?.headerView.snp.updateConstraints({ (make) in
                make.top.equalToSuperview().offset(Screen.statusBarHeight)
            })
            self?.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        headerView.clickCancelCallback = { [weak self] in
            guard let self = self else { return }
            self.name = ""
            self.headerView.snp.updateConstraints({ (make) in
                make.top.equalToSuperview()
            })
            self.navigationController?.setNavigationBarHidden(false, animated: true)
           
        }
        
        headerView.searchCallback = { [weak self] name in
            guard let self = self else { return }
            self.name = name
            self.requestNetwork()
        }
        
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
        
    }
    
    override func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
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
    
    @objc private func requestNetwork() {
        
        ApiServiceManager.shared.brands(name: name) { [weak self] (response) in
            guard let self = self else { return }
            self.brands = response.brands
            self.tableView.reloadData()
            

            self.tableView.mj_header?.endRefreshing()
            
        } failureCallback: { [weak self] (code, err) in
            self?.tableView.mj_header?.endRefreshing()
        }

    }
    
}

extension BrandListViewController {
    func pluginInstalled(plugin_id: String, success: Bool) {
        brands.forEach { (brand) in
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
                tableView.reloadData()
            } else if uninstall.count != 0 && updating.count == 0 {
                brand.is_updating = false
                tableView.reloadData()
            }

        }
        
    }
    
}


extension BrandListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BrandCell.reusableIdentifier, for: indexPath) as! BrandCell
        let brand = brands[indexPath.row]
        cell.brand = brand
        
        cell.installButtonCallback = { [weak self] in
            guard let self = self else { return }
            brand.is_updating = true
            tableView.reloadData()
            let plugins = brand.plugins
            plugins.forEach {
                $0.is_updating = true
                self.websocket.executeOperation(operation: .installPlugin(plugin_id: $0.id))
            }
        }
        
        cell.updateButtonCallback = { [weak self] in
            guard let self = self else { return }
            brand.is_updating = true
            tableView.reloadData()
            let plugins = brand.plugins
            plugins.forEach {
                $0.is_updating = true
                self.websocket.executeOperation(operation: .updatePlugin(plugin_id: $0.id))
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = BrandDetailViewController()
        vc.brand_name = brands[indexPath.row].name
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


extension BrandListViewController: DocumentDelegate {
    
    func uploadClick() {
        uploadAlert = UploadPluginAlertView.show { [weak self] in
            guard let self = self else { return }
            self.documentPicker.displayPicker()
        } sureCallback: { [weak self] in
            self?.uploadAlert?.removeFromSuperview()
            self?.requestNetwork()
        }
        

    }

    func didPickDocument(document: Document?) {
        if let pickedDoc = document {
            _ = pickedDoc.fileURL
            /// do what you want with the file URL
        }
    }
    
    
}
