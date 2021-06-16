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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "家庭/公司".localizedString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if areas.count == 0 {
            tableView.mj_header?.beginRefreshing()
        } else {
            requestNetwork()
        }
        
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
        vc.area = areas[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension AreaListViewController {
    @objc func requestNetwork() {
        /// cache
        if authManager.currentSA.token == "" || !authManager.isSAEnviroment {
            tableView.mj_header?.endRefreshing()
            areas = AreaCache.areaList()
            tableView.reloadData()
            return
        }

        apiService.requestModel(.areaList, modelType: AreaListReponse.self) { [weak self] (response) in
            guard let self = self else { return }

            response.areas.forEach { $0.sa_token = self.authManager.currentSA.token }
            AreaCache.cacheAreas(areas: response.areas)
            
            
            let areas = AreaCache.areaList()
            
            self.tableView.mj_header?.endRefreshing()
            self.areas = areas
            self.tableView.reloadData()
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.tableView.mj_header?.endRefreshing()
            self.areas = AreaCache.areaList()
            self.tableView.reloadData()
        }
    }
    
}

extension AreaListViewController {
    private class AreaListReponse: BaseModel {
        var areas = [Area]()
    }
}
