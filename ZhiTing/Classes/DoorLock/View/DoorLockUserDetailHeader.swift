//
//  DoorLockUserDetailHeader.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/15.
//

import Foundation
import UIKit

class DoorLockUserDetailHeader: UIView {
    
    private lazy var avatar = ImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = .assets(.icon_doorlock_user)
    }

    private lazy var nameLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.textColor = .custom(.black_333333)
        $0.text = "User"
    }
    
    private lazy var detailLabel = Label().then {
        $0.attributed.text = "\(.image(.assets(.tag_normal) ?? UIImage(), .original()))"
    }
    
    private lazy var arrow = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.arrow_right_deepGray)
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
        backgroundColor = .custom(.white_ffffff)
        addSubview(avatar)
        addSubview(nameLabel)
        addSubview(detailLabel)
        addSubview(arrow)
    }
    
    private func setupConstraints() {
        avatar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.equalToSuperview().offset(15)
            $0.bottom.equalToSuperview().offset(-15)
            $0.width.height.equalTo(55)
        }
        
        arrow.snp.makeConstraints {
            $0.centerY.equalTo(avatar.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.width.equalTo(7.5)
            $0.height.equalTo(13.5)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatar.snp.top).offset(9.5)
            $0.left.equalTo(avatar.snp.right).offset(15)
            $0.right.equalTo(arrow.snp.left).offset(-10)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.left.equalTo(avatar.snp.right).offset(15)
            $0.right.equalTo(arrow.snp.left).offset(-10)
        }
        
        

    }
}
