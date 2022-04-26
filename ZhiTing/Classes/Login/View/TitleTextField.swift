//
//  TitleTextField.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/22.
//

import UIKit
import Combine

class TitleTextField: UIView {
    let cleanWarningNoti = NSNotification.Name.init("TitleTextField_cleanWarningNoti")

    lazy var limitCount = 20
    
    private var isSecure = false {
        didSet {
            textField.isSecureTextEntry = isSecure
        }
    }

    var text: String {
        return textField.text ?? ""
    }
    
    var textPublisher = CurrentValueSubject<String, Never>("")
    
    var warning: String {
        set {
            warningLabel.text = newValue
        }
        
        get {
            return warningLabel.text ?? ""
        }
    }
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.gray_94a5be)
    }
    
    lazy var textField = UITextField().then {
//        $0.font = .font(size: 20, type: .bold)
        $0.font = .font(size: 24, type: .D_bold)
        $0.textColor = .custom(.black_3f4663)
        $0.delegate = self
    }
    
    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_dddddd)
    }
    
    private lazy var warningLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.red_fe0000)
        $0.numberOfLines = 0
    }
    
    private lazy var secureButton = Button(frame: CGRect(x: 0, y: 0, width: 18, height: 15)).then {
        $0.setImage(.assets(.showPwd), for: .selected)
        $0.setImage(.assets(.hidePwd), for: .normal)
        $0.isEnhanceClick = true
        $0.clickCallBack = { [weak self] button in
            guard let self = self else { return }
            button.isSelected = !button.isSelected
            self.isSecure = button.isSelected
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(cleanWarnings), name: cleanWarningNoti, object: nil)
        textField.addTarget(self, action: #selector(textChanged), for: .valueChanged)
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

    }
    
    convenience init(
        frame: CGRect = .zero,
        keyboardType: UIKeyboardType = .default,
        title: String,
        placeHolder: String,
        isSecure: Bool = false,
        limitCount: Int = 20
    ) {
        self.init(frame: frame)
        titleLabel.text = title
        let attrPlaceHolder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.font : UIFont.font(size: 14, type: .regular), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
        textField.attributedPlaceholder = attrPlaceHolder
        if isSecure {
            textField.rightViewMode = .always
            textField.rightView = secureButton
            secureButton.isSelected = true
            textField.isSecureTextEntry = isSecure
        }
        self.limitCount = limitCount
        textField.keyboardType = keyboardType
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(line)
        addSubview(warningLabel)
        
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        line.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(textField.snp.bottom)
            $0.height.equalTo(0.5)
        }
        
        warningLabel.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }


    }

}


extension TitleTextField: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        NotificationCenter.default.post(name: cleanWarningNoti, object: nil)
        if let text = textField.text {
            textField.text = String(text.prefix(limitCount))
        }
        
        
        
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        line.backgroundColor = .custom(.black_3f4663)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        line.backgroundColor = .custom(.gray_dddddd)
    }

    @objc private func cleanWarnings() {
        warningLabel.text = ""
    }
    
    @objc private func textChanged() {
        if let t = textField.text {
            textPublisher.send(t)
            
        }
        
    }
}
