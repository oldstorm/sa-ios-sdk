//
//  DoorLockOneTimePwdInputView.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/13.
//

import Foundation

class DoorLockOneTimePwdInputView: UIView {
    var code: String? {
        textField.text
    }

    private var isSecure = false {
        didSet {
            if let code = code {
                for (idx, c) in code.enumerated() {
                    inputItems[idx].text = isSecure ? "*" : String(c)
                }
            }
        }
    }

    private lazy var inputItems = [HomeKitInputItemView(), HomeKitInputItemView(), HomeKitInputItemView(), HomeKitInputItemView(), HomeKitInputItemView(), HomeKitInputItemView()]

    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var textField = UITextField().then {
        $0.keyboardType = .numberPad
        $0.delegate = self
    }
    
    lazy var tipsLabelLabel = Label().then {
        $0.text = "请输入6位开锁密码".localizedString
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.textColor = .custom(.gray_94a5be)
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startEditing() {
        textField.becomeFirstResponder()
    }

    func clearCode() {
        textField.text = ""
        updateItemViews()
    }
    
    private func setupViews() {
        addSubview(textField)
        addSubview(containerView)
        addSubview(tipsLabelLabel)
        addSubview(secureButton)
        inputItems.forEach { containerView.addSubview($0) }
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        textField.addTarget(self, action: #selector(updateItemViews), for: .editingChanged)
        inputItems[0].isCurrent = true
        
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalTo(tipsLabelLabel.snp.bottom).offset(15)
            $0.left.right.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
        
        tipsLabelLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(37)
        }
        
        secureButton.snp.makeConstraints {
            $0.centerY.equalTo(tipsLabelLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-37)
            $0.height.equalTo(15)
            $0.width.equalTo(18)
        }

        let margin: CGFloat = ZTScaleValue(26)
        let itemW: CGFloat = (Screen.screenWidth - margin * 7) / 6
        let itemH: CGFloat = itemW * 4 / 3
        
        var offset = margin
        inputItems.forEach { itemView in
            itemView.snp.makeConstraints {
                $0.height.equalTo(itemH)
                $0.width.equalTo(itemW)
                $0.left.equalToSuperview().offset(offset)
                $0.top.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
            
            offset += margin + itemW
        }
    }
    
    @objc
    private func tap() {
        textField.becomeFirstResponder()
    }

    @objc private func updateItemViews() {
        guard let text = textField.text else { return }
        inputItems.forEach { $0.isCurrent = false }
        if text.count < inputItems.count {
            inputItems[text.count].isCurrent = true
        }
        

        if text.count == 0 {
            inputItems[0].text = ""
        }

        for idx in (text.count - 1)..<inputItems.count {
            if idx < inputItems.count && idx > 0 {
                inputItems[idx].text = ""
            }
            
        }

        for (idx, c) in text.enumerated() {
            if idx < inputItems.count {
                inputItems[idx].text = isSecure ? "*" : String(c)
            }
            
        }
        

    }
    
}

extension DoorLockOneTimePwdInputView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text?.prefix(6) else { return }
        textField.text = String(text)

    }
}
