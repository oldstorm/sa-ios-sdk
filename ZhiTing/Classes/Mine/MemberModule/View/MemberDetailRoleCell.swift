//
//  MemberInfoRoleCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/31.
//

import UIKit

class MemberInfoRoleCell: UITableViewCell, ReusableView {
    lazy var icon = ImageView().then {
        $0.image = .assets(.icon_role)
    }
    
    lazy var title = Label().then {
        $0.text = "角色".localizedString
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_3f4663)
    }
    
    lazy var valueLabel = Label().then {
        $0.text = " "
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
        $0.textAlignment = .right
    }
    
    private lazy var arrow = ImageView().then {
        $0.image = .assets(.right_arrow_gray)
    }
    
    private lazy var line = UIView().then { $0.backgroundColor = .custom(.gray_f1f4fc) }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(icon)
        contentView.addSubview(title)
        contentView.addSubview(valueLabel)
        contentView.addSubview(arrow)
        contentView.addSubview(line)

        
        icon.snp.makeConstraints {
            $0.width.equalTo(16)
            $0.height.equalTo(16)
            $0.top.equalToSuperview().offset(19.5)
            $0.left.equalToSuperview().offset(19.5)
        }
        
        title.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.left.equalTo(icon.snp.right).offset(14.5)
        }
        
        arrow.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.centerY.equalTo(icon.snp.centerY)
            $0.width.equalTo(7)
            $0.height.equalTo(12.5)
        }
        
        valueLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19.5)
            $0.right.equalTo(arrow.snp.left).offset(-15)
            $0.left.greaterThanOrEqualTo(title.snp.right).offset(15)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(valueLabel.snp.bottom).offset(19.5)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.right.equalToSuperview()
            $0.left.equalToSuperview()
        }
    }
}
