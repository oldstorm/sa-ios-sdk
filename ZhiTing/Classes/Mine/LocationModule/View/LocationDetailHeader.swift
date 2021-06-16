//
//  LocationDetailHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/15.
//

import UIKit

class LocationDetailHeader: UIView {
    var changeNameCallback: (() -> ())?

    private lazy var topContainerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeNameClicked)))
    }
    
    private lazy var titleLabel = Label().then {
        $0.text = "名称".localizedString
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_3f4663)
    }
    
    lazy var valueLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
        $0.textAlignment = .right
        $0.text = " "
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }

    private lazy var arrow = ImageView().then {
        $0.image = .assets(.arrow_right)
        $0.contentMode = .scaleAspectFit
        $0.alpha = 0.3
    }
    
    lazy var deviceLabel = Label().then {
        $0.text = "房间设备".localizedString
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = .custom(.gray_f6f8fd)
        topContainerView.backgroundColor = .custom(.white_ffffff)
        addSubview(topContainerView)
        topContainerView.addSubview(line)
        topContainerView.addSubview(titleLabel)
        topContainerView.addSubview(valueLabel)
        topContainerView.addSubview(arrow)
        addSubview(deviceLabel)
    }
    
    func setupConstraints() {
        topContainerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
        
        line.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
        }

        arrow.snp.makeConstraints {
            $0.width.equalTo(7.5)
            $0.height.equalTo(13.5)
            $0.top.equalToSuperview().offset(23)
            $0.right.equalToSuperview().offset(-15)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(19)
            $0.left.equalToSuperview().offset(14.5)
        }
        
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(19)
            $0.left.equalTo(titleLabel.snp.right).offset(14)
            $0.right.equalTo(arrow.snp.left).offset(-14)
            $0.bottom.equalToSuperview().offset(-18)
        }
        
        deviceLabel.snp.makeConstraints {
            $0.top.equalTo(topContainerView.snp.bottom).offset(13)
            $0.left.equalToSuperview().offset(15)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
    }
    
    
    @objc private func changeNameClicked() {
        changeNameCallback?()
    }
}
