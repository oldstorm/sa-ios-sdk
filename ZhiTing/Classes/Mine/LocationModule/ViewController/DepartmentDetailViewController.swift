//
//  DepartmentDetailViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/15.
//

import UIKit
import AttributedString

class DepartmentDetailViewController: BaseViewController {
    var area: Area?
    var department: Location?

    private lazy var requestQueue = DispatchQueue(label: "ZhiTing.DepartmentDetailViewController.requestQueue")


    private lazy var members = [User]()

//    private lazy var companyNameLabel = Label().then {
//        $0.font = .font(size: 11, type: .regular)
//        $0.textColor = .custom(.gray_94a5be)
//    }
//
//    private lazy var arrow = ImageView().then {
//        $0.isHidden = true
//        $0.image = .assets(.arrow_right_deepGray)
//    }
    
    private lazy var locationNameLabel = Label().then {
        $0.font = .font(size: 11, type: .regular)
        $0.numberOfLines = 0
        $0.textColor = .custom(.gray_94a5be)
    }

    private lazy var emptyView = EmptyStyleView(frame: .zero, style: .noDepartmentMember).then{
        $0.container.backgroundColor = .clear
        $0.isHidden = true
    }
    
    private lazy var bottomView = DepartmentDetailBottomView()
    
    private lazy var sectionHeader = AreaMemberSectionHeader()
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.register(AreaMemberCell.self, forCellReuseIdentifier: AreaMemberCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = ZTScaleValue(50)
        $0.showsVerticalScrollIndicator = false
        if #available(iOS 15.0, *) {
            $0.sectionHeaderTopPadding = 0
        }
        $0.delegate = self
        $0.dataSource = self
        $0.bounces = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "部门".localizedString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestNetwork()
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(locationNameLabel)
        view.addSubview(tableView)
        tableView.addSubview(emptyView)
        view.addSubview(bottomView)
        
        bottomView.callback = { [weak self] type in
            guard let self = self else { return }
            switch type {
            case .departmentSetting:
                let vc = DepartmentSettingViewController()
                vc.area = self.area
                vc.department = self.department
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .addMember:
                let vc = DepartmentAddMemberViewController()
                vc.department = self.department
                vc.area = self.area
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

    }
    
    override func setupConstraints() {
        bottomView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
        }
        
        
        locationNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height + 15)
            $0.left.equalToSuperview().offset(14.5)
            $0.right.equalToSuperview().offset(-14.5)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(locationNameLabel.snp.bottom).offset(3.5)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top).offset(-15)
        }
        
        emptyView.snp.makeConstraints {
            $0.width.equalTo(tableView.snp.width)
            $0.height.equalTo(tableView.snp.height)
            $0.center.equalToSuperview()
        }
    }

}

// MARK: - NetworkRequests
extension DepartmentDetailViewController {
    private func requestNetwork() {
        guard let area = self.area, let department = self.department else { return }
        var attrStr: ASAttributedString = .init(string: "")
        attrStr += .init(string: "\(area.name) ", with: [.foreground(.custom(.gray_94a5be))])
        attrStr += .init(.image(.assets(.arrow_right_deepGray) ?? UIImage(), .custom(.center, size: CGSize(width: 4, height: 7))))
        attrStr += .init(string: " \(department.name)", with: [.foreground(.custom(.gray_94a5be))])
        locationNameLabel.attributed.text = attrStr

        if !area.is_bind_sa && area.id == nil {
            self.bottomView.setBtns(types: [.departmentSetting])
            return
        }

        showLoadingView()
        requestQueue.async { [weak self] in
            guard let self = self else { return }
            
            let sema = DispatchSemaphore(value: 0)
            
            sema.signal()
            sema.wait()
            /// 获取用户权限
            ApiServiceManager.shared.rolesPermissions(area: area, user_id: area.sa_user_id) { [weak self] response in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    var types = [DepartmentDetailBottomView.BtnType]()
                    if response.permissions.add_department_user {
                        types.append(.addMember)
                    }
                    
                    if response.permissions.update_department {
                        types.append(.departmentSetting)
                    }
                    self.bottomView.setBtns(types: types)
                    sema.signal()
                }
                
                
            } failureCallback: { [weak self] code, err in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.bottomView.setBtns(types: [])
                    sema.signal()
                }
                
            }
            
            sema.wait()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.bottomView.types.count == 0 {
                    self.bottomView.isHidden = true
                    self.tableView.snp.remakeConstraints {
                        $0.top.equalTo(self.locationNameLabel.snp.bottom).offset(3.5)
                        $0.left.right.equalToSuperview()
                        $0.bottom.equalToSuperview().offset(-15)
                    }
                } else {
                    self.bottomView.isHidden = false
                    self.tableView.snp.remakeConstraints {
                        $0.top.equalTo(self.locationNameLabel.snp.bottom).offset(3.5)
                        $0.left.right.equalToSuperview()
                        $0.bottom.equalTo(self.bottomView.snp.top).offset(-15)
                    }
                }
                sema.signal()
            }

            sema.wait()
            /// 获取成员列表
            ApiServiceManager.shared.departmentDetail(area: area, id: department.id) { [weak self] response in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.sectionHeader.titleLabel.text = "成员 ".localizedString + " (\(response.users.count)\("人".localizedString))"
                    self.members = response.users
                    self.emptyView.isHidden = (self.members.count != 0)
                    self.tableView.reloadData()
                    sema.signal()
                }
                
                
            } failureCallback: { [weak self] code, err in
                DispatchQueue.main.async { [weak self] in
                    self?.showToast(string: err)
                    sema.signal()
                }
                
            }
            
            sema.wait()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.hideLoadingView()
            }
            

        }


    }
    
}


// MARK: - TableViewDelegate & TableViewDatasource
extension DepartmentDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if members.count > 0  {
            return 45
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if members.count > 0  {
            return sectionHeader
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AreaMemberCell.reusableIdentifier, for: indexPath) as! AreaMemberCell
        cell.member = members[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = CompanyMemberInfoViewController()
        vc.area = self.area
        vc.member_id = members[indexPath.row].user_id
        navigationController?.pushViewController(vc, animated: true)
    }
    

    
}
