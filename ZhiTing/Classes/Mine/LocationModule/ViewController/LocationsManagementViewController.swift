//
//  AreasManageViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/15.
//

import UIKit

class LocationsManagementViewController: BaseViewController {
    var sa_token = ""

    var area_id: Int?
    
    lazy var locations = [Location]()
    
    var isEditingCell = false {
        didSet {
            if isEditingCell {
                navRightButton.setTitle("完成".localizedString, for: .normal)
                addLocationButton.isHidden = true
                tableView.snp.remakeConstraints {
                    $0.top.left.right.equalToSuperview()
                    $0.bottom.equalToSuperview()
                }
                tableView.mj_header?.removeFromSuperview()
                tableView.isEditing = true
                
            } else {
                setLocationOrder()
                navRightButton.setTitle("编辑".localizedString, for: .normal)
                addLocationButton.isHidden = false
                tableView.snp.remakeConstraints {
                    $0.top.left.right.equalToSuperview()
                    $0.bottom.equalTo(addLocationButton.snp.top).offset(-15)
                }
                
                let header = ZTGIFRefreshHeader()
                tableView.mj_header = header
                tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
                
                tableView.isEditing = false
            }
            
            tableView.reloadData()
        }
    }
    
    private lazy var navRightButton = Button().then {
        $0.setTitle("编辑".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        if getCurrentLanguage() == .chinese {
            $0.titleLabel?.font = .font(size: 14, type: .bold)
        } else {
            $0.titleLabel?.font = .font(size: 12, type: .bold)
        }
        
    }

    private lazy var addLocationButton = ImageTitleButton(frame: .zero, icon: .assets(.plus_blue), title: "添加房间/区域".localizedString, titleColor: UIColor.custom(.blue_2da3f6), backgroundColor: UIColor.custom(.white_ffffff))
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.register(LocationsManagementCell.self, forCellReuseIdentifier: LocationsManagementCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 60
        $0.delegate = self
        $0.dataSource = self
    }
    
    var addAreaAlertView: InputAlertView?

    private lazy var emptyView = EmptyStyleView(frame: .zero, style: .noRoom)

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "房间/区域管理".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if locations.count == 0 {
            tableView.es.startPullToRefresh()
        } else {
            requestNetwork()
        }
        
    }

    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(addLocationButton)
        view.addSubview(tableView)
        tableView.addSubview(emptyView)
        emptyView.isHidden = true
        
        navRightButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.isEditingCell = !self.isEditingCell
        }
        
        addLocationButton.clickCallBack = { [weak self] in
            guard let self = self else { return }
            let addAreaAlertView = InputAlertView(labelText: "房间/区域名称".localizedString, placeHolder: "请输入房间/区域名称".localizedString) { [weak self] text in
                guard let self = self else { return }
                self.addLocation(name: text)
            }
            
            self.addAreaAlertView = addAreaAlertView
            
            SceneDelegate.shared.window?.addSubview(addAreaAlertView)
        }
                
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
       
    }
    
    override func setupConstraints() {
        addLocationButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
        }
        
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(addLocationButton.snp.top).offset(-15)
        }
        
        emptyView.snp.makeConstraints {
            $0.width.equalTo(tableView)
            $0.height.equalTo(tableView)
            $0.center.equalToSuperview()
        }
    }

}

extension LocationsManagementViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationsManagementCell.reusableIdentifier, for: indexPath) as! LocationsManagementCell
        cell.title.text = locations[indexPath.row].name
        cell.arrow.isHidden = isEditingCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !authManager.currentRolePermissions.get_location && !sa_token.contains("unbind") {
            showToast(string: "没有权限".localizedString)
            return
        }

        if !isEditingCell {
            let vc = LocationDetailViewController()
            vc.sa_token = sa_token
            vc.location_id = locations[indexPath.row].id
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
}


extension LocationsManagementViewController {
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        locations.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        self.tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }

}


extension LocationsManagementViewController {
    @objc func requestNetwork() {
        /// auth
        checkAuth()
        
        guard let id = area_id else { return }
        
        /// cache
        if sa_token.contains("unbind") {
            tableView.mj_header?.endRefreshing()
            locations = LocationCache.areaLocationList(area_id: id, sa_token: sa_token).sorted(by: { (l1, l2) -> Bool in
                return l1.sort < l2.sort
            })
            emptyView.isHidden = !(locations.count == 0)
            tableView.reloadData()
            return
        }

        apiService.requestModel(.areaLocationsList, modelType: AreaDetailResponse.self) { [weak self] (response) in
            self?.tableView.mj_header?.endRefreshing()
            self?.locations = response.locations
            self?.emptyView.isHidden = !(response.locations.count == 0)
            self?.tableView.reloadData()
        }
    }
    
    func addLocation(name: String) {
        guard let id = area_id else {
            return
        }
        
        if locations.map(\.name).contains(name) {
            let text = getCurrentLanguage() == .chinese ? "\(name)已存在" : "\(name) already existed"
            self.showToast(string: text)
            return
        }
        
        /// cache
        if sa_token.contains("unbind") {
            LocationCache.addLocationToArea(area_id: id, name: name, sa_token: sa_token)
            requestNetwork()
            addAreaAlertView?.removeFromSuperview()
            return
        }
        
        apiService.requestModel(.addLocation(name: name), modelType: BaseModel.self) { [weak self] (response) in
            self?.requestNetwork()
            self?.addAreaAlertView?.removeFromSuperview()
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
    }
    
    func setLocationOrder() {
        guard let area_id = area_id else { return }
        let orderArray = locations.map(\.id)
        
        /// cache
        if sa_token.contains("unbind") {
            LocationCache.setAreaOrder(area_id: area_id, orderArray: orderArray, sa_token: sa_token)
            return
        }

        apiService.requestModel(.setLocationOrders(location_order: orderArray), modelType: BaseModel.self) { [weak self] response in
            guard let self = self else { return }
            LocationCache.setAreaOrder(area_id: area_id, orderArray: orderArray, sa_token: self.sa_token)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.requestNetwork()
        }
        
    }
    
}

extension LocationsManagementViewController {
    private func checkAuth() {
        if sa_token.contains("unbind") {
            return
        }
        
        if authManager.currentRolePermissions.update_location_order {
            navRightButton.isHidden = false
        } else {
            navRightButton.isHidden = true
        }

        
        
        if authManager.currentRolePermissions.add_location {
            addLocationButton.isHidden = false
            tableView.snp.remakeConstraints {
                $0.top.left.right.equalToSuperview()
                $0.bottom.equalTo(addLocationButton.snp.top).offset(-15)
                
            }
        } else {
            addLocationButton.isHidden = true
            tableView.snp.remakeConstraints {
                $0.top.left.right.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        }
        
        
    }
}

extension LocationsManagementViewController {
    private class AreaDetailResponse: BaseModel {
        var locations = [Location]()
    }
    

}

