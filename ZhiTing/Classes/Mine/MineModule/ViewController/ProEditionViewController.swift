//
//  ProEditionViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/8.
//

import Foundation
import UIKit
import WebKit

class ProEditionViewController: WKWebViewController {
    private lazy var customView = CustomNavButtonView(frame: CGRect(x: 0, y: 0, width: 70, height: 28))

    override func viewDidLoad() {
        super.viewDidLoad()

        customView.settingButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let vc = ProEditionSettingViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        customView.minimizeButton.clickCallBack = { [weak self] _ in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.shadowImage = UIImage()
        
        navigationBarAppearance.backgroundColor = UIColor.custom(.black_3f4663)
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.font(size: 18, type: .bold), NSAttributedString.Key.foregroundColor: UIColor.custom(.white_ffffff)]
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance


        navBackBtn.isHidden = true
        
        navigationController?.navigationBar.addSubview(customView)
        customView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-8.5)
            $0.width.equalTo(70)
            $0.height.equalTo(28)
        }
        
        customView.settingButton.isEnabled = true
        customView.settingButton.alpha = 1
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        customView.settingButton.isEnabled = false
        customView.settingButton.alpha = 0.3
    }

    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.title = "专业版".localizedString
    }
    
    override func isProfession(callBack: ((Any?) -> ())?) {
        let json = "{ \"result\" : true }"
        callBack?(json)
    }

}





extension ProEditionViewController {
    class CustomNavButtonView: UIView {
        lazy var settingButton = Button().then {
            $0.setImage(.assets(.icon_nav_account), for: .normal)
            $0.frame.size = CGSize(width: 18, height: 18)

        }
        
        lazy var minimizeButton = Button().then {
            $0.setImage(.assets(.icon_nav_minimize), for: .normal)
            $0.frame.size = CGSize(width: 18, height: 18)
        }
        
        private lazy var line = UIView().then {
            $0.backgroundColor = UIColor(red: 126/255, green: 132/255, blue: 155/255, alpha: 1)
        }
        
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(settingButton)
            addSubview(minimizeButton)
            addSubview(line)
            layer.borderWidth = 0.5
            layer.borderColor = UIColor(red: 126/255, green: 132/255, blue: 155/255, alpha: 1).cgColor
            layer.cornerRadius = 14
            
            
            settingButton.snp.makeConstraints {
                $0.top.left.bottom.equalToSuperview()
                $0.width.equalTo(35)
                
            }
            
            minimizeButton.snp.makeConstraints {
                $0.top.right.bottom.equalToSuperview()
                $0.width.equalTo(35)
                
            }
            
            line.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(0.5)
                $0.top.bottom.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
