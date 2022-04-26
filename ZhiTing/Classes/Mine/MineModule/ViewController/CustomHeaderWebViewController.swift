//
//  CustomHeaderWebViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/12/17.
//



import Foundation
import UIKit
import WebKit

class CustomHeaderWebViewController: WKWebViewController {
    private lazy var customView = CustomNavButtonView(frame: CGRect(x: 0, y: 0, width: 70, height: 28))
    
    private var linkEnum: LinkEnum?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        customView.minimizeButton.clickCallBack = { [weak self] _ in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    override init(linkEnum: LinkEnum) {
        self.linkEnum = linkEnum
        super.init(linkEnum: linkEnum)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.shadowImage = UIImage()
        
        navigationBarAppearance.backgroundColor = UIColor.custom(.blue_2da3f6)
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.font(size: 18, type: .bold), NSAttributedString.Key.foregroundColor: UIColor.custom(.white_ffffff)]
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance


        navBackBtn.isHidden = true
        
        navigationController?.navigationBar.addSubview(customView)
        customView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-8.5)
            $0.width.equalTo(40)
            $0.height.equalTo(28)
        }
        

        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.title = linkEnum?.webViewTitle
    }
    

}





extension CustomHeaderWebViewController {
    class CustomNavButtonView: UIView {
        lazy var minimizeButton = Button().then {
            $0.setImage(.assets(.icon_nav_minimize), for: .normal)
            $0.frame.size = CGSize(width: 18, height: 18)
        }
        

        
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(minimizeButton)
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.custom(.white_ffffff).withAlphaComponent(0.6).cgColor
            layer.cornerRadius = 14
            
            minimizeButton.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.centerX.equalToSuperview()
                $0.width.equalTo(35)
                
            }
            
            

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
