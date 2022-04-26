//
//  DepartmentSettingCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/16.
//

import UIKit

class DepartmentSettingCell: UITableViewCell, ReusableView {
    var member: User? {
        didSet {
            guard let member = member else {
                nicknameLabel.text = " "
                avatar.image = nil
                return
            }
            
            nicknameLabel.text = member.nickname
            avatar.setImage(urlString: member.avatar_url, placeHolder: .assets(.default_avatar))

        }
    }

    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "部门主管".localizedString
    }
    
    private lazy var avatar = ImageView().then {
        $0.layer.cornerRadius = 15
        $0.contentMode = .scaleAspectFit
        $0.image = nil
        $0.clipsToBounds = true
    }
    
    private lazy var nicknameLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var arrow = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.arrow_right_deepGray)
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(avatar)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(arrow)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(15.5)
        }
        
        arrow.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-11)
            $0.width.equalTo(7.5)
            $0.height.equalTo(13.5)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(arrow.snp.left).offset(-13)
            $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(40)
        }
        
        avatar.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(30)
            $0.right.equalTo(nicknameLabel.snp.left).offset(-8)
        }

    }

}
