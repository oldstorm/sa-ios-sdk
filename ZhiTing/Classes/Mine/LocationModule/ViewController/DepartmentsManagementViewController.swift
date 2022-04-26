//
//  DepartmentsManagementViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/15.
//
import UIKit

class DepartmentsManagementViewController: BaseViewController {
    
    var rolePermission = RolePermission()
    

    var area = Area()
    
    /// 部门
    lazy var departments = [Location]()
    
    var isEditingCell = false {
        didSet {
            if isEditingCell {
                navRightButton.setTitle("完成".localizedString, for: .normal)
                addLocationButton.isHidden = true
                tableView.snp.remakeConstraints {
                    $0.top.equalTo(companyNameLabel.snp.bottom).offset(10)
                    $0.left.right.equalToSuperview()
                    $0.bottom.equalToSuperview()
                }
                tableView.mj_header?.removeFromSuperview()
                tableView.isEditing = true
                
            } else {
                checkAuth()
                setLocationOrder()
                navRightButton.setTitle("编辑".localizedString, for: .normal)
                tableView.snp.remakeConstraints {
                    $0.top.equalTo(companyNameLabel.snp.bottom).offset(10)
                    $0.left.right.equalToSuperview()
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
    
    private lazy var companyNameLabel = Label().then {
        $0.font = .font(size: 11, type: .regular)
        $0.numberOfLines = 0
        $0.textColor = .custom(.gray_94a5be)
    }

    private lazy var addLocationButton = ImageTitleButton(frame: .zero, icon: .assets(.plus_blue), title: "添加部门".localizedString, titleColor: UIColor.custom(.blue_2da3f6), backgroundColor: UIColor.custom(.white_ffffff))
    
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

    private lazy var emptyView = EmptyStyleView(frame: .zero, style: .noDepartment).then{
        $0.container.backgroundColor = .clear
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "部门".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightButton)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestNetwork()
    }

    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(addLocationButton)
        view.addSubview(companyNameLabel)
        view.addSubview(tableView)
        tableView.addSubview(emptyView)
        emptyView.isHidden = true
        
        navRightButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.isEditingCell = !self.isEditingCell
        }
        
        addLocationButton.clickCallBack = { [weak self] in
            guard let self = self else { return }
            let addAreaAlertView = InputAlertView(labelText: "部门名称".localizedString, placeHolder: "请输入部门名称".localizedString) { [weak self] text in
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
        
        companyNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height + 15)
            $0.left.equalToSuperview().offset(14.5)
            $0.right.equalToSuperview().offset(-14.5)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(companyNameLabel.snp.bottom).offset(10)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(addLocationButton.snp.top).offset(-15)
        }
        
        emptyView.snp.makeConstraints {
            $0.width.equalTo(tableView)
            $0.height.equalTo(tableView)
            $0.center.equalToSuperview()
        }
    }

}

extension DepartmentsManagementViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationsManagementCell.reusableIdentifier, for: indexPath) as! LocationsManagementCell
        cell.title.text = departments[indexPath.row].name
        cell.arrow.isHidden = isEditingCell
        cell.numsLabel.isHidden = isEditingCell
        if departments[indexPath.row].user_count > 0 {
            cell.numsLabel.text = "\(departments[indexPath.row].user_count)" + "人 ".localizedString
        } else {
            cell.numsLabel.text = " "
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !rolePermission.get_department && !area.sa_user_token.contains("unbind") {
            showToast(string: "没有权限".localizedString)
            return
        }

        if !isEditingCell {
            let vc = DepartmentDetailViewController()
            vc.area = area
            vc.department = departments[indexPath.row]
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}


extension DepartmentsManagementViewController {
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        departments.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        self.tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }

}


extension DepartmentsManagementViewController {


