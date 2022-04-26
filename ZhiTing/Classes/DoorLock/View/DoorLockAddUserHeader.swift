//
//  DoorLockAddUserHeader.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/15.
//

import Foundation

class DoorLockAddUserHeader: UIView {

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
    }

    private lazy var line1 = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    convenience init() {
        self.init(frame: .zero)
        let attributedPlaceholder = NSAttributedString(string: "请输入用户名".localizedString, attributes: [NSAttributedString.Key.font : UIFont.font(size: 14, type: .bold), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
        textField.attributedPlaceholder = attributedPlaceholder
      

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .custom(.white_ffffff)
        addSubview(line0)
        addSubview(textField)
        addSubview(line1)
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
            $0.height.equalTo(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
    }

}
