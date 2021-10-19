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

    override func setupViews() {
        view.addSubview(deviceImg)
        view.addSubview(deviceNameLabel)
    }
    
    override func setupConstraints() {
        deviceImg.snp.makeConstraints {
            $0.width.height.equalTo(ZTScaleValue(120))
            $0.top.equalToSuperview().offset(ZTScaleValue(25) + Screen.k_nav_height)
            $0.centerX.equalToSuperview()
        }
        
        deviceNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(deviceImg.snp.bottom).offset(ZTScaleValue(15))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            
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
        
    }
}

