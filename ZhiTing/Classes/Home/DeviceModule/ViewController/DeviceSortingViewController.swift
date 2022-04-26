//
//  DeviceSortingViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/6.
//

import Foundation
import UIKit

class DeviceSortingViewController: BaseViewController {
    /// 当前家庭
    var area: Area?
    /// 当前位置
    var location: Location? {
        didSet {
            locationLabel.text = location?.name
        }
    }
    /// 设备列表
    var devices = [Device]()

    private lazy var saveButton = Button().then {
        $0.setTitle("保存".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.isEnhanceClick = true
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.save()
        }
        
    }
    
    private lazy var locationLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.text = " "
    }
    
    private lazy var emptyView = EmptyStyleView(frame: .zero, style: .noList).then {
        $0.isHidden = true
    }
    
    private lazy var tableViewHeader = UIView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 40)).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.addSubview(locationLabel)
        locationLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
        }
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.separatorStyle = .none
        $0.tableHeaderView = tableViewHeader
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.isEditing = true
        $0.register(DeviceSortingCell.self, forCellReuseIdentifier: DeviceSortingCell.reusableIdentifier)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "设备排序".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        tableView.addSubview(emptyView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.width.equalTo(tableView)
            $0.height.equalTo(tableView)
            $0.center.equalToSuperview()
        }
    }


}

extension DeviceSortingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyView.isHidden = devices.count > 0 
        return devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeviceSortingCell.reusableIdentifier, for: indexPath) as! DeviceSortingCell
        cell.device = devices[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        devices.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        self.tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
}

extension DeviceSortingViewController {
    @objc
    private func save() {
        
    }
}
