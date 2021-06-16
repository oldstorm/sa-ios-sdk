//
//  DeviceSettingHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/16.
//

import UIKit

class DeviceSettingHeader: UIView {
    

    private lazy var titleLabel = Label().then {
        $0.text = "设备名称".localizedString
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
    }
    
    lazy var deviceNameTextField = UITextField().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.layer.cornerRadius = 10
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 14, type: .bold)
        $0.delegate = self
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
        $0.leftViewMode = .always
        $0.rightViewMode = .always
        $0.leftView = leftView
        $0.rightView = rightView

        let attributedPlaceholder = NSAttributedString(string: "请输入设备名称".localizedString, attributes: [NSAttributedString.Key.font : UIFont.font(size: 14, type: .bold), NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_94a5be)])
        $0.attributedPlaceholder = attributedPlaceholder
        
        $0.returnKeyType = .done
        
    }
    
    
    private lazy var deviceLocaltionLabel = Label().then {
        $0.text = "设备位置".localizedString
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: 14, type: .medium)
        $0.isUserInteractionEnabled = false
    }
    
    lazy var addAreaButton = Button().then {
        $0.setTitle("添加房间/区域".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.text = "添加房间或区域".localizedString
        $0.titleLabel?.textAlignment = .right
        $0.titleLabel?.font = .font(size: 14, type: .medium)
        
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
        addSubview(titleLabel)
        addSubview(deviceNameTextField)
        addSubview(deviceLocaltionLabel)
        addSubview(addAreaButton)
        
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(31)
            $0.left.equalToSuperview().offset(15)
        }
        
        deviceNameTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(14.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }

        deviceLocaltionLabel.snp.makeConstraints {
            $0.top.equalTo(deviceNameTextField.snp.bottom).offset(49.5)
            $0.left.equalToSuperview().offset(15)
        }
        
        addAreaButton.snp.makeConstraints {
            $0.centerY.equalTo(deviceLocaltionLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.width.equalTo(140)
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview()
        }

    }
    

    
}

extension DeviceSettingHeader: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.count > 30 {
            textField.text = String(text.prefix(30))
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
