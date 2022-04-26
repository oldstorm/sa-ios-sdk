//
//  DoorLockSettingHeader.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/11.
//

import Foundation

class DoorLockSettingHeader: UIView {

    lazy var containerView = UIView().then {
        $0.backgroundColor = UIColor.custom(.oringe_f6ae1e).withAlphaComponent(0.15)
    }

    private lazy var icon = ImageView().then {
        $0.image = .assets(.icon_warning)
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 12, type: .medium)
        $0.textAlignment = .left
        $0.textColor = .custom(.oringe_f6ae1e)
        $0.text = "门锁设备处于安全考虑，暂只支持当前手机使用。".localizedString
    }
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.addSubview(icon)
        containerView.addSubview(tipsLabel)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        icon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
            $0.height.width.equalTo(14).priority(.high)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.left.equalTo(icon.snp.right).offset(7).priority(.high)
            $0.right.equalToSuperview().offset(-15)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
