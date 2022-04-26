//
//  DepartmentAddMemberViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/17.
//

import UIKit


class DepartmentAddMemberViewController: BaseViewController {
    var area: Area?
    var department: Location?

    private lazy var members = [User]()
    
    private var selectedMembers: [User] {
        return members.filter({ $0.isSelected })
    }
    
    private lazy var saveButton = DoneButton(frame: CGRect(x: 0, y: 0, width: 50, height: 25)).then {
        $0.setTitle("确定".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: 12, type: .regular)
        $0.isEnhanceClick = true
        $0.isEnabled = false
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.save()
        }
    }
    
    private lazy var selectedHeader = DepartmentAddMemberHeader()
    
    private lazy var tableViewHeader = UIView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 10)).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.dataSource = self
        $0.delegate = self
        $0.register(DepartmentAddMemberCell.self, forCellReuseIdentifier: DepartmentAddMemberCell.reusableIdentifier)
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.showsVerticalScrollIndicator = false

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "添加成员".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestNetwork()
    }

    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(selectedHeader)
        view.addSubview(tableViewHeader)
        view.addSubview(tableView)
        
        selectedHeader.cancellCallback = { [weak self] member in
            guard let self = self else { return }
            self.members.first(where: { $0.user_id == member.user_id })?.isSelected = false
            self.tableView.reloadData()
            self.updateSelectedHeader()
        }
    }
    
    override func setupConstraints() {
        selectedHeader.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        tableViewHeader.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(10)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(tableViewHeader.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }

    }

    func updateSelectedHeader() {
        if selectedMembers.count != 0 {
            tableViewHeader.snp.remakeConstraints {
                $0.top.equalTo(selectedHeader.snp.bottom)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(10)
            }
        } else {
            tableViewHeader.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(Screen.k_nav_height)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(10)
            }
        }
        
        saveButton.isEnabled = (selectedMembers.count > 0)
        selectedHeader.update(selectedMembers)
        if selectedMembers.count > 0 {
            saveButton.setTitle("确定(\(selectedMembers.count))", for: .normal)
        } else {
            saveButton.setTitle("确定", for: .normal)
        }
        
    }

}

extension DepartmentAddMemberViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DepartmentAddMemberCell.reusableIdentifier, for: indexPath) as! DepartmentAddMemberCell
        cell.member = members[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        members[indexPath.row].isSelected = !members[indexPath.row].isSelected
        tableView.reloadRows(at: [indexPath], with: .automatic)
        updateSelectedHeader()
    }
}

extension DepartmentAddMemberViewController {
    
    private func requestNetwork() {
        guard let area = area, let department = department else { return }
        showLoadingView()
        ApiServiceManager.shared.memberList(area: area) { [weak self] response in
            guard let self = self else { return }
            self.members = response.users
            self.tableView.reloadData()
            
            ApiServiceManager.shared.departmentDetail(area: area, id: department.id) { [weak self] department in
                guard let self = self else { return }
                self.members.forEach { member in
                    if department.users.contains(where: { $0.user_id == member.user_id }) {
                        member.isSelected = true
                    }
                }
               
                self.tableView.reloadData()
                self.updateSelectedHeader()
                self.hideLoadingView()

            } failureCallback: { [weak self] code, err in
                self?.hideLoadingView()
                self?.showToast(string: err)
            }

            
            
        } failureCallback: { [weak self] code, err in
            self?.showToast(string: err)
            self?.hideLoadingView()
        }
    }

    private func save() {
        guard let area = area, let department = department else { return }
        
        showLoadingView()
        ApiServiceManager.shared.addDepartmentMembers(area: area, id: department.id, users: selectedMembers.map(\.user_id)) { [weak self] response in
            self?.showToast(string: "添加成功".localizedString)
            self?.hideLoadingView()
            self?.navigationController?.popViewController(animated: true)

        } failureCallback: { [weak self] code, err in
            self?.showToast(string: err)
            self?.hideLoadingView()
        }


    }
}
