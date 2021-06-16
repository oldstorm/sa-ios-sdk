//
//  EditSceneAddCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/12.
//

import UIKit

class EditSceneAddCell: UITableViewCell, ReusableView {
    var isEnabled = false {
        didSet {
            if isEnabled {
                plusImage.image = .assets(.plus_blue_circle)
                titleLabel.textColor = .custom(.blue_2da3f6)
                isUserInteractionEnabled = true
            } else {
                plusImage.image = .assets(.plus_gray)
                titleLabel.textColor = .custom(.gray_94a5be)
                isUserInteractionEnabled = false
            }
        }
    }

    private lazy var bgView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var plusImage = ImageView().then {
        $0.image = .assets(.plus_blue_circle)
    }
    
    lazy var titleLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .center
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .custom(.gray_f6f8fd)
        contentView.addSubview(bgView)
        bgView.addSubview(plusImage)
        bgView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        bgView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(20))
            $0.bottom.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        plusImage.snp.makeConstraints {
            $0.width.height.equalTo(ZTScaleValue(24))
            $0.top.equalToSuperview().offset(ZTScaleValue(50))
            $0.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(plusImage.snp.bottom).offset(ZTScaleValue(10))
            
        }

    }
    
}
