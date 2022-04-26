//
//  DoorLockUserManagementViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/13.
//

import UIKit

class DoorLockUserManagementViewController: BaseViewController {
    var users = ["String", "awefewf"]

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.register(DoorLockUserManagementCell.self, forCellReuseIdentifier: DoorLockUserManagementCell.reusableIdentifier)
        $0.register(DoorLockUserManagementSectionHeader.self, forHeaderFooterViewReuseIdentifier: DoorLockUserManagementSectionHeader.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        if #available(iOS 15.0, *) {
            $0.sectionHeaderTopPadding = 0
        }
    }

    private lazy var addUserBtn = Button().then {
        $0.setTitle("添加用户".localizedString, for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.layer.cornerRadius = 10
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let vc = DoorLockAddUserViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private lazy var bindVerificationBtn = Button().then {
        $0.setTitle("绑定验证".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.blue_2da3f6).cgColor
        $0.titleLabel?.font = .font(size: 14, type: .bold)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "用户管理".localizedString
    }

    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(addUserBtn)
        view.addSubview(bindVerificationBtn)
    }
    
    override func setupConstraints() {
        let btnW = (Screen.screenWidth - 45) / 2
        addUserBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
            $0.right.equalToSuperview().offset(-15)
            $0.width.equalTo(btnW)
            $0.height.equalTo(50)
        }
        
        bindVerificationBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
            $0.left.equalToSuperview().offset(15)
            $0.width.equalTo(btnW)
            $0.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(addUserBtn.snp.top).offset(-10)
        }
    }
}

extension DoorLockUserManagementViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DoorLockUserManagementCell.reusableIdentifier, for: indexPath) as! DoorLockUserManagementCell
        cell.item = users[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DoorLockUserManagementSectionHeader.reusableIdentifier) as! DoorLockUserManagementSectionHeader
        header.titleLabel.text = "管理员(3人)"
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DoorLockUserDetailViewController()
        vc.user = users[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 10))
        footer.backgroundColor = .custom(.gray_f6f8fd)
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
}
