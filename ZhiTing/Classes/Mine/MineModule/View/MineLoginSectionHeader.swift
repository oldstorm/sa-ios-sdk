//
//  MineLoginSectionHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/5/7.
//

import UIKit

class MineLoginSectionHeader: UIView {
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var button = Button().then {
        $0.setTitle("登录".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.layer.cornerRadius = ZTScaleValue(4)
    }

    private lazy var label = Label().then {
        $0.text = "登录后，可远程控制设备".localizedString
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
    }

    private lazy var line1 = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .custom(.white_ffffff)
        addSubview(line)
        addSubview(button)
        addSubview(label)
        addSubview(line1)
    }
    
    private func setConstraints() {
        line.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview().priority(.high)
            $0.height.equalTo(0.5)
        }
        
        button.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(14.5))
            $0.left.equalToSuperview().offset(ZTScaleValue(15)).priority(.high)
            $0.height.equalTo(ZTScaleValue(30))
            $0.width.equalTo(ZTScaleValue(70))
        }
        
        label.snp.makeConstraints {
            $0.centerY.equalTo(button.snp.centerY)
            $0.left.equalTo(button.snp.right).offset(ZTScaleValue(15))
        }
        
        line1.snp.makeConstraints {
            $0.top.equalTo(button.snp.bottom).offset(ZTScaleValue(15))
            $0.left.right.equalToSuperview().priority(.high)
            $0.height.equalTo(10)
        }

    }

}
