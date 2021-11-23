//
//  SupportedViewHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/26.
//

import UIKit

class BrandSearchView: UIView {
    var clickTextFieldCallback: (() -> ())?
    var clickCancelCallback: (() -> ())?
    var searchCallback: ((String) -> ())?

    private lazy var isSearching = false

    lazy var textField = UITextField()
    
    private lazy var cancelBtn = Button().then {
        $0.setTitle("取消".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.clickCancelCallback?()
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

extension BrandSearchView {
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
        
        let searchIcon = ImageView(image: .assets(.search_bold))
        searchIcon.frame = CGRect(x: 15, y: 13, width: 14, height: 14)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        leftView.addSubview(searchIcon)
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        textField.leftView = leftView
        textField.rightView = rightView
    }

    private func setupViews() {
        addSubview(textField)
        addSubview(cancelBtn)
        
        
        textField.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(40)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalTo(cancelBtn.snp.left).offset(-10)
            $0.bottom.equalToSuperview()
        }
        
        cancelBtn.snp.makeConstraints {
            $0.centerY.equalTo(textField.snp.centerY)
            $0.right.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(56.5)
        }
        
    }

    
}

extension BrandSearchView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !self.isSearching {
            clickTextFieldCallback?()
        }
        
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchCallback?(textField.text ?? "")
        return true
    }
}
