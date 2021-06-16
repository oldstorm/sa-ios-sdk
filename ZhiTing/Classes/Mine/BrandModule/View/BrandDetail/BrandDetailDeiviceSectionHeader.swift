//
//  BrandDetailDeiviceSectionHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/26.
//

import UIKit

class BrandDetailDeiviceSectionHeader: UIView {
    lazy var titleLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.text = "该品牌支持的设备".localizedString
        $0.textColor = .custom(.gray_94a5be)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(14.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
