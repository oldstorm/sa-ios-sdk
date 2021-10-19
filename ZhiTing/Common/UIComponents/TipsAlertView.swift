//
//  TipsAlertView.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/26.
//

import UIKit

class TipsAlertView: UIView {
    var sureCallback: (() -> ())?
    var cancelCallback: (() -> ())?

    var removeWithSure = true
    
    var isSureBtnLoading = false {
        didSet {
            sureBtn.selectedChangeView(isLoading: isSureBtnLoading)
        }
    }
    
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.3)
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }

    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private lazy var sureBtn = CustomButton(buttonType:
                                                .centerTitleAndLoading(normalModel:
                                                                        .init(
                                                                            title: "确定".localizedString,
                                                                            titleColor: .custom(.blue_2da3f6),
                                                                            font: .font(size: 14, type: .bold),
                                                                            bagroundColor: .custom(.white_ffffff)
                                                                        )
                                                )).then {
                                                    $0.layer.borderWidth = 0.5
                                                    $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
                                                    $0.addTarget(self, action: #selector(onClickSure), for: .touchUpInside)
                                                }
    
    private lazy var cancelBtn = Button().then {
        $0.setTitle("取消".localizedString, for: .normal)
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
        if removeWithSure {
            removeFromSuperview()
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init(frame: CGRect, message: String) {
        self.init(frame: frame)
        self.tipsLabel.text = message
    }
    
    convenience init(frame: CGRect, attributedString: NSAttributedString) {
        self.init(frame: frame)
        self.tipsLabel.attributedText = attributedString
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
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
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
    static func show(message: String, sureTitle: String = "确定".localizedString, sureCallback: (() -> ())?, cancelCallback: (() -> ())? = nil, removeWithSure: Bool = true) -> TipsAlertView {
        let tipsView = TipsAlertView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight), message: message)
        tipsView.sureBtn.title.text = sureTitle.localizedString
        tipsView.sureBtn.nomalStruct = .init(
            title: sureTitle.localizedString,
            titleColor: .custom(.blue_2da3f6),
            font: .font(size: 14, type: .bold),
            bagroundColor: .custom(.white_ffffff)
        )
        tipsView.removeWithSure = removeWithSure
        tipsView.sureCallback = sureCallback
        tipsView.cancelCallback = cancelCallback
        UIApplication.shared.windows.first?.addSubview(tipsView)
        return tipsView
    }
    
    @discardableResult
    static func show(attributedString: NSAttributedString, sureCallback: (() -> ())?, cancelCallback: (() -> ())? = nil, removeWithSure: Bool = true) -> TipsAlertView {
        let tipsView = TipsAlertView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight), attributedString: attributedString)
        tipsView.removeWithSure = removeWithSure
        tipsView.sureCallback = sureCallback
        tipsView.cancelCallback = cancelCallback
        UIApplication.shared.windows.first?.addSubview(tipsView)
        return tipsView
    }
    

}


