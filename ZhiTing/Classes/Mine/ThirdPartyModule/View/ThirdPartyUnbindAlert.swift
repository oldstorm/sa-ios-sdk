//
//  ThirdPartyUnbindAlert.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/10.
//

import Foundation
import UIKit


class ThirdPartyUnbindAlert: UIView {
    var unbindBtnCallback: (() -> ())?
    
    var isLoading = false {
        didSet {
            closeBtn.isHidden = isLoading
            cancelBtn.isEnabled = !isLoading
            unbindBtn.selectedChangeView(isLoading: isLoading)

        }
    }


    private lazy var cover = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    lazy var tipsLabel = Label().then {
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
        $0.font = .font(size: 14, type: .regular)
    }
    
    
    lazy var unbindBtn = CustomButton(buttonType:
                                                    .leftLoadingRightTitle(
                                                        normalModel:
                                                            .init(
                                                                title: "解除授权".localizedString,
                                                                titleColor: UIColor.custom(.blue_2da3f6),
                                                                font: UIFont.font(size: 14, type: .bold),
                                                                backgroundColor: UIColor.custom(.white_ffffff)
                                                            ),
                                                        lodingModel:
                                                            .init(
                                                                title: "解除授权中...".localizedString,
                                                                titleColor: UIColor.custom(.blue_2da3f6),
                                                                font: UIFont.font(size: 14, type: .bold),
                                                                backgroundColor: UIColor.custom(.white_ffffff)
                                                            )
                                                    )
    ).then {
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.addTarget(self, action: #selector(onClick), for: .touchUpInside)
    }

    private lazy var cancelBtn = Button().then {
        $0.setTitle("取消".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.titleLabel?.font = .font(size: 14, type: .medium)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
    }
    
    private lazy var closeBtn = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.isEnhanceClick = true
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    }
    
    
    private func setupViews() {
        addSubview(cover)
        addSubview(containerView)
        containerView.addSubview(tipsLabel)
        containerView.addSubview(unbindBtn)
        containerView.addSubview(cancelBtn)
        containerView.addSubview(closeBtn)
        
        cancelBtn.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private func setupConstraints() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.bottom.equalToSuperview().offset(10)
            $0.left.right.equalToSuperview()
        }

        tipsLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(18)
            $0.right.equalToSuperview().offset(-48)
        }
        
        closeBtn.snp.makeConstraints {
            $0.centerY.equalTo(tipsLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.height.width.equalTo(15)
        }

        unbindBtn.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(15)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(55)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.top.equalTo(unbindBtn.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(55)
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
        }

    }
    
    @objc
    private func onClick() {
        unbindBtnCallback?()
    }

    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.transform = CGAffineTransform(translationX: 0, y: Screen.screenHeight / 3)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })


    }

    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: Screen.screenHeight / 3)
        },completion: { isFinished in
            if isFinished {
                super.removeFromSuperview()
            }

        })

    }

    
}
