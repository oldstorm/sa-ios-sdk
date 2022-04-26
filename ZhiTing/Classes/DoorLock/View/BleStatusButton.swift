//
//  BleStatusButton.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/11.
//

import UIKit

class BleStatusButton: Button {
    
    var isOnline = false {
        didSet {
            title.text = isOnline ? "蓝牙连接".localizedString : "蓝牙未连接".localizedString
            title.textColor = isOnline ? .custom(.blue_2da3f6) : .custom(.gray_cfd6e0)
            image.image = isOnline ? .assets(.icon_ble_online) : .assets(.icon_ble_offline)
            layer.borderColor = isOnline ? UIColor.custom(.blue_2da3f6).cgColor : UIColor.custom(.gray_94a5be).cgColor
        }
    }
    
    private lazy var title = Label().then {
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: 12, type: .medium)
        $0.text = "蓝牙未连接".localizedString
    }
    
    private lazy var image = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_ble_offline)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 0.5
        layer.cornerRadius = 12.5

        addSubview(image)
        addSubview(title)
        
        title.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(image.snp.right).offset(5)
            $0.right.equalToSuperview().offset(-5)
        }
        
        image.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(10)
            $0.width.equalTo(10)
            $0.height.equalTo(15)
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}
