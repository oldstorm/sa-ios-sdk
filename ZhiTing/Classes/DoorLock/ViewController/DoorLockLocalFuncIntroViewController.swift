//
//  DoorLockLocalFuncIntroViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/11.
//

import Foundation
import UIKit

class DoorLockLocalFuncIntroViewController: BaseViewController {
    let funcType: FuncType
    
    init(funcType: FuncType) {
        self.funcType = funcType
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var image = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = funcType.image
    }
    
    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 18, type: .bold)
        $0.textColor = .custom(.blue_2da3f6)
        $0.textAlignment = .center
        $0.text = "此功能为门锁本地端开启".localizedString
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }
    
    private lazy var funcTitle = Label().then {
        $0.text = "功能介绍".localizedString
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 18, type: .bold)
    }

    private lazy var detailLabel = Label().then {
        $0.text = funcType.detail
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 14, type: .regular)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = funcType.title
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(image)
        view.addSubview(tipsLabel)
        view.addSubview(line)
        view.addSubview(funcTitle)
        view.addSubview(detailLabel)
    }
    
    override func setupConstraints() {
        image.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(150)
            $0.top.equalToSuperview().offset(Screen.k_nav_height + 30)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(image.snp.bottom).offset(20)
        }
        
        line.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(10)
            $0.top.equalTo(tipsLabel.snp.bottom).offset(20)
        }
        
        funcTitle.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(funcTitle.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }
    }
}

extension DoorLockLocalFuncIntroViewController {
    enum FuncType {
        case locked
        case catEyeProtection
        
        var title: String {
            switch self {
            case .locked:
                return "反锁".localizedString
            case .catEyeProtection:
                return "防猫眼".localizedString
            }
        }
        
        var image: UIImage? {
            switch self {
            case .locked:
                return .assets(.guide_locked)
            case .catEyeProtection:
                return .assets(.guide_cateye)
            }
        }
        
        var detail: String {
            switch self {
            case .locked:
                return "启用后，仅管理员指纹、管理员密码、管理员NFC、手机蓝牙和机械钥匙可开锁。门内可正常开锁。开门一次后反锁失效。".localizedString
            case .catEyeProtection:
                return "开启后，可防止他人使用非法工具通过猫眼孔开锁。门内无法通过握把开锁，门外开锁功能正常。".localizedString
            }
        }
    }
}