    @objc func requestNetwork() {
        companyNameLabel.text = area.name
        /// auth
        getRolePermission()

        /// cache
        if !area.is_bind_sa && !UserManager.shared.isLogin {
            tableView.mj_header?.endRefreshing()
            hideLoadingView()
            departments = LocationCache.areaLocationList(area_id: area.id, sa_token: area.sa_user_token).sorted(by: { (l1, l2) -> Bool in
                return l1.sort < l2.sort
            })
            emptyView.isHidden = !(departments.count == 0)
            tableView.reloadData()
            return
        }

        showLoadingView()
        ApiServiceManager.shared.departmentList(area: area) { [weak self] (response) in
            self?.tableView.mj_header?.endRefreshing()
            self?.departments = response.departments
            self?.emptyView.isHidden = !(response.departments.count == 0)
            self?.hideLoadingView()
            self?.tableView.reloadData()
        } failureCallback: { [weak self] code, err in
            self?.showToast(string: err)
            self?.hideLoadingView()
            self?.tableView.mj_header?.endRefreshing()
        }
        
    }
    
    func addLocation(name: String) {
        if departments.map(\.name).contains(name) {
            let text = getCurrentLanguage() == .chinese ? "\(name)已存在" : "\(name) already existed"
            self.showToast(string: text)
            return
        }
        
        /// cache
        if !area.is_bind_sa && !UserManager.shared.isLogin {
            LocationCache.addLocationToArea(area_id: area.id, name: name, sa_token: area.sa_user_token)
            requestNetwork()
            addAreaAlertView?.removeFromSuperview()
            return
        }
        
        addAreaAlertView?.saveButton.selectedChangeView(isLoading: true)
        ApiServiceManager.shared.addDepartment(area: area, name: name) { [weak self] (response) in
            self?.addAreaAlertView?.saveButton.selectedChangeView(isLoading: true)
            self?.requestNetwork()
            self?.addAreaAlertView?.removeFromSuperview()
        } failureCallback: { [weak self] (code, err) in
            self?.addAreaAlertView?.saveButton.selectedChangeView(isLoading: false)
            self?.showToast(string: err)
        }

    }
    
    func setLocationOrder() {
        let orderArray = departments.map(\.id)
        
        /// cache
        if !area.is_bind_sa && !UserManager.shared.isLogin {
            LocationCache.setLocationOrder(area_id: area.id, orderArray: orderArray, sa_token: area.sa_user_token)
            showToast(string: "编辑成功".localizedString)
            return
        }
        

        ApiServiceManager.shared.setDepartmentOrders(area: area, department_order: orderArray) { [weak self] response in
            guard let self = self else { return }
            LocationCache.setLocationOrder(area_id: self.area.id, orderArray: orderArray, sa_token: self.area.sa_user_token)
            self.showToast(string: "编辑成功".localizedString)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.requestNetwork()
        }

        
        
    }
    
}

extension DepartmentsManagementViewController {
    private func getRolePermission() {
        if area.id == nil {
            checkAuth()
            return
        }

        ApiServiceManager.shared.rolesPermissions(area: area, user_id: area.sa_user_id) { [weak self] response in
            guard let self = self else { return }
            self.rolePermission = response.permissions
            self.checkAuth()
            
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.rolePermission = RolePermission()
            self.checkAuth()
        }

    }
    
    private func checkAuth() {
        if area.id == nil {
            addLocationButton.isHidden = false
            tableView.snp.remakeConstraints {
                $0.top.left.right.equalToSuperview()
                $0.bottom.equalTo(addLocationButton.snp.top).offset(-15)
                
            }
            return
        }
        
        if rolePermission.update_department_order {
            navRightButton.isHidden = false
        } else {
            navRightButton.isHidden = true
        }

        
        
        if rolePermission.add_department {
            addLocationButton.isHidden = false
            tableView.snp.remakeConstraints {
                $0.top.equalTo(companyNameLabel.snp.bottom).offset(10)
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(addLocationButton.snp.top).offset(-15)
                
            }
        } else {
            addLocationButton.isHidden = true
            tableView.snp.remakeConstraints {
                $0.top.equalTo(companyNameLabel.snp.bottom).offset(10)
                $0.left.right.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        }
        
        
    }
}


