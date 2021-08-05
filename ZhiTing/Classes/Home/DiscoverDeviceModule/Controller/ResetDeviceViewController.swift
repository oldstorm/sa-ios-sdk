//
//  ResetDeviceViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/7/12.
//

import UIKit

class ResetDeviceViewController: BaseViewController {
    
    private lazy var icon = ImageView().then {
        $0.image = .assets(.icon_resetDevice)
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var titleLabel = Label().then {
        $0.text = "设备重置".localizedString
        $0.font = .font(size: ZTScaleValue(16), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
    }
    
    private lazy var detailLabel = Label().then {
        $0.text = "设备重置".localizedString
        $0.font = .font(size: ZTScaleValue(14), type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var nextBtn = Button().then {
        $0.setTitle("下一步".localizedString, for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
    }

    private lazy var confirmLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(14), type: .regular)
        $0.text = "已确认上述操作".localizedString
        $0.textColor = .custom(.gray_94a5be)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapConfirm)))
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var confirmBtn = SelectButton(frame: .zero, type: .rounded)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "设备重置".localizedString
    }
    
    override func setupViews() {
        view.addSubview(icon)
        view.addSubview(titleLabel)
        view.addSubview(detailLabel)
        view.addSubview(confirmBtn)
        view.addSubview(confirmLabel)
        view.addSubview(nextBtn)
        
        self.nextBtn.isEnabled = false
        self.nextBtn.alpha = 0.5
        
        confirmBtn.clickedCallback = { [weak self] isSelected in
            guard let self = self else { return }
            self.nextBtn.isEnabled = isSelected
            self.nextBtn.alpha = isSelected ? 1 : 0.5
            
        }

        nextBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let vc = SmartConfigWifiViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc
    private func tapConfirm() {
        confirmBtn.isSelected = !confirmBtn.isSelected
        self.nextBtn.isEnabled = confirmBtn.isSelected
        self.nextBtn.alpha = confirmBtn.isSelected ? 1 : 0.5
    }


    override func setupConstraints() {
        icon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(ZTScaleValue(180))
            $0.top.equalToSuperview().offset(ZTScaleValue(34))
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(icon.snp.bottom).offset(ZTScaleValue(23))
        }
        
        detailLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(15))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }

        nextBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(ZTScaleValue(-10) - Screen.bottomSafeAreaHeight)
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.equalTo(50)
        }
        
        confirmBtn.snp.makeConstraints {
            $0.bottom.equalTo(nextBtn.snp.top).offset(ZTScaleValue(-20))
            $0.left.equalTo(nextBtn.snp.left)
            $0.height.width.equalTo(ZTScaleValue(16))
        }

        confirmLabel.snp.makeConstraints {
            $0.centerY.equalTo(confirmBtn.snp.centerY)
            $0.left.equalTo(confirmBtn.snp.right).offset(10)
        }

    }

}
