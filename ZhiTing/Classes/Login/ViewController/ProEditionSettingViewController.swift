//
//  ProEditionSettingViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/19.
//

import UIKit


class ProEditionSettingViewController: BaseViewController {
    private lazy var header = UIView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 40)).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        let label = Label()
        label.text = "可用以下用户名和密码登录网页专业版".localizedString
        label.font = .font(size: 12, type: .regular)
        label.textColor = .custom(.gray_94a5be)
        label.lineBreakMode = .byTruncatingTail
        
        $0.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(ZTScaleValue(15))
        }
    }

    private lazy var userNameCell = ValueDetailCell().then {
        $0.title.text = "用户名".localizedString
        
    }
    
    private lazy var pwdCell = ValueDetailCell().then {
        $0.title.text = "密码".localizedString
        
    }

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = UITableView.automaticDimension
        $0.isScrollEnabled = false
        $0.tableHeaderView = header
    }
    
    private lazy var saveButton = OnNextButton(title: "保存".localizedString)
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "设置".localizedString
        navBackBtn.setImage(.assets(.nav_back_white), for: .normal)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.font(size: 18, type: .bold), NSAttributedString.Key.foregroundColor: UIColor.custom(.white_ffffff)]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if authManager.currentSA.is_set_password {
            userNameCell.valueLabel.text = authManager.currentSA.account_name
            pwdCell.valueLabel.text = "已设置".localizedString
            tableView.isUserInteractionEnabled = false
        } else {
            userNameCell.valueLabel.text = "未设置".localizedString
            pwdCell.valueLabel.text = "未设置".localizedString
            tableView.isUserInteractionEnabled = true
        }

    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)

    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        
    }

}

extension ProEditionSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return userNameCell
        } else {
            return pwdCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = SetProAccountViewController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}



