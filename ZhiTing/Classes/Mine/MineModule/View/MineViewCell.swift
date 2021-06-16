//
//  MineViewCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/24.
//

import UIKit

class MineViewCell: UITableViewCell, ReusableView {
    lazy var icon = ImageView().then {
        $0.image = .assets(.icon_brand)
    }
    
    lazy var title = Label().then {
        $0.text = "  ".localizedString
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var arrow = ImageView().then {
        $0.image = .assets(.arrow_right)
    }
    
    private lazy var line = UIView().then { $0.backgroundColor = .custom(.gray_eeeeee) }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(icon)
        contentView.addSubview(title)
        contentView.addSubview(arrow)
        contentView.addSubview(line)

        
        icon.snp.makeConstraints {
            $0.width.equalTo(16)
            $0.height.equalTo(16)
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(19.5)
        }
        
        title.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(icon.snp.right).offset(14.5)
        }
        
        arrow.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(7)
            $0.height.equalTo(12.5)
        }
        
        line.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.right.equalToSuperview()
            $0.left.equalToSuperview().offset(50)
        }
    }
    
}
