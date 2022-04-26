//
//  InputAlertView.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/15.
//

import UIKit
import IQKeyboardManagerSwift

class InputAlertView: UIView {
    var saveCallback: ((_ text: String) -> ())?
    
    var limitText = 20

    var isSureBtnLoading = false {
        didSet {
            saveButton.selectedChangeView(isLoading: isSureBtnLoading)
        }
    }

    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var label = Label().then {
        $0.text = "房间名称".localizedString
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 16, type: .bold)
    }
    
    private lazy var closeButton = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    lazy var textField = UITextField().then {
        $0.font = .font(size: 14, type: .medium)
        let attributedPlaceholder = NSAttributedString(string: "请输入房间名称".localizedString, attributes: [NSAttributedString.Key.font : UIFont.font(size: 14, type: .bold), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
        $0.attributedPlaceholder = attributedPlaceholder
        $0.delegate = self
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var saveButton = CustomButton(buttonType:
                                                    .leftLoadingRightTitle(
                                                        normalModel:
                                                            .init(
                                                                title: "保存".localizedString,
                                                                titleColor: UIColor.custom(.black_3f4663),
                                                                font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                                backgroundColor: UIColor.custom(.gray_f6f8fd)
                                                            ),
                                                        lodingModel:
                                                            .init(
                                                                title: "保存中...".localizedString,
                                                                titleColor: UIColor.custom(.gray_94a5be),
                                                                font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                                backgroundColor: UIColor.custom(.gray_f6f8fd)
                                                            )
                                                    )
    ).then {
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.addTarget(self, action: #selector(onClick), for: .touchUpInside)
    }
    
    @objc private func onClick() {
        saveCallback?(textField.text ?? "")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    convenience init(labelText: String, placeHolder: String, limitText: Int = 20, saveCallback: ((String) -> ())?) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        self.limitText = limitText
        self.saveCallback = saveCallback
        self.label.text = labelText
        let attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.font : UIFont.font(size: 14, type: .bold), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
        self.textField.attributedPlaceholder = attributedPlaceholder

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
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
            $0.top.equalTo(textField.snp.bottom).offset(5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(0.5)
        }

        saveButton.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(23.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-30)
        }

    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        containerView.isHidden = true
        self.textField.becomeFirstResponder()
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        

        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }) { (finished) in
            if finished {
                IQKeyboardManager.shared.shouldResignOnTouchOutside = true
                super.removeFromSuperview()
            }
        }
        
        
    }
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
    
    
    @objc private func keyboardHide(_ notification:Notification) {
        UIView.animate(withDuration: 0.3) {
            self.containerView.snp.remakeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(-20)
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
            }
            self.layoutIfNeeded()
        }
        
    }
    
    @objc func keyBoardWillShow(note: NSNotification) {
        //1
        let userInfo  = note.userInfo! as NSDictionary
        //2
        let  keyBoardBounds = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        //4
        let deltaY = keyBoardBounds.size.height
        //5
        let animations:(() -> Void) = {
            self.containerView.transform = CGAffineTransform(translationX: 0,y: -deltaY)
        }
        
        containerView.isHidden = false
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        } else{
            animations()
        }
    }
    
}

extension InputAlertView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.count > limitText {
            textField.text = String(text.prefix(limitText))
        }
        
        
        
        if textField.text?.replacingOccurrences(of: " ", with: "").count == 0 {
            saveButton.isEnabled = false
            saveButton.title.textColor = .custom(.gray_94a5be)
        } else {
            saveButton.isEnabled = (text.count > 0)
            saveButton.title.textColor = .custom(.black_333333)
        }
    }
}
