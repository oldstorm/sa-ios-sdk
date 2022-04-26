//
//  DoorLockHeadCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/1.
//

import Foundation
import UIKit


class DoorLockHeadCell: UITableViewCell, ReusableView {
    private lazy var powerIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_low_battery)
    }
    
    private lazy var powerLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.red_fe0000)
        $0.text = "0%"
    }
    
    private lazy var lockButton = Button().then {
        $0.imageView?.contentMode = .scaleAspectFit
        $0.setImage(.assets(.icon_door_opened), for: .normal)
        $0.setImage(.assets(.icon_door_closed), for: .selected)
    }
    
    private lazy var nameLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
        $0.text = "门锁"
    }
    
    private lazy var labelStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
        
        let l1 = DoorLookStatusLabel()
        l1.type = .verified
        let l2 = DoorLookStatusLabel()
        l2.type = .closer
        
        $0.addArrangedSubview(l1)
        $0.addArrangedSubview(l2)
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(powerIcon)
        contentView.addSubview(powerLabel)
        contentView.addSubview(lockButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(labelStackView)
    }
    
    private func setupConstraints() {
        powerIcon.snp.makeConstraints {
            $0.height.equalTo(12)
            $0.width.equalTo(7)
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(15.5)
        }
        
        powerLabel.snp.makeConstraints {
            $0.centerY.equalTo(powerIcon.snp.centerY)
            $0.left.equalTo(powerIcon.snp.right).offset(7)
            $0.right.equalToSuperview().offset(-15)
        }
        
        lockButton.snp.makeConstraints {
            $0.width.height.equalTo(220)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(powerLabel.snp.bottom).offset(40)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(lockButton.snp.bottom).offset(10)
        }

        labelStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-25)
            $0.top.equalTo(nameLabel.snp.bottom).offset(10)
            $0.height.equalTo(20)
        }

    }
    
}


class DoorLookStatusLabel: UIView {
    enum DoorLookStatusLabelType {
        /// 双重验证
        case verified
        /// 安全守护
        case guardian
        /// 请尽量靠近门锁
        case closer
        
        
        var title: String {
            switch self {
            case .verified:
                return "双重验证".localizedString
            case .guardian:
                return "安全守护".localizedString
            case .closer:
                return "请尽量靠近门锁".localizedString
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .verified:
                return .assets(.icon_verified)
            case .guardian:
                return nil
            case .closer:
                return nil
            }
        }
        
        var textColor: UIColor? {
            switch self {
            case .verified:
                return .custom(.blue_2da3f6)
            case .guardian:
                return .custom(.blue_2da3f6)
            case .closer:
                return .custom(.red_fe0000)
            }
        }
        
        var backgroundColor: UIColor? {
            switch self {
            case .verified:
                return .custom(.blue_2da3f6).withAlphaComponent(0.2)
            case .guardian:
                return .custom(.blue_2da3f6).withAlphaComponent(0.2)
            case .closer:
                return .custom(.red_fe0000).withAlphaComponent(0.2)
            }
        }
    }

    var type: DoorLookStatusLabelType? {
        didSet {
            guard let type = type else {
                return
            }
            
            label.text = type.title
            label.textColor = type.textColor
            icon.image = type.icon
            backgroundColor = type.backgroundColor
            if icon.image == nil {
                label.snp.remakeConstraints {
                    $0.centerY.equalTo(icon.snp.centerY)
                    $0.left.equalTo(icon.snp.left)
                    $0.right.equalToSuperview().offset(-5)
                }
            } else {
                label.snp.remakeConstraints {
                    $0.centerY.equalTo(icon.snp.centerY)
                    $0.left.equalTo(icon.snp.right).offset(5)
                    $0.right.equalToSuperview().offset(-5)
                }
            }

        }
    }

    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var label = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.blue_2da3f6)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        addSubview(icon)
        addSubview(label)
        
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
            $0.height.width.equalTo(16).priority(.high)
            $0.left.equalToSuperview().offset(5)
        }
        
        label.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.left.equalTo(icon.snp.right).offset(5)
            $0.right.equalToSuperview().offset(-5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
