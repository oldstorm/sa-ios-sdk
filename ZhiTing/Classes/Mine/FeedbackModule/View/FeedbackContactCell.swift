//
//  FeedbackContactCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/22.
//

import Foundation
import UIKit

class FeedbackContactCell: UITableViewCell, ReusableView {
    private lazy var titleLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 14, type: .bold)
        $0.text = "联系方式".localizedString
    }
    
    lazy var textField = UITextField().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15.5, height: 1))
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15.5, height: 1))
        $0.leftView = leftView
        $0.rightView = rightView
        $0.leftViewMode = .always
        $0.rightViewMode = .always
        $0.layer.cornerRadius = 2
        
        $0.font = .font(size: 14, type: .medium)
        let attributedPlaceholder = NSAttributedString(string: "为快速解决问题，请留下你的联系方式".localizedString, attributes: [NSAttributedString.Key.font : UIFont.font(size: 12, type: .regular), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
        $0.attributedPlaceholder = attributedPlaceholder
        $0.delegate = self
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
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(18)
            $0.height.equalTo(50)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
}

extension FeedbackContactCell: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.count > 50 {
            textField.text = String(text.prefix(50))
        }
    }
}
