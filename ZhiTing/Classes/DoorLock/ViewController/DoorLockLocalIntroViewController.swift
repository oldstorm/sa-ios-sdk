//
//  DoorLockLocalIntroViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/11.
//

import Foundation

class DoorLockLocalIntroViewController: BaseViewController {
    private lazy var lockedCell = ValueDetailCell().then {
        $0.title.text = "反锁".localizedString
    }
    
    private lazy var catEyeProtectCell = ValueDetailCell().then {
        $0.title.text = "防猫眼".localizedString
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "本地本地功能介绍".localizedString
    }
    
    override func setupViews() {
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}

extension DoorLockLocalIntroViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return lockedCell
        } else {
            return catEyeProtectCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = DoorLockLocalFuncIntroViewController(funcType: .locked)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = DoorLockLocalFuncIntroViewController(funcType: .catEyeProtection)
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}

