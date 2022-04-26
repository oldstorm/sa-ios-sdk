//
//  TextfiedAlertView.swift
//  ZhiTing
//
//  Created by zy on 2022/1/11.
//

import UIKit

enum TextFieldAlertType {
    case changePwd
    case changeUserName(userName: String)
}

class TextFieldAlertView: UIView {
    var changePwdCallback: ((_ oldPWd: String, _ newPwd: String) -> ())?
    var changeUserNameCallback: ((_ userName: String) -> ())?
    var cancelCallback: (() -> ())?

    var removeWithSure = true
    
    var isSureBtnLoading = false {
        didSet {
            sureBtn.selectedChangeView(isLoading: isSureBtnLoading)
        }
    }
    
    var textFileType = TextFieldAlertType.changePwd
    
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.3)
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }

    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(16), type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private lazy var oldPwdTextField = NormalTextField(title: "旧密码:".localizedString, placeHolder: "请输入旧密码".localizedString).then {
        $0.textField.isSecureTextEntry = true
    }
    private lazy var newPwdTextField = NormalTextField(title: "新密码:".localizedString, placeHolder: "请输入新密码".localizedString).then {
        $0.textField.isSecureTextEntry = true
    }
    private lazy var confirmNewPwdTextField = NormalTextField(title: "确认新密码:".localizedString, placeHolder: "请确认新密码".localizedString).then {
        $0.textField.isSecureTextEntry = true
    }
    private lazy var userNameTextField = NormalTextField(title: "用户名:".localizedString, placeHolder: "请输入用户名".localizedString)

    
    
    private lazy var sureBtn = CustomButton(buttonType:
                                                .centerTitleAndLoading(normalModel:
                                                                        .init(
                                                                            title: "确定".localizedString,
                                                                            titleColor: .custom(.blue_2da3f6),
                                                                            font: .font(size: ZTScaleValue(14), type: .bold),
                                                                            backgroundColor: .custom(.white_ffffff)
                                                                        )
                                                )).then {
                                                    $0.layer.borderWidth = 0.5
                                                    $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
                                                    $0.addTarget(self, action: #selector(onClickSure), for: .touchUpInside)
                                                }
    
    private lazy var cancelBtn = Button().then {
        $0.setTitle("取消".localizedString, for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.cancelCallback?()
            self?.removeFromSuperview()
        }

        
    }

    @objc private func onClickSure() {
        switch textFileType {
        case .changePwd:
            
            if oldPwdTextField.text.count < 6 {
                makeToast( "密码不能少于6位".localizedString)
                return
            }
            
            if newPwdTextField.text.count < 6 {
                makeToast("密码不能少于6位")
                return
            }
            
            if confirmNewPwdTextField.text.count < 6 {
                makeToast("密码不能少于6位")
                return
            }
            
            if newPwdTextField.text != confirmNewPwdTextField.text {
                makeToast("两次新密码输入不一致")
                return
            }
            changePwdCallback?(oldPwdTextField.text,confirmNewPwdTextField.text)
        case .changeUserName:
            if userNameTextField.text == "" {
                makeToast("用户名不能为空")
                return
            }
            changeUserNameCallback?(userNameTextField.text)
            
        }
        if removeWithSure {
            removeFromSuperview()
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    convenience init(frame: CGRect, title: String, textFileType: TextFieldAlertType) {
        self.init(frame: frame)
        self.tipsLabel.text = title
        self.textFileType = textFileType
        switch textFileType {
        case .changeUserName(let userName):
            let attrPlaceHolder = NSAttributedString(string: userName, attributes: [NSAttributedString.Key.font : UIFont.font(size: 14, type: .regular), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
            userNameTextField.textField.attributedPlaceholder = attrPlaceHolder
        default:
            break
        }
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        container.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform.identity
        })
            
        
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        },completion: { isFinished in
            if isFinished {
                super.removeFromSuperview()
            }
            
        })
        
    }
    
    private func setupViews() {
        addSubview(cover)
        addSubview(container)
        container.addSubview(tipsLabel)
        switch self.textFileType {
        case .changePwd:
            container.addSubview(oldPwdTextField)
            container.addSubview(newPwdTextField)
            container.addSubview(confirmNewPwdTextField)
        case .changeUserName:
            container.addSubview(userNameTextField)
        }
        container.addSubview(sureBtn)
        container.addSubview(cancelBtn)
        
    }

    private func setConstrains() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 75)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(15))
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        switch self.textFileType {
        case .changePwd:
            oldPwdTextField.snp.makeConstraints {
                $0.top.equalTo(tipsLabel.snp.bottom).offset(ZTScaleValue(20))
                $0.left.right.equalToSuperview()
            }
            
            newPwdTextField.snp.makeConstraints {
                $0.top.equalTo(oldPwdTextField.snp.bottom).offset(ZTScaleValue(12.5))
                $0.left.right.equalToSuperview()
            }
            confirmNewPwdTextField.snp.makeConstraints {
                $0.top.equalTo(newPwdTextField.snp.bottom).offset(ZTScaleValue(12.5))
                $0.left.right.equalToSuperview()
            }
            
            sureBtn.snp.makeConstraints {
                $0.height.equalTo(50)
                $0.right.equalToSuperview()
                $0.top.equalTo(confirmNewPwdTextField.snp.bottom).offset(ZTScaleValue(23))
                $0.width.equalTo((Screen.screenWidth - 75) / 2)
            }
            
            cancelBtn.snp.makeConstraints {
                $0.height.equalTo(50)
                $0.left.equalToSuperview()
                $0.top.equalTo(confirmNewPwdTextField.snp.bottom).offset(23)
                $0.width.equalTo((Screen.screenWidth - 75) / 2)
                $0.bottom.equalToSuperview()
            }

        case .changeUserName:
            userNameTextField.snp.makeConstraints {
                $0.top.equalTo(tipsLabel.snp.bottom).offset(ZTScaleValue(20))
                $0.left.right.equalToSuperview()
            }
            
            sureBtn.snp.makeConstraints {
                $0.height.equalTo(50)
                $0.right.equalToSuperview()
                $0.top.equalTo(userNameTextField.snp.bottom).offset(ZTScaleValue(23))
                $0.width.equalTo((Screen.screenWidth - 75) / 2)
            }
            
            cancelBtn.snp.makeConstraints {
                $0.height.equalTo(50)
                $0.left.equalToSuperview()
                $0.top.equalTo(userNameTextField.snp.bottom).offset(23)
                $0.width.equalTo((Screen.screenWidth - 75) / 2)
                $0.bottom.equalToSuperview()
            }

        }
        
    }
    
    @discardableResult
    static func show(title: String, textFieldType: TextFieldAlertType, sureTitle: String = "确定".localizedString, changePwdCallback: ((_ oldPWd: String, _ newPwd: String) -> ())?, changeUserNameCallback: ((_ userName: String) -> ())?, cancelCallback: (() -> ())? = nil, removeWithSure: Bool = true) -> TextFieldAlertView {
        let tipsView = TextFieldAlertView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight),title: title, textFileType: textFieldType)
        tipsView.sureBtn.title.text = sureTitle.localizedString
        tipsView.sureBtn.nomalStruct = .init(
            title: sureTitle.localizedString,
            titleColor: .custom(.blue_2da3f6),
            font: .font(size: 14, type: .bold),
            backgroundColor: .custom(.white_ffffff)
        )
        tipsView.removeWithSure = removeWithSure
        tipsView.changePwdCallback = changePwdCallback
        tipsView.changeUserNameCallback = changeUserNameCallback
        tipsView.cancelCallback = cancelCallback
        UIApplication.shared.windows.first?.addSubview(tipsView)
        return tipsView
    }

}

