//
//  AppUpdateAlertView.swift
//  ZhiTing
//
//  Created by zy on 2022/2/24.
//

import UIKit

class AppUpdateAlertView: UIView {
    var sureCallback: (() -> ())?
    var cancelCallback: (() -> ())?

    var appVersionModel = AppVersionResponse()
    
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.3)
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private lazy var bgImgView = ImageView().then {
        $0.image = .assets(.updateApp_img)
        $0.contentMode = .scaleAspectFit
    }

    private lazy var titleLabel = Label().then {
        $0.text = "版本更新".localizedString
        $0.font = .font(size: 20, type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    private lazy var versionLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textAlignment = .left
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private lazy var updateDetailView = UITextView().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textAlignment = .left
        $0.textColor = .custom(.black_3f4663)
//        $0.numberOfLines = 0
//        $0.lineBreakMode = .byWordWrapping
        $0.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        $0.delegate = self
    }

    private lazy var updateDetailLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textAlignment = .left
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.isHidden = true
    }

    
    
    private lazy var updateBtn = Button().then {
        $0.setTitle("立即更新".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor

        $0.clickCallBack = { [weak self] _ in
            self?.sureCallback?()
        }
    }
    private lazy var cancelBtn = Button().then {
        $0.setTitle("取消".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_333333), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init(frame: CGRect, model: AppVersionResponse) {
        self.init(frame: frame)
        self.appVersionModel = model
        titleLabel.text = "版本更新".localizedString
        versionLabel.text = "可更新版本".localizedString + ":\(model.max_app_version)"
        updateDetailLabel.text = model.remark
        updateDetailView.text = model.remark
        checkoutTextViewHeight()
        //如果当前版本低于最低版本，则无法取消
        //获取当前app版本信息
        let infoDic = Bundle.main.infoDictionary
        let appVersion = infoDic?["CFBundleShortVersionString"] as? String ?? "1.0.0"

        
        //是否需要强制更新
        
        cancelBtn.setTitle("取消".localizedString, for: .normal)
        cancelBtn.clickCallBack = { [weak self] _ in
            self?.cancelCallback?()
            self?.removeFromSuperview()
        }
        
        if model.is_force_update {
            if ZTVersionTool.compareVersionIsNewBigger(nowVersion: appVersion, newVersion: model.min_app_version == "" ? "1.0.0" : model.min_app_version) {
                cancelBtn.setTitle("不更新并退出".localizedString, for: .normal)
                cancelBtn.clickCallBack = { _ in
                    //退出app
                    exit(0)
                }
            }
        }

    }
    
    convenience init(frame: CGRect, attributedString: NSAttributedString) {
        self.init(frame: frame)
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
        container.addSubview(bgImgView)
        container.addSubview(titleLabel)
        container.addSubview(versionLabel)
        container.addSubview(updateDetailView)
        container.addSubview(updateDetailLabel)
        container.addSubview(updateBtn)
        container.addSubview(cancelBtn)
        
    }

    private func setConstrains() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-ZTScaleValue(50))
            $0.width.equalTo(Screen.screenWidth - 75)
        }
        
        bgImgView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(18))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(136))
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(bgImgView.snp.bottom).offset(ZTScaleValue(27.5))
            $0.centerX.equalToSuperview()
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(-ZTScaleValue(15))
        }
        
        versionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(12))
            $0.centerX.equalToSuperview()
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(-ZTScaleValue(15))
        }
        
        updateDetailLabel.snp.makeConstraints {
            $0.top.equalTo(versionLabel.snp.bottom).offset(ZTScaleValue(12))
            $0.centerX.equalToSuperview()
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(-ZTScaleValue(15))
        }
        
        updateDetailView.snp.makeConstraints {
            $0.top.equalTo(versionLabel.snp.bottom).offset(ZTScaleValue(12))
            $0.centerX.equalToSuperview()
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(-ZTScaleValue(15))
            $0.height.equalTo(ZTScaleValue(20))
        }
        
        updateBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.right.equalToSuperview()
            $0.top.equalTo(updateDetailView.snp.bottom).offset(30)
            $0.width.equalTo((Screen.screenWidth - 75) / 2)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.equalToSuperview()
            $0.top.equalTo(updateDetailView.snp.bottom).offset(30)
            $0.width.equalTo((Screen.screenWidth - 75) / 2)
            $0.bottom.equalToSuperview()

        }

    }
    
    @discardableResult
    static func show(checkAppModel: AppVersionResponse, sureCallback: (() -> ())?, cancelCallback: (() -> ())? = nil) -> AppUpdateAlertView {
        let updateView = AppUpdateAlertView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight), model: checkAppModel)
        updateView.sureCallback = sureCallback
        updateView.cancelCallback = cancelCallback
        UIApplication.shared.windows.first?.addSubview(updateView)
        return updateView
    }
    
}

extension AppUpdateAlertView: UITextViewDelegate {
    
    private func checkoutTextViewHeight() {
        let maxHeight = ZTScaleValue(200)
//        let constraintSize = CGSize(width: Screen.screenWidth - ZTScaleValue(30), height: CGFloat(MAXFLOAT))
//        var size = updateDetailView.sizeThatFits(constraintSize)// \n\r
        layoutIfNeeded()
        var labelHeight = updateDetailLabel.frame.height
        
            if labelHeight >= maxHeight {
                labelHeight = maxHeight
                updateDetailView.isScrollEnabled = true
            }else{
                updateDetailView.isScrollEnabled = false
            }
        updateDetailView.snp.remakeConstraints {
            $0.top.equalTo(versionLabel.snp.bottom).offset(ZTScaleValue(12))
            $0.centerX.equalToSuperview()
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(-ZTScaleValue(15))
            $0.height.equalTo(labelHeight)
        }

    }
    
    func textViewDidChange(_ textView: UITextView) {
    }
}
