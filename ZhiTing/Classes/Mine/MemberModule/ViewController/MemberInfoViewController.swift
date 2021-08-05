//
//  MemberInfoViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/31.
//

import UIKit

class MemberInfoViewController: BaseViewController {
    var member_id = 0

    var area = Area()
    
    var isCreator = false
    
    var rolePermission = RolePermission() {
        didSet {
            checkAuthState()
            
        }
    }
    
    var member: User? {
        didSet {
            guard let member = member else { return }
            header.nickNameLabel.text = member.nickname
            roleCell.valueLabel.text = member.role_infos.map(\.name).joined(separator: "、")
            if roleCell.valueLabel.text == "" {
                roleCell.valueLabel.text = " "
            }
            
            checkAuthState()
        }
    }

    
    private lazy var header = MemberInfoHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 120))
    
    private lazy var roleCell = MemberInfoRoleCell()
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.rowHeight = UITableView.automaticDimension
        $0.tableHeaderView = header
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var deleteButton = ImageTitleButton(frame: .zero, icon: nil, title: "删除成员".localizedString, titleColor: .custom(.black_3f4663), backgroundColor: .custom(.white_ffffff)).then {
        $0.isHidden = true
        $0.clickCallBack = { [weak self] in
            TipsAlertView.show(message: "确定要移除该成员吗?", sureCallback: { [weak self] in
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
            vc.area = self.area
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getRolePermission()
        getMemberInfo()
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(deleteButton)
        view.addSubview(transferButton)
        
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(getMemberInfo))
        
        changeMemberRoleAlert.callback = { [weak self] roles in
            self?.editMemberRole(roles: roles)
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

}

extension MemberInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return roleCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        SceneDelegate.shared.window?.addSubview(changeMemberRoleAlert)
    }
}


extension MemberInfoViewController {
    @objc private func getMemberInfo() {
        
        ApiServiceManager.shared.userDetail(area: area, id: member_id) { [weak self] (member) in
            guard let self = self else { return }
            self.tableView.mj_header?.endRefreshing()
            self.member = member
            self.getRolesList(selected_roles: member.role_infos.map(\.id))
            self.tableView.reloadData()
        } failureCallback: { [weak self] (code, err) in
            self?.tableView.mj_header?.endRefreshing()
            self?.showToast(string: err)
        }


    }
    
    private func checkAuthState() {
        deleteButton.isHidden = false
        transferButton.isHidden = true
        
        roleCell.alpha = 1
        roleCell.isUserInteractionEnabled = true
        
        if !rolePermission.update_area_member_role || isCreator {
            roleCell.alpha = 0.5
            roleCell.isUserInteractionEnabled = false
        }
        
        if !rolePermission.delete_area_member {
            deleteButton.isHidden = true
        }

        guard let member = member else { return }

        isCreator = member.is_owner
        if isCreator {
            deleteButton.isHidden = true
            roleCell.alpha = 0.5
            roleCell.isUserInteractionEnabled = false
        }
        
        if member.is_self {
            deleteButton.isHidden = true
            if isCreator {//当自己为拥有者时候，可以转移
                transferButton.isHidden = false
            }
        }
        

    }
    
    private func getRolesList(selected_roles: [Int]) {
        ApiServiceManager.shared.rolesList(area: area) { [weak self] response in
            guard let self = self else { return }
            response.roles.forEach {
                if selected_roles.contains($0.id) {
                    $0.is_selected = true
                }
            }
            
            self.changeMemberRoleAlert.setupRoles(roles: response.roles)
        } failureCallback: { code, err in
            
        }

    }
    
    private func editMemberRole(roles: [Role]) {
        let role_ids = roles.map(\.id)
        ApiServiceManager.shared.editMember(area: area, id: member_id, role_ids: role_ids) { [weak self] _ in
            guard let self = self else { return }
            self.roleCell.valueLabel.text = roles.map(\.name).joined(separator: "、")
            self.tableView.reloadData()

        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }

        
    }
    
    private func removeMember() {
        ApiServiceManager.shared.deleteMember(area: area, id: member_id) { [weak self] _ in
            self?.showToast(string: "移除成功".localizedString)
            self?.navigationController?.popViewController(animated: true)

        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
        
    }
    
    private func getRolePermission() {
        ApiServiceManager.shared.rolesPermissions(area: area, user_id: area.sa_user_id) { [weak self] response in
            guard let self = self else { return }
            self.rolePermission = response.permissions
            self.checkAuthState()
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.rolePermission = RolePermission()
            
        }

    }
    
}

extension MemberInfoViewController {
    
    private class MemberInfoResponse: BaseModel {
        var user_info = User()
    }
    
}
