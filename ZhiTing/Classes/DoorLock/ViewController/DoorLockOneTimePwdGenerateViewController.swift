//
//  DoorLockOneTimePwdGenerateViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/12.
//

import Foundation
import UIKit

class DoorLockOneTimePwdGenerateViewController: BaseViewController {
    enum Status {
        case generating
        case generated
    }
    
    var status = Status.generating {
        didSet {
            switch status {
            case .generating:
                titleLabel.text = "生成一次性密码".localizedString
                doneButton.isHidden = true
                generateButton.isHidden = false
                pwdLabel.isHidden = true
                pwdBg.isHidden = true
                pwdInputView.isHidden = false
                copyBtn.isHidden = true
            case .generated:
                titleLabel.text = "已生成一次性密码".localizedString
                doneButton.isHidden = false
                generateButton.isHidden = true
                pwdLabel.isHidden = false
                pwdBg.isHidden = false
                pwdInputView.isHidden = true
                copyBtn.isHidden = false
            }
        }
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }

    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "生成一次性密码".localizedString
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var detailLabel = Label().then {
        $0.text = "密码永久失效，在有效期内仅可使用一次，使用后失效。".localizedString
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
    }
    
    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.text = "一次性密码".localizedString
    }
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.black_3f4663)
    }
    
    private lazy var pwdLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
        $0.font = .font(size: 30, type: .D_Medium)
        $0.text = "456210"
    }
    
    private lazy var pwdBg = ImageView().then {
        $0.image = .assets(.pwd_bg)
        $0.contentMode = .scaleAspectFill
    }
    
    private lazy var pwdInputView = DoorLockOneTimePwdInputView()
    
    private lazy var copyBtn = Button().then {
        $0.setTitle("复制密码".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .regular)
        $0.clickCallBack = { [weak self] _ in
            UIPasteboard.general.string = self?.pwdLabel.text
            self?.showToast(string: "复制成功")
        }
    }
    
    /// 生成一次性密码按钮
    lazy var generateButton = CustomButton(buttonType:
                                                    .leftLoadingRightTitle(
                                                        normalModel:
                                                            .init(
                                                                title: "生成".localizedString,
                                                                titleColor: UIColor.custom(.white_ffffff),
                                                                font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                                backgroundColor: UIColor.custom(.blue_2da3f6)
                                                            ),
                                                        lodingModel:
                                                            .init(
                                                                title: "生成中...".localizedString,
                                                                titleColor: UIColor.custom(.gray_94a5be),
                                                                font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                                backgroundColor: UIColor.custom(.blue_2da3f6)
                                                            )
                                                    )
    ).then {
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.addTarget(self, action: #selector(onClickGenerate), for: .touchUpInside)
    }
    
    /// 完成按钮
    lazy var doneButton = CustomButton(buttonType:
                                                    .leftLoadingRightTitle(
                                                        normalModel:
                                                            .init(
                                                                title: "完成".localizedString,
                                                                titleColor: UIColor.custom(.white_ffffff),
                                                                font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                                backgroundColor: UIColor.custom(.blue_2da3f6)
                                                            ),
                                                        lodingModel:
                                                            .init(
                                                                title: "完成".localizedString,
                                                                titleColor: UIColor.custom(.gray_94a5be),
                                                                font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                                backgroundColor: UIColor.custom(.blue_2da3f6)
                                                            )
                                                    )
    ).then {
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.addTarget(self, action: #selector(onClickDone), for: .touchUpInside)
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(detailLabel)
        container.addSubview(tipsLabel)
        container.addSubview(line)
        container.addSubview(pwdBg)
        container.addSubview(pwdLabel)
        container.addSubview(pwdInputView)
        container.addSubview(copyBtn)
        container.addSubview(doneButton)
        container.addSubview(generateButton)
        
        
    }
    
    override func setupConstraints() {
        container.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.left.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(15)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(38)
            $0.right.equalToSuperview().offset(-38)
            $0.height.equalTo(0.5)
        }
        
        pwdBg.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(30)
            $0.left.equalTo(line.snp.left)
            $0.right.equalTo(line.snp.right)
            $0.height.equalTo(58)
        }
        
        pwdLabel.snp.makeConstraints {
            $0.center.equalTo(pwdBg)
        }
        
        pwdInputView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(line.snp.bottom).offset(25)
            $0.height.equalTo(70)
        }
        
        copyBtn.snp.makeConstraints {
            $0.top.equalTo(pwdBg.snp.bottom).offset(12)
            $0.right.equalTo(pwdBg.snp.right)
            $0.height.equalTo(15)
            $0.width.equalTo(60)
        }
        
        doneButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(37.5)
            $0.right.equalToSuperview().offset(-37.5)
            $0.height.equalTo(50)
            $0.top.equalTo(copyBtn.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        generateButton.snp.makeConstraints {
            $0.edges.equalTo(doneButton)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        status = .generating
        pwdInputView.startEditing()
    }
    
}



extension DoorLockOneTimePwdGenerateViewController {
    @objc private func onClickDone() {
        
    }
    
    @objc private func onClickGenerate() {
        
    }
    
}
