//
//  AreaMemberSectionHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/31.
//

import UIKit

class AreaMemberSectionHeader: UIView {
    lazy var titleLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.text = "成员 ".localizedString
    }

    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .custom(.white_ffffff)
        addSubview(line)
        addSubview(titleLabel)
        
        line.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(10)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15.5)
            $0.top.equalTo(line.snp.bottom).offset(13.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
