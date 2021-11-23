//
//  PrivacyBottomView.swift
//  ZhiTing
//
//  Created by iMac on 2021/10/29.
//

import Foundation
import UIKit

class PrivacyBottomView: UIView {
    typealias privacyAlertCallback = (() -> ())
    

    var privacyCallback: privacyAlertCallback?
    var userAgreementCallback: privacyAlertCallback?
    
    lazy var selectButton = Button().then {
        $0.imageView?.contentMode = .scaleAspectFit
        $0.setImage(.assets(.unselected_tick), for: .normal)
        $0.setImage(.assets(.selected_tick), for: .selected)
        $0.isEnhanceClick = true
    }

    private lazy var userAgreementLabel = Label().then {
        $0.font = .font(size: 11, type: .medium)
        $0.textColor = .custom(.blue_2da3f6)
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.text = "用户协议、".localizedString
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickUserAgreement)))
    }

    private lazy var privacyLabel = Label().then {
        $0.font = .font(size: 11, type: .medium)
        $0.textColor = .custom(.blue_2da3f6)
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.text = "隐私政策".localizedString
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickPrivacy)))
    }
    
    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 11, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
        $0.textAlignment = .left
        $0.text = "阅读并同意智汀家庭云".localizedString
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickTips)))
    }

    @objc private func onClickTips() {
        self.selectButton.isSelected = !self.selectButton.isSelected
    }

    @objc private func onClickUserAgreement() {
        userAgreementCallback?()
    }
    
    @objc private func onClickPrivacy() {
        privacyCallback?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func setupViews() {
        addSubview(tipsLabel)
        addSubview(userAgreementLabel)
        addSubview(privacyLabel)
        addSubview(selectButton)
        
        selectButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.selectButton.isSelected = !self.selectButton.isSelected
        }
    }
    

    func setupConstraints() {
        selectButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.height.width.equalTo(18)
            $0.centerY.equalTo(tipsLabel.snp.centerY)
        }

        tipsLabel.snp.makeConstraints {
            $0.left.equalTo(selectButton.snp.right).offset(5)
            $0.top.bottom.equalToSuperview()
        }
        
        userAgreementLabel.snp.makeConstraints {
            $0.centerY.equalTo(tipsLabel.snp.centerY)
            $0.left.equalTo(tipsLabel.snp.right)
        }
        
        privacyLabel.snp.makeConstraints {
            $0.centerY.equalTo(tipsLabel.snp.centerY)
            $0.left.equalTo(userAgreementLabel.snp.right)
            $0.right.equalToSuperview()
        }

    }

}
