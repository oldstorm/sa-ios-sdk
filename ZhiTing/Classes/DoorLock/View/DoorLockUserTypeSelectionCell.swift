//
//  DoorLockUserTypeSelectionCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/15.
//

import Foundation

class DoorLockUserTypeSelectionCell: UITableViewCell, ReusableView {
    lazy var titleLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
    }

    lazy var selectButton = SelectButton(type: .rounded).then { $0.isUserInteractionEnabled = false }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(titleLabel)
        contentView.addSubview(selectButton)
        contentView.addSubview(line)
    }
    
    private func setupConstraints() {
        selectButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17.5)
            $0.right.equalToSuperview().offset(-15)
            $0.height.width.equalTo(18.5)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalTo(selectButton.snp.left)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(17)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(0.5)
            $0.bottom.equalToSuperview()
        }

    }

    
}
