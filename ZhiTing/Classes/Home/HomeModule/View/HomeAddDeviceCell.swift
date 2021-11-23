//
//  HomeAddDeviceCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/12.
//

import UIKit

class HomeAddDeviceCell: UICollectionViewCell, ReusableView {
    
    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_add_device)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        clipsToBounds = true
        contentView.backgroundColor = .custom(.white_ffffff)
        layer.cornerRadius = 10
        contentView.addSubview(icon)
        
    }
    
    private func setConstrains() {
        icon.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.35)
            $0.height.equalToSuperview().multipliedBy(0.35)
        }
        
        

    }
    
}
