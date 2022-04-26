//
//  PrivacyTipsView.swift
//  ZhiTing
//
//  Created by zy on 2022/3/10.
//

import UIKit
import AttributedString

class PrivacyTipsView: UIView {
    typealias privacyTipsCallback = (() -> ())

    var sureCallback: privacyTipsCallback?
    var cancelCallback: privacyTipsCallback?
    
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
        $0.text = "提示".localizedString
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
        
        var attrStr = ASAttributedString("")

        let detailStr: ASAttributedString = .init(
            string: "您需要同意本隐私政策才能继续使用智汀家庭云\n".localizedString,
            with: [
                .font(.font(size: 14, type: .bold)),
                .foreground(.custom(.black_3f4663)),
                .paragraph(.alignment(.left), .lineSpacing(5))
            ])
        
        let detailStr2: ASAttributedString = .init(
            string: "若您不同意本隐私政策，很遗憾我们将无法为您提供服务。".localizedString,
            with: [
                .font(.font(size: 14, type: .bold)),
                .foreground(.custom(.gray_94a5be)),
                .paragraph(.alignment(.left), .lineSpacing(5))
            ])

        attrStr += detailStr
        attrStr += detailStr2
        $0.attributed.text = attrStr
        
    }
        
    private lazy var sureBtn = Button().then {
        $0.setTitle("查看协议".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.onClickSure()
        }

        
    }
    
    private lazy var cancelBtn = Button().then {
        $0.setTitle("仍不同意".localizedString, for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.cancelCallback?()
            self?.removeFromSuperview()
        }

        
    }

    @objc private func onClickSure() {
        sureCallback?()
        removeFromSuperview()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init(sure: privacyTipsCallback?, cancel: privacyTipsCallback?) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        self.sureCallback = sure
        self.cancelCallback = cancel

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
                
        sureBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.right.equalToSuperview()
            $0.top.equalTo(tipsLabel.snp.bottom).offset(30)
            $0.width.equalTo((Screen.screenWidth - 75) / 2)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.equalToSuperview()
            $0.top.equalTo(tipsLabel.snp.bottom).offset(30)
            $0.width.equalTo((Screen.screenWidth - 75) / 2)
            $0.bottom.equalToSuperview()
        }
    }
    
    
    @discardableResult
    static func show(sure: privacyTipsCallback?, cancel: privacyTipsCallback?) -> PrivacyTipsView {
        let alert = PrivacyTipsView(sure: sure, cancel: cancel)
        UIApplication.shared.windows.first?.addSubview(alert)
        return alert
    }
    

}

