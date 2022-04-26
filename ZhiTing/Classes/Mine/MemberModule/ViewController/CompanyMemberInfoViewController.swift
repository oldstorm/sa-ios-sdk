//
//  CompanyMemberInfoViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/17.
//


import UIKit

class CompanyMemberInfoViewController: BaseViewController {
    private lazy var requestQueue = DispatchQueue(label: "ZhiTing.CompanyMemberInfoViewController.requestQueue")
    

    var member_id = 0
    var area: Area?
    var rolePermission = RolePermission() {
        didSet {
            checkAuthState()
            
        }
    }
    
    var member: User?

    
    lazy var header = MemberInfoHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 120))
    private lazy var roleCell = MemberInfoCell(type: .role)
    private lazy var departmentCell = MemberInfoCell(type: .department)
    
    private lazy var changeMemberDepartmentAlert = ChangeMemberDepartmentAlert()
    private var deleteTipsAlert: TipsAlertView?

    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.rowHeight = UITableView.automaticDimension
        $0.tableHeaderView = header
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var saveButton = DoneButton(frame: CGRect(x: 0, y: 0, width: 50, height: 25)).then {
        $0.setTitle("保存".localizedString, for: .normal)
        $0.isEnhanceClick = true
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.save()
        }
        
    }
    
    private lazy var deleteButton = ImageTitleButton(frame: .zero, icon: nil, title: "删除成员".localizedString, titleColor: .custom(.black_3f4663), backgroundColor: .custom(.white_ffffff)).then {
        $0.isHidden = true
        $0.clickCallBack = { [weak self] in
            self?.deleteTipsAlert = TipsAlertView.show(message: "确定要移除该成员吗?", sureCallback: { [weak self] in
                self?.removeMember()
            }, cancelCallback: nil)
        }
    }
    
    private lazy var transferButton = ImageTitleButton(frame: .zero, icon: nil, title: "转移拥有者".localizedString, titleColor: .custom(.black_3f4663), backgroundColor: .custom(.white_ffffff)).then {
        $0.isHidden = true
        $0.clickCallBack = { [weak self] in
            guard let self = self else {
                return
            }
            let vc = TransferOwnerController()
            vc.area = self.area ?? Area()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    private lazy var changeMemberRoleAlert = ChangeMemberRoleAlert(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "成员信息".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        requestNetwork()
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(deleteButton)
        view.addSubview(transferButton)
        
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
        changeMemberRoleAlert.callback = { [weak self] roles in
            self?.roleCell.valueLabel.text = roles.map(\.name).joined(separator: "、")
        }

        
        changeMemberDepartmentAlert.selectCallback = { [weak self] departments in
            guard let self = self else { return }
            self.departmentCell.valueLabel.text = departments.map(\.name).joined(separator: "、")
            if self.departmentCell.valueLabel.text == "" {
                self.departmentCell.valueLabel.text = "未划分".localizedString
            }
        }

    }
    
    override func setupConstraints() {
        deleteButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }
        
        transferButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }

        
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(deleteButton.snp.top)
        }
    }
    
    
    override func navPop() {
        let beforeRoleIds = member?.role_infos.map(\.id).map { String($0) }.joined(separator: " ")
        let afterRoleIds = changeMemberRoleAlert.selectedRoles.map(\.id).map { String($0) }.joined(separator: " ")
        let beforeDepartmentIds = member?.department_infos.map(\.id).map { String($0) }.joined(separator: " ")
        let afterDepartmentIds =  changeMemberDepartmentAlert.selectedDepartments.map(\.id).map { String($0) }.joined(separator: " ")

        let ifAfterEdit = (beforeRoleIds != afterRoleIds || beforeDepartmentIds != afterDepartmentIds)

        if ifAfterEdit {
            TipsAlertView.show(message: "信息未保存,是否退出".localizedString) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let beforeRoleIds = member?.role_infos.map(\.id).map { String($0) }.joined(separator: " ")
        let afterRoleIds = changeMemberRoleAlert.selectedRoles.map(\.id).map { String($0) }.joined(separator: " ")
        let beforeDepartmentIds = member?.department_infos.map(\.id).map { String($0) }.joined(separator: " ")
        let afterDepartmentIds =  changeMemberDepartmentAlert.selectedDepartments.map(\.id).map { String($0) }.joined(separator: " ")

        let ifAfterEdit = (beforeRoleIds != afterRoleIds || beforeDepartmentIds != afterDepartmentIds)

        if ifAfterEdit {
            TipsAlertView.show(message: "信息未保存,是否退出".localizedString) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return false
        } else {
            return true
        }
        
    }

}

extension CompanyMemberInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return roleCell
        } else {
            return departmentCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            if let roles = member?.role_infos {
                changeMemberRoleAlert.selectedRoles = roles
            }
            
            SceneDelegate.shared.window?.addSubview(changeMemberRoleAlert)
        } else {
            if let department_infos = member?.department_infos {
                changeMemberDepartmentAlert.selectedDepartments = department_infos
            }
            
            SceneDelegate.shared.window?.addSubview(changeMemberDepartmentAlert)
        }
        
    }
}

