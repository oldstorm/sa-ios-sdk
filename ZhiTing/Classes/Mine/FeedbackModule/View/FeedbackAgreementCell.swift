//
//  FeedbackAgreementCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/22.
//

import Foundation
import UIKit

class FeedbackAgreementCell: UITableViewCell, ReusableView {
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }

    private lazy var titleLabel = Label().then {
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 14, type: .regular)
        $0.text = "同意工程师查看智慧中心/应用/设备相关信息，以便准确诊断问题".localizedString
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }
    
    lazy var selectButton = SelectButton(type: .rounded)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func tap() {
        selectButton.clicked()
    }

    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(line)
        contentView.addSubview(titleLabel)
        contentView.addSubview(selectButton)
        
    }
    
    private func setupConstraints() {
        line.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(10)
            
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(44)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-15)
        }
        
        selectButton.snp.makeConstraints {
            $0.width.height.equalTo(18)
            $0.left.equalToSuperview().offset(15)
            $0.centerY.equalTo(titleLabel.snp.centerY)
        }

        
    }
}

