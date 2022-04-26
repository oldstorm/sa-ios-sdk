//
//  AreaListSectionHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/18.
//

import UIKit

class AreaListSectionHeader: UITableViewHeaderFooterView, ReusableView {
    lazy var titleLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .custom(.gray_f6f8fd)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
