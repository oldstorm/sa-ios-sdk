//
//  DoorLockAddUserViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/15.
//

import Foundation
import UIKit

class DoorLockAddUserViewController: BaseViewController {
    var selectedUserType: DoorLockUserType?

    private lazy var header = DoorLockAddUserHeader()

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.register(DoorLockUserTypeSelectionCell.self, forCellReuseIdentifier: DoorLockUserTypeSelectionCell.reusableIdentifier)
    }
    
    private lazy var doneButton = Button().then {
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.layer.cornerRadius = 10
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitle("完成".localizedString, for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "添加用户".localizedString
    }

    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(doneButton)
    }
    
    override func setupConstraints() {
        header.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.left.right.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(doneButton.snp.top).offset(-15)
        }
        
        doneButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }

    }


}

extension DoorLockAddUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DoorLockUserType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DoorLockUserTypeSelectionCell.reusableIdentifier, for: indexPath) as! DoorLockUserTypeSelectionCell
        cell.titleLabel.text =  DoorLockUserType.allCases[indexPath.row].title
        cell.selectButton.isSelected = selectedUserType == DoorLockUserType.allCases[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUserType = DoorLockUserType.allCases[indexPath.row]
        tableView.reloadData()
    }
    
    
}
