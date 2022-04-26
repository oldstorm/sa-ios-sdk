//
//  NormalTextField.swift
//  ZhiTing
//
//  Created by zy on 2022/1/11.
//

import UIKit
import Combine

class NormalTextField: UIView {
    
    lazy var limitCount = 20
    

    var text: String {
        return textField.text ?? ""
    }
    
    var textPublisher = CurrentValueSubject<String, Never>("")
        
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .right
    }
    
    lazy var textField = UITextField().then {
        $0.font = .font(size: ZTScaleValue(14), type: .D_bold)
        $0.textColor = .custom(.black_3f4663)
        $0.delegate = self
        $0.backgroundColor = .custom(.gray_eeeeee)
        $0.layer.cornerRadius = ZTScaleValue(4)
        $0.clipsToBounds = true
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: ZTScaleValue(15), height: 0))
        $0.leftViewMode = .always
//        $0.setValue(ZTScaleValue(10), forKey: "paddingLeft")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()

    }
    
    convenience init(
        frame: CGRect = .zero,
        keyboardType: UIKeyboardType = .default,
        title: String,
        placeHolder: String,
        limitCount: Int = 20
    ) {
        self.init(frame: frame)
        titleLabel.text = title
        let attrPlaceHolder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.font : UIFont.font(size: 14, type: .regular), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
        textField.attributedPlaceholder = attrPlaceHolder
        self.limitCount = limitCount
        textField.keyboardType = keyboardType
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(textField)
        
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalTo(textField.snp.left).offset(-ZTScaleValue(10))
        }
        
        textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-ZTScaleValue(23.5))
            $0.width.equalTo(ZTScaleValue(175))
            $0.height.equalTo(ZTScaleValue(50))
            $0.bottom.equalToSuperview()
        }

    }

}


extension NormalTextField: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if let text = textField.text {
            textField.text = String(text.prefix(limitCount))
        }

    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

}

