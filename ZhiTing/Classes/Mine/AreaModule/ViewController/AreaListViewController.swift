//
//  AreaListViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/12.
//

import UIKit

class AreaListViewController: BaseViewController {
    private lazy var areas = [Area]()

    private var families: [Area] {
        return areas.filter({ $0.areaType == .family })
    }
    
    private var companies: [Area] {
        return areas.filter({ $0.areaType == .company })
    }

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.register(AreaListCell.self, forCellReuseIdentifier: AreaListCell.reusableIdentifier)
        $0.register(AreaListSectionHeader.self, forHeaderFooterViewReuseIdentifier: AreaListSectionHeader.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 60
        if #available(iOS 15.0, *) {
            $0.sectionHeaderTopPadding = 0
        }
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var bottomAddButton = ImageTitleButton(frame: .zero, icon: .assets(.add_family_icon), title: "添加家庭、公司等区域".localizedString, titleColor: .custom(.blue_2da3f6), backgroundColor: .custom(.white_ffffff))

    private lazy var addAreaAlert = AddAreaAlert()

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "家庭/公司".localizedString
        showLoadingView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestNetwork()
    }

    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(bottomAddButton)
        
        bottomAddButton.clickCallBack = { [weak self] in
            guard let self = self else { return }
            SceneDelegate.shared.window?.addSubview(self.addAreaAlert)      
        }
        
        addAreaAlert.selectCallback = { [weak self] type in
            guard let self = self else { return }
            switch type {
            case .company:
                let vc = CreateCompanyViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            case .family:
                let vc = CreateFamilyViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
        
    }
    
    override func setupConstraints() {
        bottomAddButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
        }
        
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomAddButton.snp.top)
        }
    }
}


extension AreaListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0 && families.count == 0) || (section == 1 && companies.count == 0) {
            return nil
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: AreaListSectionHeader.reusableIdentifier) as! AreaListSectionHeader
        header.titleLabel.text = (section == 0) ? "家庭".localizedString : "公司".localizedString
        return header

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 && families.count == 0) || (section == 1 && companies.count == 0) {
            return 0
        }
        return 30
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return families.count
        } else {
            return companies.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AreaListCell.reusableIdentifier, for: indexPath) as! AreaListCell
        if indexPath.section == 0 {
            cell.title.text = families[indexPath.row].name
        } else {
            cell.title.text = companies[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let vc = FamilyDetailViewController()
            let area = families[indexPath.row]
            vc.area = area
            if (area.bssid == networkStateManager.getWifiBSSID() && area.bssid != nil) || (!area.is_bind_sa && area.cloud_user_id == 0)  {
                navigationController?.pushViewController(vc, animated: true)
            } else {
                if areas.filter({ $0.cloud_user_id > 0}).count > 0 {
                    AuthManager.checkLoginWhenComplete { [weak self] in
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            let vc = CompanyDetailViewController()
            let area = companies[indexPath.row]
            vc.area = area
            if (area.bssid == networkStateManager.getWifiBSSID() && area.bssid != nil) || (!area.is_bind_sa && area.cloud_user_id == 0)  {
                navigationController?.pushViewController(vc, animated: true)
            } else {
                if areas.filter({ $0.cloud_user_id > 0}).count > 0 {
                    AuthManager.checkLoginWhenComplete { [weak self] in
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
    }
    
    
}

extension AreaListViewController {

    @objc func requestNetwork() {
        /// cache
        if !UserManager.shared.isLogin {
            tableView.mj_header?.endRefreshing()
            hideLoadingView()
            areas = AreaCache.areaList()
            print("--------- local cache areas ---------")
            print(areas)
            print("-------------------------------------")
            tableView.reloadData()
            return
        }
        
        ApiServiceManager.shared.areaList { [weak self] (response) in
            guard let self = self else { return }

            response.areas.forEach { $0.cloud_user_id = UserManager.shared.currentUser.user_id }
            AreaCache.cacheAreas(areas: response.areas)
            
            
            let areas = AreaCache.areaList()
            
            print("--------- local cache areas ---------")
            print(areas)
            print("-------------------------------------")
            /// 如果在对应的局域网环境下,将局域网内绑定过SA但未绑定到云端的家庭绑定到云端
            if areas.filter({ $0.needRebindCloud }).count > 0 {
                AuthManager.shared.syncLocalAreasToCloud { [weak self] in
                    guard let self = self else { return }
                    self.hideLoadingView()
                    self.tableView.mj_header?.endRefreshing()
                    self.areas = areas
                    self.tableView.reloadData()
                    
                }
            } else {
                self.hideLoadingView()
                self.tableView.mj_header?.endRefreshing()
                self.areas = areas
                self.tableView.reloadData()
            }
            
            
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.hideLoadingView()
            self.tableView.mj_header?.endRefreshing()
            self.areas = AreaCache.areaList()
            self.tableView.reloadData()
        }

    }
    
}

