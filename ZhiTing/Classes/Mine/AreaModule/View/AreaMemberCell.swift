//
//  AreaMemberCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/31.
//

import UIKit

class AreaMemberCell: UITableViewCell, ReusableView {
    var member: User? {
        didSet {
            guard let member = member else {
                return
            }
            nickNameLabel.text = member.nickname == "" ? " " : member.nickname
            authorityLabel.text = member.role_infos.map(\.name).joined(separator: "、")
            if authorityLabel.text == "" {
                authorityLabel.text = " "
            }
        }
    }

    private lazy var avatar = ImageView().then {
        $0.image = .assets(.default_avatar)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
    }
    
    private lazy var nickNameLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.text = "member"
    }
    
    private lazy var authorityLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.text = "成员".localizedString
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
    }
    
    private lazy var arrow = ImageView().then {
        $0.image = .assets(.right_arrow_gray)
        $0.contentMode = .scaleAspectFit
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
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(avatar)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(authorityLabel)
        contentView.addSubview(arrow)
        contentView.addSubview(line)
    }
    
    private func setupConstraints() {
        avatar.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.top.equalToSuperview().offset(9.5)
            $0.left.equalToSuperview().offset(16.5)
        }
        
        arrow.snp.makeConstraints {
            $0.width.equalTo(7.5)
            $0.height.equalTo(13.5)
            $0.right.equalToSuperview().offset(-14.5)
            $0.top.equalToSuperview().offset(23.5)
        }

        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(avatar.snp.top)
            $0.left.equalTo(avatar.snp.right).offset(15)
            $0.right.lessThanOrEqualTo(arrow.snp.left).offset(-10)
        }
        
        authorityLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(5)
            $0.left.equalTo(nickNameLabel.snp.left)
            $0.right.lessThanOrEqualTo(arrow.snp.left).offset(-10)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(authorityLabel.snp.bottom).offset(14.5)
            $0.height.equalTo(0.5)
            $0.right.equalToSuperview()
            $0.left.equalToSuperview().offset(70)
            $0.bottom.equalToSuperview()
        }
        

    }

}
