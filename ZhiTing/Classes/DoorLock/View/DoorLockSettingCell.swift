//
//  DoorLockSettingCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/11.
//

import Foundation
import UIKit

class DoorLockSettingCell: UITableViewCell, ReusableView {
    lazy var title = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
    }
    
    lazy var detail = Label().then {
        $0.font = .font(size: 12, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
    }
    
    lazy var switchBtn = SettingSwitchButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))


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
    
    func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(title)
        contentView.addSubview(detail)
        contentView.addSubview(switchBtn)
        contentView.addSubview(line)
    }
    
    func setupConstraints() {
        title.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.equalToSuperview().offset(15)
        }
        
        switchBtn.snp.makeConstraints {
            $0.centerY.equalTo(title.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.width.equalTo(40)
            $0.height.equalTo(20)
        }
        
        detail.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        line.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.top.equalTo(detail.snp.bottom).offset(15)
        }

    }

}
