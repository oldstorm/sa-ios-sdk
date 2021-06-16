//
//  SupportedDeviceCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/26.
//

import UIKit

class BrandDetailDeviceCell: UITableViewCell, ReusableView {
    var device: Device? {
        didSet {
            guard let device = device else { return }
            icon.setImage(urlString: device.logo_url, placeHolder: .assets(.default_device))
            nameLabel.text = device.name
        }
    }
    
    private lazy var icon = ImageView().then {
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.backgroundColor = .custom(.white_ffffff)
    }

    private lazy var nameLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.text = "Unknown Device"
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(icon)
        contentView.addSubview(nameLabel)
        contentView.addSubview(line)
        
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.width.height.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.left.equalTo(icon.snp.right).offset(16.5)
            $0.right.equalToSuperview().offset(-16.5)
        }
        
        line.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.top.equalTo(nameLabel.snp.bottom).offset(28.5)
            $0.bottom.equalToSuperview()
        }

    }
}
