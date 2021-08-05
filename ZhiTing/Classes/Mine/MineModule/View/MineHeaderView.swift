//
//  MineHeaderView.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/23.
//

import UIKit

class MineHeaderView: UIView {
    var infoCallback: (() -> ())?

    lazy var avatar = ImageView().then {
        $0.layer.cornerRadius = 30
        $0.image = .assets(.default_avatar)
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(jumpInfo)))
        $0.isUserInteractionEnabled = true
    }

    lazy var nickNameLabel = Label().then {
        $0.text = "   "
        $0.font = .font(size: 20, type: .bold)
        $0.textAlignment = .left
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = .custom(.black_3f4663)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(jumpInfo)))
        $0.isUserInteractionEnabled = true
    }
    
    lazy var arrow = Button().then {
        $0.setImage(.assets(.arrow_right), for: .normal)
        $0.contentMode = .scaleAspectFit
        $0.isEnhanceClick = true
        $0.clickCallBack = { [weak self] _ in
            self?.jumpInfo()
        }
    }
    
    lazy var scanBtn = Button().then {
        $0.setImage(.assets(.icon_scan), for: .normal)
        $0.isEnhanceClick = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func jumpInfo() {
        infoCallback?()
    }
    
    private func setupViews() {
        backgroundColor = .custom(.white_ffffff)
        addSubview(avatar)
        addSubview(nickNameLabel)
        addSubview(arrow)
        addSubview(scanBtn)
    }
    
    private func setupConstraints() {
        avatar.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(15).priority(.high)
            $0.width.height.equalTo(60)
        }
        
        arrow.snp.makeConstraints {
            $0.centerY.equalTo(nickNameLabel.snp.centerY).offset(ZTScaleValue(2.5))
            $0.left.equalTo(nickNameLabel.snp.right).offset(15.5)
            $0.width.equalTo(7)
            $0.height.equalTo(12.5)
        }

        nickNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(10)
            $0.left.equalTo(avatar.snp.right).offset(13.5)
            $0.right.lessThanOrEqualToSuperview().offset(-40)
        }
        
        scanBtn.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.right.equalToSuperview().offset(-20)
            $0.width.height.equalTo(24)
            
        }
    }
}
