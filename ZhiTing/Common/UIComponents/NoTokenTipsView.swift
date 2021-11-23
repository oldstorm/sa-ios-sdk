//
//  NoTokenTipsView.swift
//  ZhiTing
//
//  Created by macbook on 2021/9/2.
//

import UIKit

class NoTokenTipsView: UIView {

    lazy var containerView = UIView().then {
        $0.backgroundColor = UIColor.custom(.oringe_f6ae1e).withAlphaComponent(0.15)
        $0.layer.cornerRadius = 10
    }

    private lazy var icon = ImageView().then {
        $0.image = .assets(.icon_warning)
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 12, type: .medium)
        $0.textAlignment = .left
        $0.textColor = .custom(.oringe_f6ae1e)
        $0.text = "当前终端无凭证或已过期！".localizedString
    }
    
    lazy var arrowIcon = ImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .custom(.oringe_f6ae1e)
        $0.contentMode = .scaleAspectFit
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.addSubview(icon)
        containerView.addSubview(tipsLabel)
        containerView.addSubview(arrowIcon)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        icon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
            $0.height.width.equalTo(14)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.left.equalTo(icon.snp.right).offset(7)
            $0.right.equalToSuperview().offset(-15)
        }
        
        arrowIcon.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.right.equalToSuperview().offset(ZTScaleValue(-14.5))
            $0.width.equalTo(ZTScaleValue(7.5))
            $0.height.equalTo(ZTScaleValue(13.5))
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
