//
//  PrivacyViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/10/29.
//

import UIKit

class PrivacyViewController: BaseViewController {
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.estimatedSectionHeaderHeight = 0
        $0.estimatedSectionFooterHeight = 0
        $0.separatorStyle = .none
        $0.register(ValueDetailCell.self, forCellReuseIdentifier: ValueDetailCell.reusableIdentifier)

    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "用户协议和隐私政策".localizedString
    }

    override func setupViews() {
        view.addSubview(tableView)
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.left.right.bottom.equalToSuperview()
        }
    }

}


extension PrivacyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ValueDetailCell.reusableIdentifier, for: indexPath) as! ValueDetailCell

        if indexPath.row == 0 {
            cell.title.text = "用户协议".localizedString
        } else {
            cell.title.text = "隐私政策".localizedString
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let vc = WKWebViewController(link: "\(cloudUrl)/smartassitant/protocol/user")
            vc.title = "用户协议".localizedString
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = WKWebViewController(link: "\(cloudUrl)/smartassitant/protocol/privacy")
            vc.title = "隐私政策".localizedString
            navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    
}
