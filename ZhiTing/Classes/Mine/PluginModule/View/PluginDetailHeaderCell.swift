//
//  PluginDetailHeaderCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/1.
//

import UIKit

class PluginDetailHeaderCell: PluginCell {
    private lazy var shadow = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = false
        $0.layer.shadowColor = UIColor.lightGray.cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowRadius = 3
        $0.layer.shadowOffset = CGSize(width: -0.2, height: -0.2)
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).withAlphaComponent(0.3).cgColor
    }
    
    override func setupViews() {
        selectionStyle = .none
        contentView.addSubview(shadow)
        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(versionLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(installButton)
        containerView.addSubview(updateButton)
        containerView.addSubview(deleteButton)
        containerView.addSubview(progressView)
        containerView.addSubview(line)
    }
    
    override func setConstrains() {
        shadow.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview()
        }
        
        super.setConstrains()
    }
}
