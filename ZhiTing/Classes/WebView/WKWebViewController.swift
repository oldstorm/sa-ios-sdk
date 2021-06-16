//
//  WKWebViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/23.
//

import Alamofire
import CoreTelephony
import UIKit
import WebKit

class WKWebViewController: BaseViewController {
    var link: String
    
    
    init(link:String) {
        /// 处理编码问题
        let charSet = CharacterSet.urlQueryAllowed as NSCharacterSet
        let mutSet = charSet.mutableCopy() as! NSMutableCharacterSet
        mutSet.addCharacters(in: "#")
    
        if let queryLink = link.addingPercentEncoding(withAllowedCharacters: mutSet as CharacterSet) {
            self.link = queryLink
        } else {
            self.link = link
        }
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var webView: WKWebView!
    var eventHandler:WKEventHandlerSwift!
    
    private lazy var progress: UIProgressView = {
        let progres = UIProgressView.init(progressViewStyle: .default)
        progres.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 1.5)
        progres.progress = 0
        progres.progressTintColor = .custom(.blue_2da3f6)
        progres.trackTintColor = UIColor.clear
        return progres
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
   

    private func setupWebView() {
        eventHandler = WKEventHandlerSwift(webView, self)
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.preferences.minimumFontSize = 10
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.processPool = WKProcessPool()
        config.applicationNameForUserAgent = "zhitingua " + (config.applicationNameForUserAgent ?? "")
        
        let usrScript:WKUserScript = WKUserScript.init(source: WKEventHandlerSwift.handleJS(), injectionTime: .atDocumentStart, forMainFrameOnly: true)
        config.userContentController = WKUserContentController()
        config.userContentController.addUserScript(usrScript)
        config.userContentController.add(self.eventHandler, name: WKEventHandlerNameSwift)
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        eventHandler.webView = webView
        
        view.addSubview(webView)
        webView.addSubview(progress)
        
        webView.snp.makeConstraints { (make) in
           make.edges.equalToSuperview()
        }
        
        progress.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1.5)
        }
        
        if let linkURL = URL(string: link) {
            webView.load(URLRequest(url: linkURL))
           
        }
    
    }
    
    
    override func navPop() {
        if webView.canGoBack {
            webView.goBack()
        }else{
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController.init(title: "alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (_ acton:UIAlertAction) in
            completionHandler()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}


extension WKWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progress.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = ""
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progress.isHidden = true
        progress.progress = 0
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        decisionHandler(.allow)
        
    }

}


extension WKWebViewController: WKUIDelegate {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progress.alpha = 1.0
            let animal = webView.estimatedProgress > Double(progress.progress)
            progress.setProgress(Float(webView.estimatedProgress), animated: animal)
            
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progress.alpha = 0
                }) { (finished) in
                    self.progress.setProgress(0, animated: false)
                }
            }
        }
    }
    
}


extension WKWebViewController: WKEventHandlerProtocol {
    //MARK:WKEventHandlerProtocol
    func nativeHandle(funcName: inout String!, params: Dictionary<String, Any>?, callback: ((Any?) -> Void)?) {
        if funcName == "networkType" {
            networkType(callBack: callback)
        } else if funcName == "setTitle" {
            setTitle(params: params ?? [:])
        } else if funcName == "getUserInfo" {
            getUserInfo(callBack: callback)
        } else if funcName == "isApp" {
            isApp(callBack: callback)
        }
        
    }
    
    
    /// Set navigation style from js
    /// - Parameter params:
    ///{
    /// title: navigation title,
    /// color: navigation title color,
    /// background: navigation bar color,
    /// isShow: whether navigation bar is hidden
    ///}
    @objc func setTitle(params:Dictionary<String,Any>) {
        print("params:%@",params)
        if let title = params["title"] as? String {
            self.title = title
        }
        
        if let color = params["color"] as? String {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(hex: color) ?? .black]
        }
        
        if let background = params["background"] as? String {
            navigationController?.navigationBar.barTintColor = UIColor(hex: background)
        }
        
        if let isShow = params["isShow"] as? String {
            if isShow == "false" {
                navigationController?.setNavigationBarHidden(true, animated: true)
            } else {
                navigationController?.setNavigationBarHidden(false, animated: true)
            }
            
        }

    }
    
    /// Get the current network status
    /// - Parameter callBack: status callback to js
    /// - Returns: nil
    func networkType(callBack:((_ response:Any?) -> ())?) {
        var status = ""
        switch NetworkReachabilityManager.default?.status {
        case .none:
            break
        case .unknown:
            break
        case .notReachable:
            status = ""
        case .reachable(let type):
            switch type {
            case .cellular:
                let networkInfo = CTTelephonyNetworkInfo()
                status = "4g"
                let carrierType = networkInfo.serviceCurrentRadioAccessTechnology
                if let carrierTypeName = carrierType?.first?.value {
                    switch carrierTypeName {
                    case CTRadioAccessTechnologyGPRS,
                         CTRadioAccessTechnologyEdge,
                         CTRadioAccessTechnologyCDMA1x:
                        status = "2g"
                    case CTRadioAccessTechnologyWCDMA,
                         CTRadioAccessTechnologyHSDPA,
                         CTRadioAccessTechnologyHSUPA,
                         CTRadioAccessTechnologyCDMAEVDORev0,
                         CTRadioAccessTechnologyCDMAEVDORevA,
                         CTRadioAccessTechnologyCDMAEVDORevB,
                         CTRadioAccessTechnologyeHRPD:
                        status = "3g"
                    case CTRadioAccessTechnologyLTE:
                        status = "4g"
                    default:
                        status = "5g"
                    }
                }
                
                
                
            case .ethernetOrWiFi:
                status = "wifi"
            }
        
        }
        
        let json = "{ \"type\" : \"\(status)\" }"
        callBack?(json)
        
       

       
        
    }
    
    
    /// Get the current user informations
    /// - Parameter callBack: userInfo
    /// - Returns: nil
    func getUserInfo(callBack:((_ response:Any?) -> ())?) {
        let json = "{ \"token\" : \"\(authManager.currentSA.token)\", \"userId\" : \"\(authManager.currentSA.user_id)\" }"
        callBack?(json)
    }
    
    
    /// if open in app's webview
    /// - Parameter callBack: true
    /// - Returns: isApp
    func isApp(callBack:((_ response:Any?) -> ())?) {
        callBack?("true")
    }
}
