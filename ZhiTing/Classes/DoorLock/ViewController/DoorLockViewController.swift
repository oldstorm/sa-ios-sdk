//
//  DoorLockViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/1.
//

import Foundation
import UIKit

class DoorLockViewController: BaseViewController {
    
    private lazy var headCell = DoorLockHeadCell()
    
    private lazy var warningCell = DoorLockHomeWarningCell()
    
    private lazy var logCell = DoorLockHomeLogCell()
    
    private lazy var settingButton = Button().then {
        $0.setImage(.assets(.settings), for: .normal)
        $0.frame.size = CGSize(width: 18, height: 18)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            
        }
    }
    
    private lazy var bleStatusButton = BleStatusButton().then {
        $0.isOnline = false
    }

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.contentInset.bottom = 10
    }
    
    private lazy var bottomDrawer = UIView().then {
        let img = ImageView()
        img.image = .assets(.icon_menu)
        img.contentMode = .scaleAspectFit
        $0.addSubview(img)
        img.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(18)
            $0.height.equalTo(12)
        }
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.shadowRadius = 3
        $0.layer.shadowOffset = CGSize(width: -0.3, height: -0.3)
        $0.layer.shadowOpacity = 1
        $0.layer.shadowColor = UIColor.custom(.gray_cfd6e0).withAlphaComponent(0.5).cgColor
        $0.layer.masksToBounds = false
        $0.layer.cornerRadius = 10
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSettingAlert)))
    }
    
    var homeSettingAlert: DoorLockHomeAlert?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingButton)
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        view.addSubview(bottomDrawer)
        view.addSubview(bleStatusButton)
        warningCell.items = ["awefaw", "awefawf,", "awfewf"]
        logCell.items = ["室内上锁", "永久密码上锁", "指纹开锁"]
        
        /// 展开
        warningCell.btn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.warningCell.btn.isFolded = !self.warningCell.btn.isFolded
            if !self.warningCell.btn.isFolded {
                self.warningCell.items = ["awefaw", "awefawf,", "awfewf", "awefaw", "awefawf,", "awfewf"]
            } else {
                self.warningCell.items = ["awefaw", "awefawf,", "awfewf"]
            }
            self.tableView.reloadData()
        }
        
        /// 查看日志
        logCell.btn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            
        }

    }
    
    override func setupConstraints() {
        bleStatusButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(10)
            $0.height.equalTo(25)
            $0.width.equalTo(100)
            $0.top.equalToSuperview().offset(Screen.k_nav_height + 10)
        }
        
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomDrawer.snp.top).offset(-10)
        }
        
        bottomDrawer.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Screen.bottomSafeAreaHeight)
            $0.height.equalTo(50)
        }

    }
    
    @objc private func showSettingAlert() {
        homeSettingAlert = DoorLockHomeAlert(items: [.oneTimePwd, .usersManagement, .lockSettings]) { [weak self] item in
            guard let self = self else { return }
            switch item {
            case .lockSettings:
                let vc = DoorLockSettingViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            case .usersManagement:
                let vc = DoorLockUserManagementViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            case .oneTimePwd:
                let vc = DoorLockOneTimePwdListViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
        SceneDelegate.shared.window?.addSubview(homeSettingAlert!)
    }
}

extension DoorLockViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return headCell
        } else if indexPath.row == 1 {
            return warningCell
        } else {
            return logCell
        }
        
    }
    

}
