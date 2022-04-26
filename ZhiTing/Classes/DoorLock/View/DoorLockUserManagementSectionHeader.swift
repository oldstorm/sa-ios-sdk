//
//  DoorLockUserManagementSectionHeader.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/14.
//

import Foundation
import UIKit

class DoorLockUserManagementSectionHeader: UITableViewHeaderFooterView, ReusableView {
    lazy var titleLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundColor = .custom(.white_ffffff)
        contentView.backgroundColor = .custom(.white_ffffff)
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
