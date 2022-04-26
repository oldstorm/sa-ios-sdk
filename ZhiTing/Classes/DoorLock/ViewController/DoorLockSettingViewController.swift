//
//  DoorLockSettingViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/11.
//

import Foundation
import UIKit

class DoorLockSettingViewController: BaseViewController {
    
    private lazy var header = DoorLockSettingHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 40))

    private lazy var introCell = ValueDetailCell().then {
        $0.title.text = "门锁本地功能介绍".localizedString
    }
    
    private lazy var langCell = ValueDetailCell().then {
        $0.title.text = "语言选择".localizedString
        $0.valueLabel.text = "中文".localizedString
    }
    
    private lazy var volumeCell = ValueDetailCell().then {
        $0.title.text = "门锁音量".localizedString
        $0.valueLabel.text = "高".localizedString
        $0.bottomLine.isHidden = false
        $0.bottomLine.backgroundColor = .custom(.gray_f6f8fd)
        $0.bottomLine.snp.updateConstraints { make in
            make.height.equalTo(8)
        }
    }
    
    private lazy var verificationCell = DoorLockSettingCell().then {
        $0.title.text = "双重验证".localizedString
        $0.detail.text = "开启后，需要验证指纹、密码、NFC其中两种开锁方式才能开门。".localizedString
    }
    
    private lazy var alwaysModeCell = DoorLockSettingCell().then {
        $0.title.text = "常开模式".localizedString
        $0.detail.text = "开启后，不需要使用任何验证方式都可以开门。使用指纹、密码、NFC、APP开锁一次后自动关闭。上提把手，把原来没有打出来的方舌打出来也可以关闭".localizedString
    }

    private lazy var languageAlert = DoorLockSettingLanguageAlert()
    
    private lazy var volumeAlert = DoorLockSettingVolumeAlert(value: 0)

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.tableHeaderView = header
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "设置".localizedString
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        
        /// 选择语言
        langCell.valueLabel.text = "中文".localizedString
        languageAlert.selectedItem = .cn
        languageAlert.selectCallback = { [weak self] item in
            guard let self = self else { return }
            self.langCell.valueLabel.text = item.title
        }
        
        /// 门锁音量
        volumeCell.valueLabel.text = "静音".localizedString
        volumeAlert.value = .mute
        volumeAlert.valueCallback = { [weak self] value in
            guard let self = self else { return }
            self.volumeCell.valueLabel.text = value.title
        }
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}

extension DoorLockSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return introCell
        } else if indexPath.row == 1 {
            return langCell
        } else if indexPath.row == 2 {
            return volumeCell
        } else if indexPath.row == 3 {
            return verificationCell
        } else {
            return alwaysModeCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = DoorLockLocalIntroViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            SceneDelegate.shared.window?.addSubview(languageAlert)
        } else if indexPath.row == 2 {
            SceneDelegate.shared.window?.addSubview(volumeAlert)
        }
    }
}
