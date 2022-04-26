//
//  PrivacyAlert.swift
//  ZhiTing
//
//  Created by iMac on 2021/10/29.
//


import UIKit
//import SwiftUI


class PrivacyAlert: UIView {
    typealias privacyAlertCallback = (() -> ())

    var sureCallback: privacyAlertCallback?
    var cancelCallback: privacyAlertCallback?
    var privacyCallback: privacyAlertCallback?
    var userAgreementCallback: privacyAlertCallback?
    
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.3)
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }

    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.text = "用户协议与隐私政策".localizedString
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }

    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textAlignment = .left
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        var paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        

        let attrStr = NSAttributedString(string: "我们深知隐私对您的重要性，为了更全面地呈现我们收集和使用您个人信息的相关情况，我们根据最新法律法规的要求，对用户协议和隐私政策进行了详细的修订。当您勾选同意即代表您已充分阅读、理解并接受更新过的《用户协议》和《隐私政策》的全部内容。请花一些时间熟悉我们的隐私政策，如果您有任何问题，请随时联系我们。".localizedString,
                                         attributes: [
                                            NSAttributedString.Key.font: UIFont.font(size: 14, type: .medium),
                                            NSAttributedString.Key.foregroundColor: UIColor.custom(.black_3f4663),
                                            NSAttributedString.Key.paragraphStyle: paragraph
                                         ])
        $0.attributedText = attrStr

       
    }
    
    
    private lazy var agreeLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_333333)
        $0.textAlignment = .left
        $0.text = "我已阅读并同意".localizedString
        $0.numberOfLines = 0
        $0.attributed.text = "我已阅读并同意\("用户协议", .font(.systemFont(ofSize: ZTScaleValue(14))), .foreground(.custom(.blue_2da3f6)), .action(onClickUserAgreement), .underline(.single, color: nil))与\("隐私政策", .font(.systemFont(ofSize: ZTScaleValue(14))), .foreground(.custom(.blue_2da3f6)), .action(onClickPrivacy), .underline(.single, color: nil))"
        
        if getCurrentLanguage() == .english {
            $0.attributed.text = "I have read and agree \("用户协议".localizedString, .font(.systemFont(ofSize: ZTScaleValue(14))), .foreground(.custom(.blue_2da3f6)), .action(onClickUserAgreement), .underline(.single, color: nil)) & \("隐私政策".localizedString, .font(.systemFont(ofSize: ZTScaleValue(14))), .foreground(.custom(.blue_2da3f6)), .action(onClickPrivacy), .underline(.single, color: nil))"
        }

    }

    private lazy var selectBtn = Button().then {
        $0.setImage(.assets(.unselected_tick_square), for: .normal)
        $0.setImage(.assets(.selected_tick_square), for: .selected)
        $0.isEnhanceClick = true
    }
    
    private lazy var sureBtn = Button().then {
        $0.setTitle("同意并继续".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.onClickSure()
        }

        
    }
    
    private lazy var cancelBtn = Button().then {
        $0.setTitle("不同意".localizedString, for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.cancelCallback?()
            self?.removeFromSuperview()
        }

        
    }

    @objc private func onClickUserAgreement() {
        userAgreementCallback?()
    }
    
    @objc private func onClickPrivacy() {
        privacyCallback?()
    }

    @objc private func onClickSure() {
        if !selectBtn.isSelected {
            SceneDelegate.shared.window?.makeToast("请勾选同意《用户协议》与《隐私政策》".localizedString)
            return
        }
        sureCallback?()
        removeFromSuperview()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init(sure: privacyAlertCallback?, cancel: privacyAlertCallback?, privacy: privacyAlertCallback?, userAgreement: privacyAlertCallback?) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        self.sureCallback = sure
        self.cancelCallback = cancel
        self.privacyCallback = privacy
        self.userAgreementCallback = userAgreement
    }
    
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        container.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform.identity
        })
            
        
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        },completion: { isFinished in
            if isFinished {
                super.removeFromSuperview()
            }
            
        })
        
    }
    
    private func setupViews() {
        addSubview(cover)
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(tipsLabel)
        container.addSubview(selectBtn)
        container.addSubview(agreeLabel)
        container.addSubview(sureBtn)
        container.addSubview(cancelBtn)
        
        selectBtn.clickCallBack = {
            $0.isSelected = !$0.isSelected
        }
    }

    private func setConstrains() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 75)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }

        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(22)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }
        
        selectBtn.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(ZTScaleValue(14))
        }
        
        agreeLabel.snp.makeConstraints {
            $0.top.equalTo(selectBtn).offset(-ZTScaleValue(3))
            $0.left.equalTo(selectBtn.snp.right).offset(ZTScaleValue(5))
            $0.right.equalTo(-ZTScaleValue(20))
        }
        
        sureBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.right.equalToSuperview()
            $0.top.equalTo(agreeLabel.snp.bottom).offset(30)
            $0.width.equalTo((Screen.screenWidth - 75) / 2)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.equalToSuperview()
            $0.top.equalTo(agreeLabel.snp.bottom).offset(30)
            $0.width.equalTo((Screen.screenWidth - 75) / 2)
            $0.bottom.equalToSuperview()
        }
    }
    
    
    @discardableResult
    static func show(sure: privacyAlertCallback?, cancel: privacyAlertCallback?, privacy: privacyAlertCallback?, userAgreement: privacyAlertCallback?) -> PrivacyAlert {
        let alert = PrivacyAlert(sure: sure, cancel: cancel, privacy: privacy, userAgreement: privacy)
        UIApplication.shared.windows.first?.addSubview(alert)
        return alert
    }
    

}

