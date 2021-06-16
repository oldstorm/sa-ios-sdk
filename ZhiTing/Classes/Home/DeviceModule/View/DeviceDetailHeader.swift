//
//  DeviceDetailHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/18.
//

import UIKit

class DeviceDetailHeader: UIView {
    lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.default_device)
    }
    
    lazy var deviceTypeLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
    }
    
    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .custom(.white_ffffff)
        addSubview(icon)
        addSubview(deviceTypeLabel)
        addSubview(line)
        
        icon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(12.5)
            let w = Screen.screenWidth * 0.25
            $0.width.height.equalTo(w)
        }
        
        deviceTypeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(icon.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15).priority(.high)
            $0.right.equalToSuperview().offset(-15).priority(.high)
            
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(deviceTypeLabel.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().priority(.high)
            $0.height.equalTo(10)
            $0.bottom.equalToSuperview()
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
