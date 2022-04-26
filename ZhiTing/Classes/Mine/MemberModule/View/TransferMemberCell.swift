//
//  TransferMemberCell.swift
//  ZhiTing
//
//  Created by macbook on 2021/7/7.
//

import UIKit

class TransferMemberCell: UITableViewCell,ReusableView {

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
            selectedBtn.isSelected = member.isSelected
        }
    }

    private lazy var avatar = ImageView().then {
        $0.image = .assets(.default_avatar)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = ZTScaleValue(20)
    }
    
    private lazy var nickNameLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.text = "member"
    }
    
    private lazy var authorityLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.text = "成员".localizedString
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
    }
    
    private lazy var selectedBtn = Button().then {
        $0.isUserInteractionEnabled = false
        $0.setImage(.assets(.unselected_tick), for: .normal)
        $0.setImage(.assets(.selected_tick), for: .selected)
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
        contentView.addSubview(selectedBtn)
        contentView.addSubview(line)
    }
    
    private func setupConstraints() {
        avatar.snp.makeConstraints {
            $0.width.height.equalTo(ZTScaleValue(40))
            $0.top.equalToSuperview().offset(ZTScaleValue(9.5))
            $0.left.equalToSuperview().offset(ZTScaleValue(16.5))
        }
        
        selectedBtn.snp.makeConstraints {
            $0.width.equalTo(ZTScaleValue(18.5))
            $0.height.equalTo(ZTScaleValue(18.5))
            $0.right.equalToSuperview().offset(-ZTScaleValue(14.5))
            $0.top.equalToSuperview().offset(ZTScaleValue(23.5))
        }

        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(avatar.snp.top)
            $0.left.equalTo(avatar.snp.right).offset(ZTScaleValue(15))
            $0.right.lessThanOrEqualTo(selectedBtn.snp.left).offset(-ZTScaleValue(10))
        }
        
        authorityLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(ZTScaleValue(5))
            $0.left.equalTo(nickNameLabel.snp.left)
            $0.right.lessThanOrEqualTo(selectedBtn.snp.left).offset(-ZTScaleValue(10))
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(authorityLabel.snp.bottom).offset(ZTScaleValue(14.5))
            $0.height.equalTo(ZTScaleValue(0.5))
            $0.right.equalToSuperview()
            $0.left.equalToSuperview().offset(ZTScaleValue(70))
            $0.bottom.equalToSuperview()
        }
        

    }


}
