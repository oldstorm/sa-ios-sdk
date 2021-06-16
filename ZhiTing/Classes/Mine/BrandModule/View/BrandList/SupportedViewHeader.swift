//
//  SupportedViewHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/26.
//

import UIKit

class SupportedViewHeader: UIView {
    var clickTextFieldCallback: (() -> ())?
    var clickCancelCallback: (() -> ())?
    var searchCallback: ((String) -> ())?

    private lazy var isSearching = false

    private lazy var textField = UITextField()
    
    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 11, type: .medium)
        $0.text = #"可添加以下品牌的设备，如需添加其他品牌，可搜索添加；如系统没有对应品牌的插件，可点击【添加插件】，手动上传；"#.localizedString
        $0.numberOfLines = 0
        $0.textAlignment = .left
        $0.textColor = .custom(.gray_94a5be)
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    private lazy var cancelBtn = Button().then {
        $0.setTitle("取消".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.isHidden = true
        $0.clickCallBack = { [weak self] _ in
            self?.transformUI(isSearching: false)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
}

extension SupportedViewHeader {
    private func setupTextField() {
        textField.delegate = self
        textField.backgroundColor = .custom(.gray_f1f4fd)
        textField.layer.cornerRadius = 20
        textField.font = .font(size: 14, type: .medium)
        textField.textColor = .custom(.black_3f4663)
        textField.attributedPlaceholder = NSAttributedString(string: "输入品牌名称搜索".localizedString, attributes: [
            NSAttributedString.Key.font : UIFont.font(size: 14, type: .medium),
            NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)
        ])
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.returnKeyType = .search
        
        let searchIcon = ImageView(image: .assets(.search))
        searchIcon.frame = CGRect(x: 15, y: 13, width: 14, height: 14)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        leftView.addSubview(searchIcon)
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        textField.leftView = leftView
        textField.rightView = rightView
    }

    private func setupViews() {
        addSubview(textField)
        addSubview(tipsLabel)
        addSubview(cancelBtn)
        addSubview(line)
        
        
        textField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.height.equalTo(40)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.centerY.equalTo(textField.snp.centerY)
            $0.right.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(56.5)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(11.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-12.5)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
    
    private func transformUI(isSearching: Bool) {
        self.isSearching = isSearching
        if isSearching {
            self.cancelBtn.alpha = 0
            self.cancelBtn.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                guard let self = self else { return }
                self.cancelBtn.alpha = 1
                self.tipsLabel.alpha = 0
                self.line.alpha = 0
                self.textField.snp.updateConstraints {
                    $0.right.equalToSuperview().offset(-58)
                }
                self.layoutIfNeeded()
                
            }, completion: { [weak self] isFinished in
                guard let self = self else { return }
                if isFinished {
                    self.tipsLabel.isHidden = true
                    self.line.isHidden = true
                    self.line.snp.removeConstraints()
                    self.textField.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(5)
                        $0.height.equalTo(40)
                        $0.left.equalToSuperview().offset(15)
                        $0.right.equalToSuperview().offset(-58)
                        $0.bottom.equalToSuperview()
                    }
                    
                }
            })
            
        } else {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                guard let self = self else { return }
                self.cancelBtn.alpha = 0
                self.tipsLabel.alpha = 1
                self.line.alpha = 1
                self.textField.snp.updateConstraints {
                    $0.right.equalToSuperview().offset(-15)
                }
                self.layoutIfNeeded()
                
            }, completion: { [weak self] isFinished in
                guard let self = self else { return }
                if isFinished {
                    self.textField.resignFirstResponder()
                    self.textField.text = ""
                    self.cancelBtn.isHidden = true
                    self.tipsLabel.isHidden = false
                    self.line.isHidden = false
                    self.textField.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(5)
                        $0.height.equalTo(40)
                        $0.left.equalToSuperview().offset(15)
                        $0.right.equalToSuperview().offset(-15)
                    }
                    self.line.snp.remakeConstraints {
                        $0.top.equalTo(self.tipsLabel.snp.bottom).offset(10)
                        $0.left.equalToSuperview()
                        $0.right.equalToSuperview()
                        $0.bottom.equalToSuperview()
                        $0.height.equalTo(0.5)
                    }
                    self.clickCancelCallback?()
                    self.searchCallback?("")
                }
            })
        }
        


    }
}

extension SupportedViewHeader: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !self.isSearching {
            clickTextFieldCallback?()
            transformUI(isSearching: true)
        }
        
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchCallback?(textField.text ?? "")
        return true
    }
}
