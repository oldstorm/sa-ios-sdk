//
//  SAUpdateAlert.swift
//  ZhiTing
//
//  Created by iMac on 2022/2/24.
//

import Foundation
import UIKit

class SAUpdateAlert: UIView {
    var leftBtnCallback: (() -> ())?
    var rightBtnCallback: (() -> ())?

    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.3)
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_alert_warning)
    }
    
    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "提示".localizedString
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
    }

    private lazy var contentLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    lazy var leftBtn = Button().then {
        $0.setTitle("切换家庭".localizedString, for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.layer.cornerRadius = 20
        $0.clickCallBack = { [weak self] _ in
            self?.leftBtnCallback?()
            self?.removeFromSuperview()
        }
        
        
    }
    
    lazy var rightBtn = Button().then {
        $0.setTitle("进入专业版".localizedString, for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.layer.cornerRadius = 20
        $0.clickCallBack = { [weak self] _ in
            self?.rightBtnCallback?()
        }
        
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init(frame: CGRect, message: String, image: UIImage? = .assets(.icon_alert_warning)) {
        self.init(frame: frame)
        self.contentLabel.text = message
        self.icon.image = image
    }
    
    convenience init(frame: CGRect, attributedString: NSAttributedString) {
        self.init(frame: frame)
        self.contentLabel.attributedText = attributedString
    }
    
    deinit {
        print("SAUpdateAlert deinit")
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
                SAUpdateAlert.alert = nil
            }
            
        })
        
    }
    
    private func setupViews() {
        addSubview(cover)
        addSubview(container)
        container.addSubview(icon)
        container.addSubview(tipsLabel)
        container.addSubview(contentLabel)
        container.addSubview(leftBtn)
        container.addSubview(rightBtn)

        
    }

    private func setConstrains() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 75)
        }
        
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(53)
        }

        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        leftBtn.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.left.equalToSuperview().offset(15)
            $0.top.equalTo(contentLabel.snp.bottom).offset(30)
            $0.width.equalTo((Screen.screenWidth - 140) / 2)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        rightBtn.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.right.equalToSuperview().offset(-15)
            $0.top.equalTo(contentLabel.snp.bottom).offset(30)
            $0.width.equalTo((Screen.screenWidth - 140) / 2)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
    
    static fileprivate var alert: SAUpdateAlert?
    
    static func show(message: String, leftBtnTitle: String = "切换家庭", rightBtnTitle: String = "进入专业版", iconImage: UIImage? = .assets(.icon_warning), leftBtnCallback: (() -> ())? = nil, rightBtnCallback: (() -> ())? = nil) {
        alert?.removeFromSuperview()
        alert = SAUpdateAlert(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight), message: message)
        alert?.leftBtnCallback = leftBtnCallback
        alert?.leftBtn.setTitle(leftBtnTitle, for: .normal)
        alert?.rightBtnCallback = rightBtnCallback
        alert?.rightBtn.setTitle(rightBtnTitle, for: .normal)
        alert?.icon.image = iconImage
        UIApplication.shared.windows.first?.addSubview(alert!)
    }
}



