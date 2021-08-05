//
//  HomeDeviceCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/1.
//

import UIKit

class HomeDeviceCell: UICollectionViewCell, ReusableView {
    var statusButtonCallback: ((Bool) -> ())? {
        didSet{
            switchButton.statusCallback = { [weak self] isOn in
                self?.statusButtonCallback?(isOn)
            }
        }
    }
    
    var device: Device? {
        didSet {
            guard let device = device else { return }
            icon.setImage(urlString: device.logo_url, placeHolder: .assets(.default_device))
            nameLabel.text = device.name
            switchButton.isOn = device.isOn ?? false
            
            if device.isOn != nil {
                loadingActivity.stopAnimating()
            } else {
                if !device.is_sa {
                    loadingActivity.isHidden = false
                    loadingActivity.startAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                        self.loadingActivity.stopAnimating()
                    }
                }
            }

            if device.is_online ?? false || device.is_sa {
                offlineView.isHidden = true
                switchButton.isUserInteractionEnabled = true
                nameLabel.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(20)
                    $0.left.equalToSuperview().offset(15).priority(.high)
                    $0.width.lessThanOrEqualTo((Screen.screenWidth - 45) / 2 - 30)
                }
            } else {
                switchButton.isUserInteractionEnabled = false
                switchButton.isSelected = false
                switchButton.alpha = 0.8
                
                nameLabel.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(20)
                    $0.left.equalToSuperview().offset(15).priority(.high)
                    $0.width.lessThanOrEqualTo((Screen.screenWidth - 45) / 2 - 60)
                }
                
                offlineView.isHidden = false
                offlineView.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(20)
                    $0.left.equalTo(nameLabel.snp.right).offset(ZTScaleValue(5))
                    $0.width.equalTo(ZTScaleValue(30))
                    $0.height.equalTo(ZTScaleValue(18))
                }
            }
            
            switchButton.isHidden = device.is_sa
            switchButton.isHidden = !(device.is_permit ?? false)
            
        }
    }
    
    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.default_device)
    }

    private lazy var nameLabel = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .left
        $0.text = "Unknown"
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private lazy var offlineView = OfflineView().then {
        $0.isHidden = true
    }

    private lazy var loadingActivity = UIActivityIndicatorView().then {
        $0.hidesWhenStopped = true
        $0.isHidden = true
    }

    private lazy var switchButton = SwitchButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        backgroundColor = .custom(.white_ffffff)
        layer.cornerRadius = 10
        contentView.addSubview(icon)
        contentView.addSubview(nameLabel)
        contentView.addSubview(switchButton)
        contentView.addSubview(offlineView)
        contentView.addSubview(loadingActivity)
    }
    
    private func setConstrains() {
        icon.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.top.equalTo(nameLabel.snp.bottom).offset(10)
            $0.width.height.equalTo(snp.height).multipliedBy(0.5)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        switchButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-17.5)
            $0.bottom.equalToSuperview().offset(-17)
            $0.width.height.equalTo(snp.height).multipliedBy(0.25)
            
        }
        
        loadingActivity.snp.makeConstraints {
            $0.edges.equalTo(switchButton)
        }

    }
    
}


extension HomeDeviceCell {
    class OfflineView: UIView {
        private lazy var titleLabel = Label().then {
            $0.text = "离线".localizedString
            $0.textColor = .custom(.gray_94a5be)
            $0.font = .font(size: 12, type: .regular)
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(titleLabel)
            layer.cornerRadius = ZTScaleValue(4)
            layer.borderColor = UIColor.custom(.gray_94a5be).cgColor
            layer.borderWidth = 0.5
            titleLabel.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }
}
