//
//  GuideTokenView.swift
//  ZhiTing
//
//  Created by iMac on 2021/7/13.
//

import UIKit

class GuideTokenViewController: BaseViewController {
    private lazy var scrollView = UIScrollView(frame: view.bounds)

    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var descriptionLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "“当前终端无凭证”是因为您更换了手机/平板登录或卸载了APP，为了您的家庭信息安全进行的凭证验证。家庭拥有者可通过以下路径进行设置找回用户凭证：".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var titleLabel0 = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "1. 登录专业版进入智慧中心详情".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var titleLabel1 = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "2. 选择权限管理-找回用户凭证".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var titleLabel2 = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "3. 更改选择，保存".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var guideImg1 = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.guide_token_1)
    }

    private lazy var guideImg2 = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.guide_token_2)
    }
    
    private lazy var guideImg3 = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.guide_token_3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "如何设置找回用户凭证".localizedString
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
            $0.height.equalTo(356)
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
            $0.height.equalTo(310)
        }
        
        titleLabel2.snp.makeConstraints {
            $0.top.equalTo(guideImg2.snp.bottom).offset(31.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }

        guideImg3.snp.makeConstraints {
            $0.top.equalTo(titleLabel2.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.width.equalTo(263)
            $0.height.equalTo(459)
            $0.bottom.equalToSuperview().offset(-120)
        }
        
    }
}
