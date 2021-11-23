//
//  LocationDetailDeviceCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/16.
//

import UIKit

class LocationDetailDeviceCell: UICollectionViewCell, ReusableView {
    var device: Device? {
        didSet {
            guard let device = device else { return }
            image.setImage(urlString: device.logo_url, placeHolder: .assets(.default_device))
            titleLabel.text = device.name
        }
    }

    private lazy var image = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.default_device)
    }
    
    private lazy var titleLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 14, type: .regular)
        $0.textAlignment = .center
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .custom(.white_ffffff)
        layer.cornerRadius = 10
        contentView.addSubview(image)
        contentView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        image.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-6.5)
            $0.width.equalToSuperview().multipliedBy(0.4)
            $0.height.equalToSuperview().multipliedBy(0.4)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(image.snp.bottom).offset(5)
            $0.left.equalToSuperview().offset(5)
            $0.right.equalToSuperview().offset(-5)
        }
    }
    
    override func prepareForReuse() {
        image.image = nil
    }
    
}
