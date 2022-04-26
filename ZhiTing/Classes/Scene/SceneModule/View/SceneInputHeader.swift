//
//  SceneInputHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/12.
//


import UIKit

class SceneInputHeader: UIView {
    private lazy var line0 = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var textField = UITextField().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: ZTScaleValue(15.5), height: 1))
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: ZTScaleValue(15.5), height: 1))
        $0.leftView = leftView
        $0.rightView = rightView
        $0.leftViewMode = .always
        $0.rightViewMode = .always
        $0.layer.cornerRadius = 10
        $0.delegate = self
        let attributedPlaceholder = NSAttributedString(string: "".localizedString, attributes: [NSAttributedString.Key.font : UIFont.font(size: ZTScaleValue(14), type: .bold), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
        $0.attributedPlaceholder = attributedPlaceholder
    }


    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    convenience init(placeHolder: String) {
        self.init(frame: .zero)
        
        let attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.font : UIFont.font(size: ZTScaleValue(14), type: .bold), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
        textField.attributedPlaceholder = attributedPlaceholder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .custom(.white_ffffff)
        addSubview(line0)
        addSubview(textField)

    }
    
    private func setupConstraints() {
        line0.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(0.5))
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(line0.snp.bottom).offset(ZTScaleValue(20))
            $0.left.equalToSuperview().offset(ZTScaleValue(15.5))
            $0.right.equalToSuperview().offset(-ZTScaleValue(15.5))
            $0.height.equalTo(ZTScaleValue(50))
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(20))
        }
        
    }

}

extension SceneInputHeader: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.count > 40 {
            textField.text = String(text.prefix(40))
        }
        
    }
}
