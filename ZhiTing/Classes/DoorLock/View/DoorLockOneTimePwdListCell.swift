//
//  DoorLockOneTimePwdListCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/12.
//

import Foundation
import UIKit


class DoorLockOneTimePwdListCell: UITableViewCell, ReusableView {
    var item: String? {
        didSet {
            guard let item = item else {
                return
            }

            nameLabel.text = item
            timeLabel.text = "创建时间".localizedString + ":2022-3-29 17:43"
        }
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var nameLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 14, type: .bold)
    }
    
    private lazy var timeLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 12, type: .regular)
    }
    
    lazy var deleteBtn = Button().then {
        $0.setTitle("  删除".localizedString, for: .normal)
        $0.setImage(.assets(.icon_delete), for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .medium)
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
        contentView.backgroundColor = .custom(.gray_f6f8fd)
        contentView.addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(timeLabel)
        container.addSubview(deleteBtn)
        
    }
    
    private func setupConstraints() {
        container.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalTo(deleteBtn.snp.left).offset(-5)
        }
        
        deleteBtn.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.width.equalTo(70)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

}
