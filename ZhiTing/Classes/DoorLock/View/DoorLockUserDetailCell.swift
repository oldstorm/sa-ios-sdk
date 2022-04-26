//
//  DoorLockUserDetailCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/18.
//

import Foundation
import UIKit
// MARK: - Cell
class DoorLockUserDetailCell: UITableViewCell, ReusableView {
    
    var item: String? {
        didSet {
            titleLabel.text = "密码 01"
            detailLabel.text = "在门锁本地编号: 密码03"
        }
    }

    lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }

    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }

    lazy var titleLabel = Label().then {
        $0.textColor = .custom(.black_333333)
        $0.font = .font(size: 14, type: .bold)
    }
    
    lazy var detailLabel = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = . custom(.gray_94a5be)
    }
    
    lazy var editBtn = Button().then {
        $0.setTitle(" 编辑".localizedString, for: .normal)
        $0.setImage(.assets(.icon_edit_blue), for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 11, type: .medium)
    }
    
    lazy var deleteBtn = Button().then {
        $0.setTitle(" 删除".localizedString, for: .normal)
        $0.setImage(.assets(.icon_delete), for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 11, type: .medium)
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
        container.addSubview(titleLabel)
        container.addSubview(detailLabel)
        container.addSubview(line)
        container.addSubview(editBtn)
        container.addSubview(deleteBtn)
    }
    
    private func setupConstraints() {
        container.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        line.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        deleteBtn.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-14)
            $0.height.equalTo(22)
            $0.width.equalTo(45)
        }
        
        editBtn.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.right.equalTo(deleteBtn.snp.left).offset(-20)
            $0.height.equalTo(22)
            $0.width.equalTo(45)
        }


        titleLabel.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(13)
            $0.right.equalTo(editBtn.snp.left).offset(-5)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.equalTo(titleLabel.snp.left)
            $0.right.equalToSuperview().offset(-13)
            $0.bottom.equalToSuperview().offset(-18)
        }

    }
    
    func setRoundedCorner(radii: CGSize) {
        layoutIfNeeded()
        container.addRounded(corners: [.bottomLeft, .bottomRight], radii: radii, borderWidth: 0, borderColor: .clear)
        
    }
    

}


// MARK: - SectionHeader
class DoorLockUserDetailSectionHeader: UIView {
    lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }

    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }

    lazy var titleLabel = Label().then {
        $0.textColor = .custom(.black_333333)
        $0.font = .font(size: 14, type: .bold)
        $0.text = "NFC"
    }
    
    lazy var icon = ImageView().then {
        $0.image = .assets(.icon_pwd_nfc_color)
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var addBtn = Button().then {
        $0.setImage(.assets(.plus_blue_circle), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .custom(.gray_f6f8fd)
        addSubview(line)
        addSubview(container)
        container.addSubview(icon)
        container.addSubview(titleLabel)
        container.addSubview(addBtn)

    }
    
    private func setupConstraints() {
        line.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(10)
        }
        
        container.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }
        
        icon.snp.makeConstraints {
            $0.height.width.equalTo(18).priority(.high)
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(icon.snp.right).offset(10)
            $0.centerY.equalTo(icon.snp.centerY)
        }
        
        addBtn.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.width.height.equalTo(18)
        }
    }
    
    func setRoundedCorner(corners: UIRectCorner = [.topLeft, .topRight]) {
        layoutIfNeeded()
        container.addRounded(corners: corners, radii: CGSize(width: 10, height: 10), borderWidth: 0, borderColor: .clear)
        
    }

}
