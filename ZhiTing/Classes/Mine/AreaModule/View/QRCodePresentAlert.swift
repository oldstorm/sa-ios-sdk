//
//  QRCodePresentAlert.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/31.
//

import Foundation
import UIKit
import swiftScan
import Photos

class QRCodePresentAlert: UIView {
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private lazy var contentView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "邀请码已生成，请邀请好友加入吧".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var icon = ImageView().then {
        $0.image = .assets(.default_avatar)
        $0.layer.cornerRadius = 30
        $0.clipsToBounds = true
    }
    
    private lazy var nickNameLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
        $0.text = "nickname"
    }
    
    private lazy var inviteTipsLabel = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textAlignment = .center
        $0.text = "邀请您加入".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var qrcodeImg = ImageView()
    
    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.text = "10分钟内有效，请扫码加入".localizedString
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var closeButton = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.isEnhanceClick = true
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    private lazy var saveButton = ImageTitleButton(frame: .zero, icon: nil, title: "保存至相册".localizedString, titleColor: .custom(.black_3f4663), backgroundColor: .custom(.white_ffffff)).then {
        $0.clickCallBack = { [weak self] in
            self?.saveToAlbum()
        }
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func show(qrcodeString: String, avatar: UIImage? = UIImage.assets(.default_avatar), nickname: String = "nickname", areaName: String = "") {
        let alert = QRCodePresentAlert(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        alert.icon.image = avatar
        alert.nickNameLabel.text = nickname
        alert.inviteTipsLabel.text = "邀请您加入".localizedString + areaName
        let codeStr = "{\"qr_code\": \"\(qrcodeString)\", \"url\": \"\(AuthManager.shared.currentArea.sa_lan_address ?? "")\", \"area_name\": \"\(areaName)\"}"

        alert.qrcodeImg.image = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator", codeString: codeStr, size: CGSize(width: 170, height: 170), qrColor: .black, bkColor: .white)

        SceneDelegate.shared.window?.addSubview(alert)
    }
    
}

extension QRCodePresentAlert {
    private func setupViews() {
        addSubview(cover)
        addSubview(containerView)
        addSubview(saveButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(line)
        containerView.addSubview(contentView)
        contentView.addSubview(icon)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(inviteTipsLabel)
        contentView.addSubview(qrcodeImg)
        contentView.addSubview(tipsLabel)
    }
    
    private func setupConstraints() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-30)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }

        saveButton.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }
        
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(9)
            $0.top.equalToSuperview().offset(22)
            $0.right.equalToSuperview().offset(-12)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)
            $0.left.equalToSuperview().offset(19)
            $0.right.lessThanOrEqualTo(closeButton.snp.left).offset(-5)
        }
        
        line.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32.5)
            $0.width.height.equalTo(60)
            $0.centerX.equalToSuperview()
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        inviteTipsLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        qrcodeImg.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(170)
            $0.top.equalTo(inviteTipsLabel.snp.bottom).offset(30)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(qrcodeImg.snp.bottom).offset(5.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-25)
        }

    }
}

extension QRCodePresentAlert {
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        saveButton.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.identity
            self.saveButton.transform = CGAffineTransform.identity
        })
        
        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
            self.saveButton.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
        
        
    }
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
}

extension QRCodePresentAlert {
    private func saveToAlbum() {
        UIGraphicsBeginImageContextWithOptions(contentView.bounds.size, false, UIScreen.main.scale)
        contentView.drawHierarchy(in: contentView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let img = image else { return }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: img)
        }, completionHandler: { [weak self](isSuccess, error) in
            
            DispatchQueue.main.async {
                if isSuccess {
                    self?.makeToast("保存成功".localizedString)
                } else {
                    self?.makeToast("保存失败".localizedString)
                }
            }
        })
    }
}
