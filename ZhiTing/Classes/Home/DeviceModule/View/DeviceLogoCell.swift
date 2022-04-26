//
//  DeviceLogoCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/2/24.
//

import Foundation
import UIKit


class DeviceLogoCell: UICollectionViewCell, ReusableView {
    var deviceLogo: DeviceLogoModel? {
        didSet {
            guard let deviceLogo = deviceLogo else {
                return
            }

            logo.setImage(urlString: deviceLogo.url, placeHolder: .assets(.default_device))
            nameLabel.text = deviceLogo.name
        }
    }
    
    var isChoosed: Bool = false {
        didSet {
            bgView.layer.shadowOpacity = isChoosed ? 1 : 0
            selectedCornerImg.isHidden = !isChoosed
        }
    }


    private lazy var selectedCornerImg = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.corner_select_icon)
        $0.isHidden = true
    }

    private lazy var logo = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.default_device)
    }
    
    private lazy var nameLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 12, type: .medium)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        
    }
    
    private lazy var bgView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 4
        $0.layer.shadowRadius = 4
        $0.layer.shadowOffset = CGSize(width: 1, height: 1)
        $0.layer.shadowOpacity = 0
        $0.layer.shadowColor = UIColor.custom(.gray_cfd6e0).cgColor
        $0.layer.masksToBounds = false
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
        contentView.addSubview(bgView)
        bgView.addSubview(logo)
        bgView.addSubview(nameLabel)
        bgView.addSubview(selectedCornerImg)
    }
    
    private func setupConstraints() {
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        logo.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(10))
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(58))
        }
        
        nameLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        selectedCornerImg.snp.makeConstraints {
            $0.top.right.equalToSuperview()
            $0.height.width.equalTo(24)
        }
    }

}
