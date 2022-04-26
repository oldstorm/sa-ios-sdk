//
//  DoorLockUserDetailViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/15.
//

import Foundation
import UIKit


class DoorLockUserDetailViewController: BaseViewController {
    var user: String?
    
    private lazy var fingers = ["a", "af", "wfe"]
    
    private lazy var pwds = [String]()
    
    private lazy var nfcs = ["a", "af", "wfe"]
    
    private lazy var header = DoorLockUserDetailHeader()

    private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.estimatedRowHeight = UITableView.automaticDimension
        $0.sectionHeaderHeight = 60
        $0.sectionFooterHeight = 0
        $0.register(DoorLockUserDetailCell.self, forCellReuseIdentifier: DoorLockUserDetailCell.reusableIdentifier)
    }
    
    private lazy var navRightButton = Button().then {
        $0.setTitle("删除".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.frame.size = CGSize(width: 44, height: 24)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "用户详情"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightButton)
    }
    
    override func setupViews() {
        view.addSubview(header)
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        header.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }

    }

}

extension DoorLockUserDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return fingers.count
        } else if section == 1 {
            return pwds.count
        } else {
            return nfcs.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = DoorLockUserDetailSectionHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 60))
        if section == 0 {
            header.icon.image = .assets(.icon_pwd_finger_color)
            header.titleLabel.text = "指纹".localizedString
            header.setRoundedCorner(corners: fingers.count == 0 ? .allCorners : [.topLeft, .topRight])

        } else if section == 1 {
            header.icon.image = .assets(.icon_pwd_lock_color)
            header.titleLabel.text = "密码".localizedString
            header.setRoundedCorner(corners: pwds.count == 0 ? .allCorners : [.topLeft, .topRight])
        } else {
            header.icon.image = .assets(.icon_pwd_nfc_color)
            header.titleLabel.text = "NFC".localizedString
            header.setRoundedCorner(corners: nfcs.count == 0 ? .allCorners : [.topLeft, .topRight])
        }
        
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DoorLockUserDetailCell.reusableIdentifier, for: indexPath) as! DoorLockUserDetailCell
        if indexPath.section == 0 {
            cell.item = fingers[indexPath.row]
            cell.setRoundedCorner(radii: indexPath.row == fingers.count - 1 ? CGSize(width: 10, height: 10) : CGSize(width: 0, height: 0))
        } else if indexPath.section == 1 {
            cell.item = pwds[indexPath.row]
            cell.setRoundedCorner(radii: indexPath.row == pwds.count - 1 ? CGSize(width: 10, height: 10) : CGSize(width: 0, height: 0))
        } else {
            cell.item = nfcs[indexPath.row]
            cell.setRoundedCorner(radii: indexPath.row == nfcs.count - 1 ? CGSize(width: 10, height: 10) : CGSize(width: 0, height: 0))
        }
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? DoorLockUserDetailCell {
            if indexPath.section == 0 {
                cell.setRoundedCorner(radii: indexPath.row == fingers.count - 1 ? CGSize(width: 10, height: 10) : CGSize(width: 0, height: 0))
            } else if indexPath.section == 1 {
                cell.setRoundedCorner(radii: indexPath.row == pwds.count - 1 ? CGSize(width: 10, height: 10) : CGSize(width: 0, height: 0))
            } else {
                cell.setRoundedCorner(radii: indexPath.row == nfcs.count - 1 ? CGSize(width: 10, height: 10) : CGSize(width: 0, height: 0))
            }
        }
        
    }
    
    
}
