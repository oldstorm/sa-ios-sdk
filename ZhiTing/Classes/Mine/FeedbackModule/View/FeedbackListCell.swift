//
//  FeedbackListCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/22.
//

import Foundation
import UIKit


class FeedbackListCell: UITableViewCell, ReusableView {
    var feedback: Feedback? {
        didSet {
            titleLabel.text = feedback?.description
            typeLabel.text = feedback?.feedbackType?.title
            dateLabel.text = feedback?.formattedDate
        }
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }

    private lazy var titleLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.text = " "
        $0.font = .font(size: 14, type: .bold)
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private lazy var typeIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_feedback_suggestion)
    }
    
    private lazy var typeLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.text = " "
        $0.font = .font(size: 12, type: .medium)
    }
    
    private lazy var dateIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_date)
    }
    
    private lazy var dateLabel = Label().then {
        $0.textColor = .custom(.gray_94a5be)
        $0.text = " "
        $0.font = .font(size: 14, type: .medium)
    }
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .custom(.gray_f6f8fd)
        contentView.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(typeIcon)
        container.addSubview(typeLabel)
        container.addSubview(dateIcon)
        container.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        container.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-25)
        }
        
        typeIcon.snp.makeConstraints {
            $0.height.width.equalTo(14)
            $0.top.equalTo(titleLabel.snp.bottom).offset(14)
            $0.left.equalToSuperview().offset(15)
        }
        
        typeLabel.snp.makeConstraints {
            $0.centerY.equalTo(typeIcon.snp.centerY)
            $0.left.equalTo(typeIcon.snp.right).offset(9.5)
            $0.right.equalToSuperview().offset(-10)
        }
        
        dateIcon.snp.makeConstraints {
            $0.top.equalTo(typeIcon.snp.bottom).offset(10.5)
            $0.height.width.equalTo(14)
            $0.left.equalToSuperview().offset(15)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(dateIcon.snp.centerY)
            $0.left.equalTo(dateIcon.snp.right).offset(10)
            $0.right.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(-16)
        }

    }
    
}
