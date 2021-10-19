//
//  HomekitInputView.swift
//  ZhiTing
//
//  Created by iMac on 2021/5/27.
//

import UIKit

class HomekitInputView: UIView {
    var completeCallback: ((_ code: String) -> ())?

    private lazy var inputItems = [HomeKitInputItemView(), HomeKitInputItemView(), HomeKitInputItemView(), HomeKitInputItemView(), HomeKitInputItemView(), HomeKitInputItemView(), HomeKitInputItemView(), HomeKitInputItemView()]

    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var textField = UITextField().then {
        $0.keyboardType = .numberPad
        $0.delegate = self
    }
    
    lazy var warningLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.textColor = .custom(.red_fe0000)
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

    func clearCode(warning: String?) {
        textField.text = ""
        updateItemViews()
        textField.becomeFirstResponder()
        warningLabel.text = warning
    }
    
    private func setupViews() {
        addSubview(textField)
        addSubview(containerView)
        addSubview(warningLabel)
        inputItems.forEach { containerView.addSubview($0) }
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        textField.addTarget(self, action: #selector(updateItemViews), for: .editingChanged)
        inputItems[0].isCurrent = true
        
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
        
        warningLabel.snp.makeConstraints {
            $0.left.equalTo(containerView.snp.left).offset(ZTScaleValue(15))
            $0.top.equalTo(containerView.snp.bottom).offset(ZTScaleValue(10))
            $0.right.equalTo(containerView.snp.right).offset(ZTScaleValue(-15))
            $0.bottom.equalToSuperview()
        }

        let margin: CGFloat = ZTScaleValue(15)
        let itemW: CGFloat = (Screen.screenWidth - margin * 9) / 8
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
                inputItems[idx].text = String(c)
            }
            
        }
        

    }
    
}

extension HomekitInputView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text?.prefix(8) else { return }
        textField.text = String(text)
        warningLabel.text = ""
        if String(text).count == 8 {
            completeCallback?(String(text))
        }

    }
}


fileprivate class HomeKitInputItemView: UIView {
    var text: String = "" {
        didSet {
            label.text = text
        }
    }
    
    var isCurrent: Bool = false {
        didSet {
            lineView.layer.borderColor = isCurrent ? UIColor.custom(.blue_2da3f6).cgColor : UIColor.custom(.gray_dddddd).cgColor
        }
        
    }


    private lazy var lineView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.custom(.gray_dddddd).cgColor
    }
    
    private lazy var label = Label().then {
        $0.font = .font(size: ZTScaleValue(20), type: .bold)
        $0.textColor = .custom(.black_3f4663)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(lineView)
        addSubview(label)
    }
    
    private func setupConstraints() {
        lineView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

}
