//
//  DoorLockUserManagementCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/14.
//

import Foundation
import UIKit
import AttributedString

class DoorLockUserManagementCell: UITableViewCell, ReusableView {
    var item: String? {
        didSet {
            var nameText: ASAttributedString = .init(string: "")
            let nameTextAttrStr: ASAttributedString = .init(string: "管理员", with: [.font(.font(size: 12, type: .medium)), .foreground(.custom(.gray_94a5be))])
            nameText += nameTextAttrStr
            nameLabel.attributed.text = nameText

            var pwdText: ASAttributedString = .init(string: "")
            
            let colorStr: ASAttributedString = .init(.image(UIImage.assets(.icon_pwd_lock) ?? UIImage(), .custom(.center, size: CGSize(width: 12, height: 14))))
            pwdText += colorStr
            let attrStr: ASAttributedString = .init(string: " 指纹1、指纹3  ", with: [.font(.font(size: 12, type: .medium)), .foreground(.custom(.gray_94a5be))])
            pwdText += attrStr
            
            let colorStr2: ASAttributedString = .init(.image(UIImage.assets(.icon_pwd_nfc) ?? UIImage(), .custom(.center, size: CGSize(width: 12, height: 14))))
            pwdText += colorStr2
            let attrStr2: ASAttributedString = .init(string: " 密码2", with: [.font(.font(size: 12, type: .medium)), .foreground(.custom(.gray_94a5be))])
            pwdText += attrStr2
            
            detailLabel.attributed.text = pwdText
        }
    }

    private lazy var avatar = ImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = .assets(.icon_doorlock_user)
    }
    
    private lazy var nameLabel = Label()
    
    private lazy var detailLabel = Label()
    
    private lazy var arrow = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.right_arrow_gray)
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
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
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(arrow)
        contentView.addSubview(line)
    }
    
    private func setupConstraints() {
        avatar.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.width.height.equalTo(40)
            $0.top.equalToSuperview().offset(15)
            $0.bottom.equalToSuperview().offset(-15)
        }
        
        arrow.snp.makeConstraints {
            $0.centerY.equalTo(avatar.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.width.equalTo(7.5)
            $0.height.equalTo(13.5)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatar.snp.top)
            $0.left.equalTo(avatar.snp.right).offset(15)
            $0.right.equalTo(arrow.snp.left).offset(-15)
        }
        
        detailLabel.snp.makeConstraints {
            $0.bottom.equalTo(avatar.snp.bottom)
            $0.left.equalTo(avatar.snp.right).offset(15)
            $0.right.equalTo(arrow.snp.left).offset(-15)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(avatar.snp.bottom).offset(10)
            $0.right.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.left.equalTo(nameLabel.snp.left)
        }

    }
    

}
