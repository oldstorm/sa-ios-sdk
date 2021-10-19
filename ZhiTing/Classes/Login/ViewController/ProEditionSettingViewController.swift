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
    
    private lazy var saveButton = LoadingButton(title: "保存".localizedString)
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.shadowImage = UIImage()
        
        navigationBarAppearance.backgroundColor = UIColor.custom(.black_3f4663)
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.font(size: 18, type: .bold), NSAttributedString.Key.foregroundColor: UIColor.custom(.white_ffffff)]
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance

        navigationItem.title = "设置".localizedString
        navBackBtn.setImage(.assets(.nav_back_white), for: .normal)
        
        requestNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)

    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.left.right.bottom.equalToSuperview()
        }
        
        
    }
    
    private func requestNetwork() {
        self.tableView.isUserInteractionEnabled = false
        ApiServiceManager.shared.userDetail(area: authManager.currentArea, id: authManager.currentArea.sa_user_id) { [weak self] (response) in
            guard let self = self else { return }
            if response.is_set_password {
                self.userNameCell.valueLabel.text = response.account_name
                self.pwdCell.valueLabel.text = "已设置".localizedString
                self.tableView.isUserInteractionEnabled = false
            } else {
                self.userNameCell.valueLabel.text = "未设置".localizedString
                self.pwdCell.valueLabel.text = "未设置".localizedString
                self.tableView.isUserInteractionEnabled = true
            }

            self.tableView.reloadData()

        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            if self.authManager.currentArea.setAccount ?? false {
                self.userNameCell.valueLabel.text = self.authManager.currentArea.accountName
                self.pwdCell.valueLabel.text = "已设置".localizedString
                self.tableView.isUserInteractionEnabled = false
            } else {
                self.userNameCell.valueLabel.text = "未设置".localizedString
                self.pwdCell.valueLabel.text = "未设置".localizedString
                self.tableView.isUserInteractionEnabled = true
            }
            
            self.tableView.reloadData()
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




