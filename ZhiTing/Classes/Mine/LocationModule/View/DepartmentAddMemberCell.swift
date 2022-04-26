//
//  DepartmentAddMemberCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/17.
//

import Foundation
import UIKit

class DepartmentAddMemberCell: UITableViewCell, ReusableView {
    var member: User? {
        didSet {
            guard let member = member else {
                return
            }

            titleLabel.text = member.nickname
            detailLabel.text = member.role_infos.map(\.name).joined(separator: "、")
            tickIcon.image = member.isSelected ? .assets(.selected_tick_square) : .assets(.unselected_tick_square)
        }
    }

    lazy var line = UIView().then { $0.backgroundColor = .custom(.gray_eeeeee) }
    
    lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.image = .assets(.default_avatar)
    }
    
    lazy var titleLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "nickname"
    }
    
    lazy var detailLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.text = "role"
    }

    lazy var tickIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.unselected_tick_square)
        
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(tickIcon)
        contentView.addSubview(line)
        
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(17)
            $0.height.width.equalTo(40)
        }
        
        tickIcon.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.height.width.equalTo(18)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.left.equalTo(icon.snp.right).offset(12.5)
            $0.right.equalTo(tickIcon.snp.left).offset(-4.5)
        }
        
        detailLabel.snp.makeConstraints {
            $0.bottom.equalTo(line.snp.top).offset(-12)
            $0.left.equalTo(icon.snp.right).offset(12.5)
            $0.right.equalTo(tickIcon.snp.left).offset(-4.5)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(10.5)
            $0.right.equalToSuperview()
            $0.left.equalToSuperview().offset(44)
            $0.height.equalTo(0.5)
            $0.bottom.equalToSuperview()
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
