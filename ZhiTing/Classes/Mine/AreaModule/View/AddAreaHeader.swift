//
//  AddAreaHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/15.
//

import UIKit

class AddAreaHeader: UIView {
    enum AddAreaHeaderType {
        case family
        case company
    }

    private lazy var line0 = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var textField = UITextField().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15.5, height: 1))
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15.5, height: 1))
        $0.leftView = leftView
        $0.rightView = rightView
        $0.leftViewMode = .always
        $0.rightViewMode = .always
        $0.layer.cornerRadius = 10
        
        let attributedPlaceholder = NSAttributedString(string: "请输入家庭/公司名称".localizedString, attributes: [NSAttributedString.Key.font : UIFont.font(size: 14, type: .bold), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
        $0.attributedPlaceholder = attributedPlaceholder
    }

    private lazy var line1 = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    private lazy var label = Label().then {
        $0.text = "房间".localizedString
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: 11, type: .bold)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    convenience init(type: AddAreaHeaderType) {
        self.init(frame: .zero)
        switch type {
        case .family:
            label.text = "房间".localizedString
            let attributedPlaceholder = NSAttributedString(string: "请输入家庭名称".localizedString, attributes: [NSAttributedString.Key.font : UIFont.font(size: 14, type: .bold), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
            textField.attributedPlaceholder = attributedPlaceholder
        case .company:
            label.text = "部门".localizedString
            let attributedPlaceholder = NSAttributedString(string: "请输入公司名称".localizedString, attributes: [NSAttributedString.Key.font : UIFont.font(size: 14, type: .bold), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
            textField.attributedPlaceholder = attributedPlaceholder
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .custom(.white_ffffff)
        addSubview(line0)
        addSubview(textField)
        addSubview(line1)
        addSubview(label)
    }
    
    private func setupConstraints() {
        line0.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(line0.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(15.5)
            $0.right.equalToSuperview().offset(-15.5)
            $0.height.equalTo(50)
        }
        
        line1.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(20)
            $0.height.equalTo(0.5)
            $0.left.equalToSuperview().offset(15.5)
            $0.right.equalToSuperview().offset(-15.5)
        }
        
        label.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15.5)
            $0.top.equalTo(line1.snp.bottom).offset(13)
            $0.bottom.equalToSuperview().offset(-3.5)
        }
    }

}
