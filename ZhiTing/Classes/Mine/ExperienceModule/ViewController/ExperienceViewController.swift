//
//  ExperienceViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/18.
//

import UIKit


class ExperienceViewController: BaseViewController {
    private lazy var scrollView = UIScrollView(frame: view.bounds)

    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var descriptionLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "为了方便您更好地了解我们的智能设备功能和服务，我们为您提供了一系列的体验设备，你可以在【我的】-【支持品牌】-【体验品牌】添加【体验设备】插件，添加后就可以通过扫描或手动添加体验设备了，快去了解和体验我们的智能设备吧。".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var titleLabel0 = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "1. 添加体验设备插件".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var titleLabel1 = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "2. 添加体验设备".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var titleLabel2 = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "3. 体验设备".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var guideImg1 = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.guide_experience1)
    }

    private lazy var guideImg2 = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.guide_experience2)
    }
    
    private lazy var guideImg3 = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.guide_experience3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "体验中心".localizedString
    }
    
    override func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(titleLabel0)
        containerView.addSubview(titleLabel1)
        containerView.addSubview(titleLabel2)
        containerView.addSubview(guideImg1)
        containerView.addSubview(guideImg2)
        containerView.addSubview(guideImg3)
        containerView.addSubview(descriptionLabel)
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        titleLabel0.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        guideImg1.snp.makeConstraints {
            $0.top.equalTo(titleLabel0.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(380)
        }

        titleLabel1.snp.makeConstraints {
            $0.top.equalTo(guideImg1.snp.bottom).offset(31.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }

        guideImg2.snp.makeConstraints {
            $0.top.equalTo(titleLabel1.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(380)
        }
        
        titleLabel2.snp.makeConstraints {
            $0.top.equalTo(guideImg2.snp.bottom).offset(31.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }

        guideImg3.snp.makeConstraints {
            $0.top.equalTo(titleLabel2.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(380)
            $0.bottom.equalToSuperview().offset(-120)
        }
        
    }
}
