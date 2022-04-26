//
//  AccountSettingViewcontroller.swift
//  ZhiTing
//
//  Created by iMac on 2022/1/5.
//

import UIKit

class AccountSettingViewcontroller: BaseViewController {
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.separatorStyle = .none
        $0.rowHeight = 60
        $0.register(ValueDetailCell.self, forCellReuseIdentifier: ValueDetailCell.reusableIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "账号与安全".localizedString
    }
    
    override func setupViews() {
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}

extension AccountSettingViewcontroller: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ValueDetailCell.reusableIdentifier, for: indexPath) as! ValueDetailCell
        if indexPath.row == 0 {
            cell.title.text = "密码修改".localizedString
        } else {
            cell.title.text = "账号注销".localizedString
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = ChangePWDViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UnregisterViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
