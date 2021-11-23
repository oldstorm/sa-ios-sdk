//
//  SetProAccountCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/19.
//

import UIKit

class SetProAccountCell: UITableViewCell, ReusableView {
    var limitCount = 20
    
    var placeHolder: String = "" {
        didSet {
            let attrPlaceHolder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.font : UIFont.font(size: 14, type: .regular), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
            textField.attributedPlaceholder = attrPlaceHolder
        }
    }

    lazy var label = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
    }
    
    lazy var textField = UITextField().then {
        $0.font = .font(size: 14, type: .bold)
        $0.keyboardType = .asciiCapable
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
        contentView.addSubview(label)
        contentView.addSubview(textField)
    }
    
    private func setupConstraints() {
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.width.equalTo(80)
        }
        
        textField.snp.makeConstraints {
            $0.left.equalTo(label.snp.right).offset(ZTScaleValue(40))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.centerY.equalToSuperview()
        }
    }
}

extension SetProAccountCell: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text {
            textField.text = String(text.prefix(limitCount))
        }
       
    }
}
