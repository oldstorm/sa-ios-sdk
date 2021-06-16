//
//  NoAuthTipsView.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/1.
//

import UIKit

class NoAuthTipsView: UIView {
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
        $0.text = "智慧中心连接失败或者无权限!".localizedString
    }
    
    lazy var refreshBtn = RefreshButton(style: .refresh).then {
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.addSubview(icon)
        containerView.addSubview(tipsLabel)
        containerView.addSubview(refreshBtn)

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
        
        refreshBtn.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.right.equalToSuperview().offset(ZTScaleValue(-14.5))
            $0.width.equalTo(ZTScaleValue(40))
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
