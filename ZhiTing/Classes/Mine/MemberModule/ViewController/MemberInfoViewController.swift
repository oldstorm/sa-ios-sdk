//
//  MemberInfoViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/31.
//

import UIKit

class MemberInfoViewController: BaseViewController {
    var member_id = 0
    
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
        getMemberInfo()
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(deleteButton)
        
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
        
        apiService.requestModel(.userDetail(id: member_id), modelType: User.self) { [weak self] (response) in
            guard let self = self else { return }
            self.tableView.mj_header?.endRefreshing()
            self.header.nickNameLabel.text = response.nickname
            self.roleCell.valueLabel.text = response.role_infos.map(\.name).joined(separator: "、")
            self.getRolesList(selected_roles: response.role_infos.map(\.id))
            self.checkAuthState(res: response)
            self.tableView.reloadData()
        } failureCallback: { [weak self] (code, err) in
            self?.tableView.mj_header?.endRefreshing()
            self?.showToast(string: err)
        }

    }
    
    private func checkAuthState(res: User) {
        deleteButton.isHidden = false
        roleCell.alpha = 1
        roleCell.isUserInteractionEnabled = true
        
        if res.is_creator {
            deleteButton.isHidden = true
            roleCell.alpha = 0.5
            roleCell.isUserInteractionEnabled = false
        }
        
        if res.is_self {
            deleteButton.isHidden = true
        }
        
        if !authManager.currentRolePermissions.update_area_member_role {
            deleteButton.isHidden = true
            roleCell.alpha = 0.5
            roleCell.isUserInteractionEnabled = false
        }

    }
    
    private func getRolesList(selected_roles: [Int]) {
        apiService.requestModel(.rolesList, modelType: RoleListResponse.self) { [weak self] response in
            guard let self = self else { return }
            response.roles.forEach {
                if selected_roles.contains($0.id) {
                    $0.is_selected = true
                }
            }
            
            self.changeMemberRoleAlert.setupRoles(roles: response.roles)
        }

    }
    
    private func editMemberRole(roles: [Role]) {
        let role_ids = roles.map(\.id)
        apiService.requestModel(.editMember(id: member_id, role_ids: role_ids), modelType: BaseModel.self) { [weak self] _ in
            guard let self = self else { return }
            self.roleCell.valueLabel.text = roles.map(\.name).joined(separator: "、")
            self.tableView.reloadData()

        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
        
    }
    
    private func removeMember() {
        apiService.requestModel(.deleteMember(id: member_id), modelType: BaseModel.self) { [weak self] _ in
            self?.showToast(string: "移除成功".localizedString)
            self?.navigationController?.popViewController(animated: true)

        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
        
    }
    
}

extension MemberInfoViewController {
    private class MemberInfoResponse: BaseModel {
        var user_info = User()
    }
    
    private class RoleListResponse: BaseModel {
        var roles = [Role]()
    }
    
    
}
