//
//  DiscoverDeviceCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/2.
//

import Foundation
class DiscoverDeviceCell: UITableViewCell, ReusableView {
    var device: DiscoverDeviceModel? {
        didSet {
            guard let device = device else { return }
//            icon.setImage(urlString: device.logo_url)
            icon.image = .assets(.default_device)
            nameLabel.text = device.name
            
        }
    }
    
    var sa_device: DiscoverSAModel? {
        didSet {
            guard let device = sa_device else { return }
//            icon.setImage(urlString: device.logo_url)
            icon.image = .assets(.default_device)
            nameLabel.text = device.name
            
            if device.is_bind && device.model == "smart_assistant" {
                addButton.setTitle("扫码".localizedString, for: .normal)
            } else {
                addButton.setTitle("添加".localizedString, for: .normal)
            }
        }
    }
    var addButtonCallback: (() -> ())?
    
    lazy var line0 = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
        $0.isHidden = true
    }

    private lazy var icon = ImageView().then {
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.backgroundColor = .custom(.white_ffffff)
        $0.image = .assets(.default_device)
    }

    lazy var nameLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.text = "Unknown Device"
    }
    
    lazy var addButton = Button().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.setTitle("添加".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .medium)
        $0.layer.cornerRadius = 4
        $0.clickCallBack = { [weak self] _ in
            self?.addButtonCallback?()
        }
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
        contentView.addSubview(line0)
        contentView.addSubview(icon)
        contentView.addSubview(nameLabel)
        contentView.addSubview(addButton)
        contentView.addSubview(line)
        
        line0.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.top.equalToSuperview()
            
        }

        icon.snp.makeConstraints {
            $0.top.equalTo(line0.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.width.height.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.left.equalTo(icon.snp.right).offset(16.5)
            $0.right.equalTo(addButton.snp.left).offset(-4.5)
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.right.equalToSuperview().offset(-15)
            $0.width.equalTo(50)
            $0.height.equalTo(30)
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
