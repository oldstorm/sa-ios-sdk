//
//  FamilyAlertView.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/15.
//

import UIKit

class FamilyAlertView: UIView {
    var saveCallback: (() -> ())?

    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 10
    }
    
    private lazy var label = Label().then {
        $0.text = "房间/区域名称".localizedString
        $0.textColor = Colors.black_3f4663
        $0.font = .font(size: 16, type: .bold)
    }
    
    private lazy var closeButton = Button().then {
        $0.setImage(Assets.closeButton, for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private lazy var textField = UITextField().then {
        $0.font = .font(size: 14, type: .medium)
        let attributedPlaceholder = NSAttributedString(string: "请输入房间/区域名称".localizedString, attributes: [NSAttributedString.Key.font : UIFont.font(size: 14, type: .bold), NSAttributedString.Key.foregroundColor : Colors.gray_94a5be])
        $0.attributedPlaceholder = attributedPlaceholder
        $0.delegate = self
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = Colors.gray_eeeeee
    }

    
    private lazy var saveButton = Button().then {
        $0.setTitle("保存".localizedString, for: .normal)
        $0.setTitleColor(Colors.black_3f4663, for: .normal)
        $0.setTitleColor(Colors.gray_94a5be, for: .disabled)
        $0.backgroundColor = Colors.gray_f1f4fd
        $0.layer.cornerRadius = 10
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.clickCallBack = { [weak self] _ in
            self?.saveCallback?()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    convenience init(saveCallback: (() -> ())?) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        self.saveCallback = saveCallback
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(label)
        containerView.addSubview(closeButton)
        containerView.addSubview(textField)
        containerView.addSubview(line)
        containerView.addSubview(saveButton)
        
        saveButton.isEnabled = false
        closeButton.isEnhanceClick = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-20)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        label.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17.5)
            $0.left.equalToSuperview().offset(16.5)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17.5)
            $0.right.equalToSuperview().offset(-15)
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(23)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(16)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }

        saveButton.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(23.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-25)
        }

    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
            
        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
        
        
    }
    
    @objc private func keyboardShow(_ notification:Notification) {
        let user_info = notification.userInfo
        let keyboardRect = (user_info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.containerView.snp.remakeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-keyboardRect.height - 30)
                $0.left.equalToSuperview().offset(15)
                $0.right.equalToSuperview().offset(-15)
            }
            self.layoutIfNeeded()
        }
        
    }
    
    @objc private func keyboardHide(_ notification:Notification) {
        UIView.animate(withDuration: 0.3) {
            self.containerView.snp.remakeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(-20)
                $0.left.equalToSuperview().offset(15)
                $0.right.equalToSuperview().offset(-15)
            }
            self.layoutIfNeeded()
        }
        
    }
    
}

extension FamilyAlertView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.count > 30 {
            textField.text = String(text.prefix(30))
        }
        
        
        
        if textField.text?.replacingOccurrences(of: " ", with: "").count == 0 {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = (text.count > 0)
        }
    }
}
