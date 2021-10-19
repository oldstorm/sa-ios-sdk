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
    var webViewTitle: String?
    var device : CommonDevice?
    
    /// blufi 配网工具
    lazy var bluFiTool = BluFiTool()
    
    /// soft ap配网工具
    lazy var softAPTool = SoftAPTool()


    init(link:String) {
        /// 处理编码问题
        self.link = link
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
            make.top.equalToSuperview().offset(Screen.k_nav_height)
            make.left.right.bottom.equalToSuperview()
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
        if let webViewTitle = webViewTitle {
            title = webViewTitle
        }

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

//MARK: WKEventHandlerProtocol
extension WKWebViewController: WKEventHandlerProtocol {
    
    
    /// 注册到JS的方法
    /// - Parameters:
    ///   - funcName: 方法名称
    ///   - params: 方法参数
    ///   - callback: 方法回调
    func nativeHandle(funcName: inout String!, params: Dictionary<String, Any>?, callback: ((Any?) -> Void)?) {
        if funcName == "networkType" {
            networkType(callBack: callback)
        } else if funcName == "setTitle" {
            setTitle(params: params ?? [:])
        } else if funcName == "getUserInfo" {
            getUserInfo(callBack: callback)
        } else if funcName == "isApp" {
            isApp(callBack: callback)
        } else if funcName == "isProfession" {
            isProfession(callBack: callback)
        } else if funcName == "connectDeviceHotspot" {
            connectDeviceHotspot(params: params, callBack: callback)
        } else if funcName == "createDeviceByHotspot" {
            createDeviceByHotspot(params: params, callBack: callback)
        } else if funcName == "connectDeviceByHotspot" {
            connectDeviceByHotspot(params: params, callBack: callback)
        } else if funcName == "connectNetworkByHotspot" {
            connectNetworkByHotspot(params: params, callBack: callback)
        } else if funcName == "connectDeviceByBluetooth" {
            connectDeviceByBluetooth(params: params, callBack: callback)
        } else if funcName == "connectNetworkByBluetooth" {
            connectNetworkByBluetooth(params: params, callBack: callback)
        } else if funcName == "getDeviceInfo" {
            getDeviceInfo(callback: callback)
        } else if funcName == "getConnectWifi" {
            getConnectWifi(callback: callback)
        } else if funcName == "toSystemWlan" {
            toSystemWlan()
        } else if funcName == "getSystemWifiList" {
            getSystemWifiList(callback: callback)
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
    @objc func setTitle(params: Dictionary<String,Any>) {
        print("params:%@",params)
        if let title = params["title"] as? String {
            self.title = title
        }
        
        if let color = params["color"] as? String {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(hex: color) ?? .black]

        }
        
        if let background = params["background"] as? String {
            navigationController?.navigationBar.barTintColor = UIColor(hex: background)
            navigationController?.navigationBar.backgroundColor = UIColor(hex: background)

        }
        
        if let isShow = params["isShow"] as? Bool {
            if isShow == false {
                navigationController?.setNavigationBarHidden(true, animated: false)
                webView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(Screen.statusBarHeight)
                    make.left.right.bottom.equalToSuperview()
                }
            } else {
                navigationController?.setNavigationBarHidden(false, animated: false)
                webView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(Screen.k_nav_height)
                    make.left.right.bottom.equalToSuperview()
                }
            }
            
        }

    }
    
    /// Get the current network status
    /// - Parameter callBack: status callback to js
    /// - Returns: nil
    func networkType(callBack:((_ response: Any?) -> ())?) {
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
    func getUserInfo(callBack:((_ response: Any?) -> ())?) {
        let json = "{ \"token\" : \"\(authManager.currentArea.sa_user_token)\", \"userId\" : \"\(authManager.currentArea.sa_user_id)\" }"
        callBack?(json)
    }
    
    
    /// if open in app's webview
    /// - Parameter callBack: true
    /// - Returns: isApp
    func isApp(callBack:((_ response: Any?) -> ())?) {
        callBack?("true")
    }
    
    /// if open in professionEdition
    /// - Parameter callBack: true
    /// - Returns: isProfession
    @objc func isProfession(callBack:((_ response: Any?) -> ())?) {
        let json = "{ \"result\" : false }"
        callBack?(json)
    }
}

//MARK: 提供给JS调用的配网相关方法
extension WKWebViewController {
    /// 获取配网设备信息
    func getDeviceInfo(callback:((_ response: Any?) -> ())?) {
        let deviceJson = self.device?.toJSONString() ?? ""
        callback?(deviceJson)
    }
    
    /// 获取当前wifi信息
    func getConnectWifi(callback:((_ response: Any?) -> ())?) {
        let ssid = NetworkStateManager.shared.getWifiSSID() ?? ""
        // 0：已连接wifi 1：未连接wifi
        let status = ssid == "" ? 1 : 0
        let json1 = "{ \"status\":\(status),\"wifiName\":\"\(ssid)\"}"
        callback?(json1)
    }

    /// 连接设备热点
    func connectDeviceHotspot(params: Dictionary<String,Any>?, callBack:((_ response: Any?) -> ())?) {
        bluFiTool.udpDeviceTool = nil
        guard let params = params,
              let ssid = params["hotspotName"] as? String
        else {
            return
        }
        
        var json = ""
        softAPTool.applyConfiguration(ssid: ssid) { isSuccess in
            if isSuccess {
                json = "{\"status\": 0,\"error\": \"\"}"
                print("连接热点成功")
            } else {
                json = "{\"status\": 1,\"error\": \"连接热点失败\"}"
                print("连接热点失败")
            }
            DispatchQueue.main.async {
                callBack?(json)
            }
            
        }
    }
    
    /// 通过设备热点创建设备
    func createDeviceByHotspot(params: Dictionary<String,Any>?, callBack:((_ response: Any?) -> ())?) {
        guard let params = params,
              let deviceName = params["hotspotName"] as? String,
              let pop = params["ownership"] as? String
        else {
            return
        }
        var json = ""
        softAPTool.createESPDevice(deviceName: deviceName, proofOfPossession: pop) { device in
            if device != nil { // 创建成功
                json = "{\"status\": 0,\"error\": \"\"}"
                print("创建esp设备成功")
            } else { // 失败
                json = "{\"status\": 1,\"error\": \"连接设备失败\"}"
                print("创建esp设备失败")
            }
            DispatchQueue.main.async {
                callBack?(json)
            }
        }
    }
    
    /// 通过热点连接设备
    func connectDeviceByHotspot(params: Dictionary<String,Any>?, callBack:((_ response: Any?) -> ())?) {
        var json = ""
        softAPTool.connectESPDevice { status in
            switch status {
            case .connected:
                json = "{\"status\": 0,\"error\": \"\"}"
                print("连接esp设备成功")

            case .disconnected:
                json = "{\"status\": 1,\"error\": \"连接设备失败\"}"
                print("连接esp设备失败")
                
            case .failedToConnect:
                json = "{\"status\": 1,\"error\": \"连接设备失败\"}"
                print("连接esp设备失败")
            }
            DispatchQueue.main.async {
                callBack?(json)
            }
        }
    }
    
    /// 通过热点发送配网信息
    func connectNetworkByHotspot(params: Dictionary<String,Any>?, callBack:((_ response: Any?) -> ())?) {
        guard let params = params,
              let ssid = params["wifiName"] as? String,
              let pwd = params["wifiPass"] as? String
        else {
            return
        }
        var json = ""
        softAPTool.provisionDevice(ssid: ssid, passphrase: pwd) { status in
            switch status {
            case .success:
                json = "{\"status\": 0,\"error\": \"\"}"
                
                print("esp设备配网成功")
                DispatchQueue.main.async {
                    callBack?(json)
                }
                
            case .configApplied:
                print("esp设备配网中")
                
                
            case .failure:
                json = "{\"status\": 1,\"error\": \"设备配网失败\"}"
                
                print("esp设备配网失败")
                DispatchQueue.main.async {
                    callBack?(json)
                }
            }
        }
    }
    
    /// 通过蓝牙连接设备
    func connectDeviceByBluetooth(params: Dictionary<String,Any>?, callBack:((_ response: Any?) -> ())?) {
        softAPTool.udpDeviceTool = nil
        guard let params = params,
              let filterContent = params["bluetoothName"] as? String
        else {
            return
        }
        var json = ""
        bluFiTool.connectCallback = { success in
            if success {
                json = "{\"status\": 0,\"error\": \"\"}"
                print("蓝牙设备连接成功")
            } else {
                json = "{\"status\": 1,\"error\": \"蓝牙设备连接失败\"}"
                print("蓝牙设备连接失败")
            }
            DispatchQueue.main.async {
                callBack?(json)
            }
        }
        bluFiTool.scanAndConnectDevice(filterContent: filterContent)
    }

    /// 通过蓝牙给设备发送配网信息
    func connectNetworkByBluetooth(params: Dictionary<String,Any>?, callBack:((_ response: Any?) -> ())?) {
        guard let params = params,
              let ssid = params["wifiName"] as? String,
              let pwd = params["wifiPass"] as? String
        else {
            return
        }
        var json = ""
        bluFiTool.provisionCallback = { success in
            if success {
                json = "{\"status\": 0,\"error\": \"\"}"
            } else {
                json = "{\"status\": 1,\"error\": \"设备配网失败\"}"
            }
            
            DispatchQueue.main.async {
                callBack?(json)
            }
        }

        bluFiTool.configWifi(ssid: ssid, pwd: pwd)

    }
    
    /// 跳转系统设置页
    func toSystemWlan() {
        if let url = URL(string: "App-Prefs:root=WIFI"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func getSystemWifiList(callback:((_ response: Any?) -> ())?) {
        let wifiListJson = networkStateManager.getHistoryWifiList().toJSONString() ?? ""
        let json = "{\"status\": 0,\"list\": \(wifiListJson)}"
        callback?(json)
    }


}
