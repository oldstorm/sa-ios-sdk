//
//  UploadPluginAlertView.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/18.
//


import UIKit

class UploadPluginAlertView: UIView {
    enum Status {
        case normal
        case success
        case failure
        case uploading
    }
    
    var sureCallback: (() -> ())?
    var uploadCallback: (() -> ())?
    
    var status: Status? {
        didSet {
            guard let status = status else { return }
            uploadButton.isHidden = true
            tipsLabel.isHidden = true
            sureBtn.isEnabled = true
            successIcon.isHidden = true
            successLabel.isHidden = true
            sureBtn.isEnabled = false
            
            switch status {
            case .normal:
                uploadButton.isHidden = false
                tipsLabel.isHidden = false
                tipsLabel.text = "如系统没有该插件，可手动上传".localizedString
            case .failure:
                uploadButton.isHidden = false
                tipsLabel.isHidden = false
                tipsLabel.text = "上传失败,请上传正确的插件包".localizedString
            case .success:
                sureBtn.isEnabled = true
                successIcon.isHidden = false
                successLabel.isHidden = false
            case .uploading:
                sureBtn.isEnabled = false
            }
        }
    }

    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private lazy var uploadButton = Button().then {
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.white_ffffff).cgColor
        $0.setTitle("点击上传插件".localizedString, for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: 16, type: .bold)
        $0.clickCallBack = { [weak self] _ in
            self?.uploadCallback?()
        }
    }
    
    private lazy var bgView = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.upload_bg)
    }

    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textAlignment = .center
        $0.textColor = .custom(.white_ffffff)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.text = "如系统没有该插件，可手动上传".localizedString
    }
    
    
    private lazy var successIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.tick_green)
        $0.isHidden = true
    }
    
    private lazy var successLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.white_ffffff)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.text = "成功上传插件".localizedString
        $0.isHidden = true
    }
    
    private lazy var sureBtn = Button().then {
        $0.setTitle("确定".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.titleLabel?.font = .font(size: 16, type: .bold)
        $0.backgroundColor = .custom(.gray_f1f4fd)
        $0.layer.cornerRadius = 10
        
        $0.clickCallBack = { [weak self] _ in
            self?.sureCallback?()
            
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
        container.transform = CGAffineTransform(translationX: 0, y: 300)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform.identity
        })
            
        
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform(translationX: 0, y: 300)
        },completion: { isFinished in
            if isFinished {
                super.removeFromSuperview()
            }
            
        })
        
    }
    
    private func setupViews() {
        addSubview(cover)
        addSubview(container)
        bgView.addSubview(successIcon)
        bgView.addSubview(successLabel)
        container.addSubview(bgView)
        container.addSubview(uploadButton)
        container.addSubview(tipsLabel)
        container.addSubview(sureBtn)
        
        
    }

    private func setConstrains() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Screen.bottomSafeAreaHeight - 10)
            $0.width.equalTo(Screen.screenWidth - 30)
        }
        
        bgView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(285)
            $0.height.equalTo(100)
        }
        
        successLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }
        
        successIcon.snp.makeConstraints {
            $0.centerY.equalTo(successLabel.snp.centerY)
            $0.height.width.equalTo(24)
            $0.right.equalTo(successLabel.snp.left).offset(-8)
        }

        uploadButton.snp.makeConstraints {
            $0.top.equalTo(bgView.snp.top).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(32)
            $0.width.equalTo(160)
        }

        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(uploadButton.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        sureBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bgView.snp.bottom).offset(20)
            $0.width.equalTo(285)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
    }
    
    @objc private func close () {
        removeFromSuperview()
    }
    
    
    @discardableResult
    static func show(uploadCallback: @escaping (() -> ()), sureCallback: (() -> ())?) -> UploadPluginAlertView {
        let alert = UploadPluginAlertView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        alert.uploadCallback = uploadCallback
        alert.sureCallback = sureCallback
        alert.sureBtn.isEnabled = false
        SceneDelegate.shared.window?.addSubview(alert)
        return alert
    }

}


