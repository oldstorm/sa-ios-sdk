//
//  AboutUsViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/6/15.
//

import UIKit

class AboutUsViewController: BaseViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "关于".localizedString
    }
    
    override func loadView() {
        super.loadView()
        view = AboutUsView()
    }

}


extension AboutUsViewController {
    private class AboutUsView: UIView {
        private lazy var logo = ImageView().then {
            $0.image = .assets(.app_logo)
            $0.contentMode = .scaleAspectFit
        }
        
        private lazy var nameLabel = Label().then {
            $0.font = .font(size: ZTScaleValue(20), type: .bold)
            $0.text = "智汀家庭云".localizedString
            $0.textAlignment = .center
            $0.textColor = .custom(.black_3f4663)
        }
        
        private lazy var versionLabel = Label().then {
            $0.font = .font(size: ZTScaleValue(14), type: .bold)
            $0.textColor = .custom(.gray_94a5be)
            $0.text = "版本号:".localizedString
            $0.textAlignment = .center
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .custom(.white_ffffff)
            addSubview(logo)
            addSubview(nameLabel)
            addSubview(versionLabel)
            setupConstraints()
            
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                versionLabel.text = "版本号:".localizedString + " V\(appVersion)"
            }

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupConstraints() {
            logo.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().offset(ZTScaleValue(36))
                $0.width.height.equalTo(ZTScaleValue(120))
            }
            
            nameLabel.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(logo.snp.bottom).offset(ZTScaleValue(28))
            }
            
            versionLabel.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(nameLabel.snp.bottom).offset(ZTScaleValue(15))
            }
        }

    }
}
