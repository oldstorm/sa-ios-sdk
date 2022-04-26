//
//  MemberInfoHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/31.
//

import UIKit

class MemberInfoHeader: UIView {
    lazy var avatar = ImageView().then {
        $0.image = .assets(.default_avatar)
        $0.layer.cornerRadius = 30
        $0.clipsToBounds = true
    }
    
    lazy var nickNameLabel = Label().then {
        $0.font = .font(size: 20, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = ""
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .custom(.white_ffffff)
        addSubview(avatar)
        addSubview(nickNameLabel)
        addSubview(line)
        
        avatar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.left.equalToSuperview().offset(15).priority(.high)
            $0.width.height.equalTo(60)
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(avatar.snp.centerY)
            $0.left.equalTo(avatar.snp.right).offset(15).priority(.high)
            $0.right.equalToSuperview().offset(-15).priority(.high)
        }
        
        line.snp.makeConstraints {
            $0.height.equalTo(10)
            $0.bottom.left.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
