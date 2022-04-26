//
//  DeviceSortingCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/6.
//

import Foundation
import UIKit

class DeviceSortingCell: UITableViewCell, ReusableView {
    var device: Device? {
        didSet {
            guard let device = device else {
                return
            }

            icon.setImage(urlString: device.logo_url, placeHolder: .assets(.default_device))
            titleLabel.text = device.name
        }
    }

    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 4
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.layer.borderWidth = 0.5
    }
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
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
        contentView.backgroundColor = .custom(.white_ffffff)
        selectionStyle = .none
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(line)
    }
    
    private func setupConstraints() {
        icon.snp.makeConstraints {
            $0.width.height.equalTo(38)
            $0.left.equalToSuperview().offset(19)
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.left.equalTo(icon.snp.right).offset(18)
            $0.right.equalToSuperview().offset(-18)
        }
        
        line.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
    
}
