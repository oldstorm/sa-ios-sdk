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
        

        let attrStr = NSAttributedString(string: "我们深知隐私对您的重要性，为了更全面地呈现我们收集和使用您个人信息的相关情况，我们根据最新法律法规的要求，对用户协议和隐私政策进行了详细的修订。当您点击【同意】即代表您已充分阅读、理解并接受更新过的《用户协议》和《隐私政策》的全部内容。请花一些时间熟悉我们的隐私政策，如果您有任何问题，请随时联系我们。".localizedString,
                                         attributes: [
                                            NSAttributedString.Key.font: UIFont.font(size: 14, type: .medium),
                                            NSAttributedString.Key.foregroundColor: UIColor.custom(.black_3f4663),
                                            NSAttributedString.Key.paragraphStyle: paragraph
                                         ])
        $0.attributedText = attrStr

       
    }
    
    private lazy var userAgreementLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.blue_2da3f6)
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.text = "用户协议".localizedString
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickUserAgreement)))
    }
    
    private lazy var privacyLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.blue_2da3f6)
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.text = "隐私政策".localizedString
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickPrivacy)))
    }
    
    private lazy var andLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_333333)
        $0.textAlignment = .left
        $0.text = "与".localizedString
    }

    
    private lazy var sureBtn = Button().then {
        $0.setTitle("同意".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_333333), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.sureCallback?()
            self?.removeFromSuperview()
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
        sureCallback?()
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
        container.addSubview(userAgreementLabel)
        container.addSubview(andLabel)
        container.addSubview(privacyLabel)
        container.addSubview(sureBtn)
        container.addSubview(cancelBtn)
        
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
        
        userAgreementLabel.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
        }
        
        andLabel.snp.makeConstraints {
            $0.centerY.equalTo(userAgreementLabel.snp.centerY)
            $0.left.equalTo(userAgreementLabel.snp.right)
        }

        privacyLabel.snp.makeConstraints {
            $0.centerY.equalTo(userAgreementLabel.snp.centerY)
            $0.left.equalTo(andLabel.snp.right)
        }

        
        sureBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.right.equalToSuperview()
            $0.top.equalTo(userAgreementLabel.snp.bottom).offset(30)
            $0.width.equalTo((Screen.screenWidth - 75) / 2)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.equalToSuperview()
            $0.top.equalTo(userAgreementLabel.snp.bottom).offset(30)
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




//
//struct PrviacyAlertView: View {
//    @State private var scale: CGFloat = 0.3
//    var body: some View {
//        ZStack {
//            Color(.black.withAlphaComponent(0.3))
//                .padding(.all, 0)
//
//            VStack(alignment: .center) {
//                Text("用户协议和隐私政策".localizedString)
//                    .font(.system(size: 16))
//                    .foregroundColor(.black)
//                    .padding()
//
//                Text("我们深知隐私对您的重要性，为了更全面地呈现我们收集和使用您个人信息的相关情况，我们根据最新法律法规的要求，对用户协议和隐私政策进行了详细的修订。当您点击【同意】即代表您已充分阅读、理解并接受更新过的《用户协议》和《隐私政策》的全部内容。请花一些时间熟悉我们的隐私政策，如果您有任何问题，请随时联系我们。".localizedString)
//                    .font(.system(size: 14))
//                    .foregroundColor(.gray)
//                    .padding()
//
//                HStack() {
//                    Text("用户协议".localizedString)
//                        .font(.system(size: 14))
//                        .foregroundColor(.blue)
//                        .padding(.horizontal, 0)
//
//                    Text("与".localizedString)
//                        .font(.system(size: 14))
//                        .foregroundColor(.black)
//                        .padding(.horizontal, 0)
//
//                    Text("隐私政策".localizedString)
//                        .font(.system(size: 14))
//                        .foregroundColor(.blue)
//                        .padding(.horizontal, 0)
//                }
//                .padding()
//            }
//            .background(Color.white)
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .padding()
//            .scaleEffect(x: scale, y: scale)
//            .onAppear {
//                withAnimation {
//                    scale = 1
//                }
//            }
//        }
//        .padding(.all, 0)
//
//
//    }
//}
