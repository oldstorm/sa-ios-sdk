//
//  DoorLockOneTimePwdListViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/12.
//

import Foundation
import UIKit

class DoorLockOneTimePwdListViewController: BaseViewController {
    var oneTimePwds: [String] = ["abc", "asfe", "awfwe"]

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = UITableView.automaticDimension
        $0.tableHeaderView = tableViewHeader
        $0.register(DoorLockOneTimePwdListCell.self, forCellReuseIdentifier: DoorLockOneTimePwdListCell.reusableIdentifier)
    }
    
    private lazy var tableViewHeader = UIView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 30)).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        let label = Label()
        label.font = .font(size: 11, type: .regular)
        label.text = "有效期内密码".localizedString
        label.textColor = .custom(.gray_94a5be)
        $0.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
    }
    
    private lazy var addButton = ImageTitleButton(frame: .zero, icon: nil, title: "添加".localizedString, titleColor: UIColor.custom(.white_ffffff), backgroundColor: UIColor.custom(.blue_2da3f6))

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "一次性密码".localizedString
    }
    
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(addButton)

        addButton.clickCallBack = { [weak self] in
            guard let self = self else { return }
            self.clickAdd()
        }
    }
    
    override func setupConstraints() {
        addButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-15 - Screen.bottomSafeAreaHeight)
            $0.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(addButton.snp.top).offset(-10)
        }
    }

}

extension DoorLockOneTimePwdListViewController {
    private func clickAdd() {
        WarningAlert.show(message: "一次性密码数量已满，请使用或删除其他有效期内密码后重试")
        let vc = DoorLockOneTimePwdGenerateViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func deletePwd(item: String) {
        TipsAlertView.show(message: "确定删除“\(item)”吗？") { [weak self] in
            guard let self = self else { return }
            
        }
        
    }
}

extension DoorLockOneTimePwdListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oneTimePwds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DoorLockOneTimePwdListCell.reusableIdentifier, for: indexPath) as! DoorLockOneTimePwdListCell
        let item = oneTimePwds[indexPath.row]
        cell.item = item
        cell.deleteBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.deletePwd(item: item)
        }
        
        return cell
    }
    
    
}
