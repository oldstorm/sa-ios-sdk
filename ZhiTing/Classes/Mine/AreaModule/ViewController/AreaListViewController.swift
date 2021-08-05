//
//  AreaListViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/12.
//

import UIKit

class AreaListViewController: BaseViewController {
    private lazy var areas = [Area]()

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.register(AreaListCell.self, forCellReuseIdentifier: AreaListCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 60
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var bottomAddButton = ImageTitleButton(frame: .zero, icon: .assets(.add_family_icon), title: "添加家庭、办公室等区域".localizedString, titleColor: .custom(.blue_2da3f6), backgroundColor: .custom(.white_ffffff))

    private lazy var loadingView = LodingView().then {
        $0.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight - Screen.k_nav_height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "家庭/公司".localizedString
        showLodingView()
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
            let vc = CreateAreaViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
            
            
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AreaListCell.reusableIdentifier, for: indexPath) as! AreaListCell
        cell.title.text = areas[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = AreaDetailViewController()
        let area = areas[indexPath.row]
        vc.area = area
        if (area.macAddr == networkStateManager.getWifiBSSID() && area.macAddr != nil) || (!area.is_bind_sa && area.cloud_user_id == 0)  {
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

extension AreaListViewController {
    private func showLodingView(){
     
     view.addSubview(loadingView)
     view.bringSubviewToFront(loadingView)
     loadingView.show()
     loadingView.snp.makeConstraints{
         $0.centerX.equalToSuperview()
         $0.centerY.equalToSuperview().offset(ZTScaleValue(-10 - Screen.bottomSafeAreaHeight))
         $0.width.equalToSuperview()
        $0.height.equalToSuperview()
     }

     }
     
     private func hideLodingView(){
         loadingView.hide()
         loadingView.removeFromSuperview()
     }

    @objc func requestNetwork() {
        /// cache
        if !authManager.isLogin {
            tableView.mj_header?.endRefreshing()
            hideLodingView()
            areas = AreaCache.areaList()
            print("--------- local cache areas ---------")
            print(areas)
            print("-------------------------------------")
            tableView.reloadData()
            return
        }
        
        ApiServiceManager.shared.areaList { [weak self] (response) in
            guard let self = self else { return }

            response.areas.forEach { $0.cloud_user_id = self.authManager.currentUser.user_id }
            AreaCache.cacheAreas(areas: response.areas)
            
            
            let areas = AreaCache.areaList()
            
            print("--------- local cache areas ---------")
            print(areas)
            print("-------------------------------------")
            /// 如果在对应的局域网环境下,将局域网内绑定过SA但未绑定到云端的家庭绑定到云端
            let checkAreas = response.areas.filter({ !$0.is_bind_sa })
            checkAreas.forEach { area in
                if let bindedArea = areas.first(where: { $0.id == area.id && $0.is_bind_sa }) {
                    /// 如果在对应的局域网内
                    if self.dependency.networkManager.getWifiBSSID() == bindedArea.macAddr {
                        ApiServiceManager.shared.bindCloud(area: bindedArea, cloud_user_id: self.authManager.currentUser.user_id, successCallback: nil, failureCallback: nil)
                    }
                }
            }
            
            self.hideLodingView()
            self.tableView.mj_header?.endRefreshing()
            self.areas = areas
            self.tableView.reloadData()
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.hideLodingView()
            self.tableView.mj_header?.endRefreshing()
            self.areas = AreaCache.areaList()
            self.tableView.reloadData()
        }

    }
    
}

