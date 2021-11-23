//
//  SADeviceViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/20.
//

import UIKit

class SADeviceViewController: BaseViewController {
    var device_id = 0
    var area = Area()
    
    var cellsArray = [UITableViewCell]()
    
    private lazy var settingButton = Button().then {
        $0.setImage(.assets(.settings), for: .normal)
        $0.frame.size = CGSize(width: 18, height: 18)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let vc = DeviceDetailViewController()
            vc.area = self.area
            vc.device_id = self.device_id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    lazy var deviceImg = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.default_device)
    }
    
    private lazy var coverView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var deviceNameLabel = Label().then {
        $0.text = "Smart Assistant"
        $0.font = .font(size: 16, type: .bold)
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "设备详情".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingButton)
        requestNetwork()
    }

    private lazy var softwareCell = ValueDetailCell().then {
        $0.title.text = "软件升级".localizedString
        $0.line.isHidden = true
        $0.bottomLine.isHidden = false
        $0.valueLabel.text = " "
    }
    
    private lazy var firmwareCell = ValueDetailCell().then {
        $0.title.text = "固件升级".localizedString
        $0.line.isHidden = true
        $0.bottomLine.isHidden = false
        $0.valueLabel.text = " "
    }

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.white_ffffff)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = ZTScaleValue(50)
        if #available(iOS 15.0, *) {
            $0.sectionHeaderTopPadding = 0
        }
        $0.delegate = self
        $0.dataSource = self
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(coverView)
        coverView.addSubview(deviceImg)
        coverView.addSubview(deviceNameLabel)
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        
        coverView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(246))
        }
        
        deviceImg.snp.makeConstraints {
            $0.width.height.equalTo(ZTScaleValue(120))
            $0.top.equalToSuperview().offset(ZTScaleValue(25))
            $0.centerX.equalToSuperview()
        }
        
        deviceNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(deviceImg.snp.bottom).offset(ZTScaleValue(15))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(coverView.snp.bottom).offset(ZTScaleValue(10))
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    private func requestNetwork() {
        ApiServiceManager.shared.deviceDetail(area: area, device_id: device_id) { [weak self] (response) in
            guard let self = self else { return }
            self.deviceNameLabel.text = response.device_info.name
            if (response.device_info.permissions.delete_device || response.device_info.permissions.update_device) {
                self.settingButton.isHidden = false
            } else {
                self.settingButton.isHidden = true
            }
            
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
        
        getRolePermission()
    }
    
    private func getRolePermission() {
        ApiServiceManager.shared.rolesPermissions(area: area, user_id: area.sa_user_id) { [weak self] response in
            guard let self = self else { return }
            self.cellsArray.removeAll()

            if response.permissions.sa_software_upgrade {
                self.cellsArray.append(self.softwareCell)
            }
            
            if response.permissions.sa_firmware_upgrade {
                self.cellsArray.append(self.firmwareCell)
            }
            
            self.tableView.reloadData()
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.showToast(string: err)
        }

    }

}

extension SADeviceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellsArray[indexPath.row]

    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UpdateViewController()
        switch cellsArray[indexPath.row] {
        case softwareCell:
            print("点击软件升级")
            vc.updateType = .software
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case firmwareCell:
            print("点击固件更新")
//            vc.updateType = .firmware
            self.showToast(string: "功能暂未开放")
            return
        default:
            break
        }
    }
    
    
}

