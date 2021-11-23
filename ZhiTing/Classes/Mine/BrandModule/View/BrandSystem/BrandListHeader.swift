//
//  BrandListHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/4.
//

import UIKit

class BrandListHeader: UIView {
    
    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(12), type: .medium)
        $0.text = "可添加以下品牌的设备，如需添加其他品牌，可点击右上角搜索图标添加；如系统没有对应品牌的插件，可切换至【创作】中手动上传插件；".localizedString
        $0.numberOfLines = 0
        $0.textAlignment = .left
        $0.textColor = .custom(.gray_94a5be)
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
}

extension BrandListHeader {
    private func setupViews() {
        addSubview(tipsLabel)
        addSubview(line)
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-12.5)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }

}