extension CompanyMemberInfoViewController {
    @objc private func requestNetwork() {
        guard let area = area else { return }
        showLoadingView()
        tableView.mj_header?.endRefreshing()
        
        requestQueue.async { [weak self] in
            guard let self = self else { return }
            let sema = DispatchSemaphore(value: 0)
            sema.signal()
            
            sema.wait()
            /// 获取权限
            ApiServiceManager.shared.rolesPermissions(area: area, user_id: area.sa_user_id) { [weak self] response in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.rolePermission = response.permissions
                    sema.signal()
                }
            } failureCallback: { code, err in
                sema.signal()
            }

            sema.wait()
            /// 获取用户信息
            ApiServiceManager.shared.userDetail(area: area, id: self.member_id) { [weak self] (member) in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.member = member
                    self.header.nickNameLabel.text = member.nickname
                    self.header.avatar.setImage(urlString: member.avatar_url, placeHolder: .assets(.default_avatar))
                    self.roleCell.valueLabel.text = member.role_infos.map(\.name).joined(separator: "、")
                    self.departmentCell.valueLabel.text = member.department_infos.map(\.name).joined(separator: "、")
                    if self.roleCell.valueLabel.text == "" {
                        self.roleCell.valueLabel.text = " "
                    }
                    if self.departmentCell.valueLabel.text == "" {
                        self.departmentCell.valueLabel.text = "未划分".localizedString
                    }
                    self.changeMemberRoleAlert.selectedRoles = member.role_infos
                    self.changeMemberDepartmentAlert.selectedDepartments = member.department_infos
                    
                    sema.signal()
                }
                
            } failureCallback: { (code, err) in
                sema.signal()
            }
            
            sema.wait()
            /// 获取角色列表
            ApiServiceManager.shared.rolesList(area: area) { [weak self] response in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.changeMemberRoleAlert.setupRoles(roles: response.roles)
                    sema.signal()
                    
                }
            } failureCallback: { code, err in
                sema.signal()
            }
            
            sema.wait()
            /// 获取部门列表
            ApiServiceManager.shared.departmentList(area: area) { [weak self] (response) in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.changeMemberDepartmentAlert.locations = response.departments
                    sema.signal()
                }
            } failureCallback: { code, err in
                sema.signal()
            }
            
            sema.wait()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.checkAuthState()
                self.hideLoadingView()
            }


        }
        

    }

}


extension CompanyMemberInfoViewController {
    
    private func checkAuthState() {
        deleteButton.isHidden = false
        transferButton.isHidden = true
        
        roleCell.alpha = 1
        roleCell.isUserInteractionEnabled = true
        departmentCell.alpha = 1
        departmentCell.isUserInteractionEnabled = true
        
        if !rolePermission.update_area_member_role || member?.is_owner == true {
            roleCell.alpha = 0.5
            roleCell.isUserInteractionEnabled = false
        }
        
        if !rolePermission.update_area_member_department {
            departmentCell.alpha = 0.5
            departmentCell.isUserInteractionEnabled = false
        }
        
        if !rolePermission.delete_area_member {
            deleteButton.isHidden = true
        }

        guard let member = member else { return }

        roleCell.arrow.isHidden = member.is_owner
        if member.is_owner {
            deleteButton.isHidden = true
            roleCell.alpha = 0.5
            roleCell.isUserInteractionEnabled = false
            
        }
        
        if member.is_self {
            deleteButton.isHidden = true
            if member.is_owner == true {//当自己为拥有者时候，可以转移
                transferButton.isHidden = false
            }
        }
        

    }
    
    private func getRolesList(selected_roles: [Int]) {
        guard let area = area else { return }
        ApiServiceManager.shared.rolesList(area: area) { [weak self] response in
            guard let self = self else { return }
            self.changeMemberRoleAlert.setupRoles(roles: response.roles)
        } failureCallback: { code, err in
            
        }

    }
    
    private func save() {
        guard let area = area else { return }
        var roles = changeMemberRoleAlert.selectedRoles
        let deparments = changeMemberDepartmentAlert.selectedDepartments
        if member?.is_owner == true {
            roles = [Role]()
        }
        showLoadingView()
        ApiServiceManager.shared.editMember(area: area, id: member_id, role_ids: roles.map(\.id), department_ids: deparments.map(\.id)) { [weak self] _ in
            guard let self = self else { return }
            self.member?.role_infos = roles
            self.member?.department_infos = deparments
            self.hideLoadingView()
            self.showToast(string: "保存成功".localizedString)
            self.navigationController?.popViewController(animated: true)

        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.hideLoadingView()
            self.showToast(string: err)
        }

        
    }
    
    
    private func removeMember() {
        guard let area = area else { return }
        showLoadingView()
        ApiServiceManager.shared.deleteMember(area: area, id: member_id) { [weak self] _ in
            self?.showToast(string: "移除成功".localizedString)
            self?.hideLoadingView()
            self?.navigationController?.popViewController(animated: true)

        } failureCallback: { [weak self] (code, err) in
            self?.hideLoadingView()
            self?.showToast(string: err)
        }
        
    }
    
    
}

