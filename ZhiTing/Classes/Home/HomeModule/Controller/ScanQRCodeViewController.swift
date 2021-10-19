//
//  ScanQRCodeViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/17.
//

import UIKit
import swiftScan

class ScanQRCodeViewController: LBXScanViewController {
    lazy var navBackBtn: Button = {
        let btn = Button()
        btn.frame.size = CGSize.init(width: 30, height: 30)
        btn.setImage(.assets(.nav_back_white), for: .normal)
        btn.addTarget(self, action: #selector(navPop), for: .touchUpInside)
        btn.contentHorizontalAlignment = .left
        return btn
    }()
    
    private lazy var tipsLabel = Label().then {
        $0.textColor = .custom(.white_ffffff)
        $0.font = .font(size: 14, type: .medium)
        $0.text = "请扫码家庭/公司二维码\n扫码后即可加入".localizedString
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        //需要识别后的图像
        setNeedCodeImage(needCodeImg: true)

        //框向上移动10个像素
        scanStyle?.centerUpOffset += 10
        scanStyle?.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
        scanStyle?.color_NotRecoginitonArea = UIColor.black.withAlphaComponent(0.8)
        scanStyle?.anmiationStyle = .LineMove
        // Do any additional setup after loading the view.
        
        
        view.addSubview(tipsLabel)
        tipsLabel.frame.size.width = (Screen.screenWidth - 30)
        tipsLabel.frame.size.height = tipsLabel.text!.height(thatFitsWidth: Screen.screenWidth - 30, font: .font(size: 14, type: .medium))
        tipsLabel.frame.origin.x = 15
        tipsLabel.frame.origin.y += (Screen.screenHeight / 2) + 75
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubviewToFront(tipsLabel)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        navigationController?.navigationBar.backgroundColor = .custom(.white_ffffff)
        navigationController?.navigationBar.barTintColor = .custom(.white_ffffff)
        navigationController?.navigationBar.tintColor = .custom(.white_ffffff)
    }

    override func handleCodeResult(arrayResult: [LBXScanResult]) {

        for result: LBXScanResult in arrayResult {
            if let str = result.strScanned {
                print(str)
            }
        }

        let result: LBXScanResult = arrayResult[0]

        print(result)
        
        if let resStr = result.strScanned, let model = QRCodeResultModel.deserialize(from: resStr) {
            var token: String?
            let ip = model.url
            if let cacheArea = AreaCache.areaList().filter({ $0.sa_lan_address == ip }).last {
                token = cacheArea.sa_user_token
            }
            
            
            requestQRCodeResult(qr_code: model.qr_code, sa_url: model.url, token: token, area_name: model.area_name)
            
            
        } else {
            if let window = SceneDelegate.shared.window {
                ScanFailTipsView.show(to: window) { [weak self] in
                    self?.startScan()
                }
            }
        }
        
        
        

    }


}

extension ScanQRCodeViewController {
    private func requestQRCodeResult(qr_code: String, sa_url: String, token: String?, area_name: String = "") {
        let nickname = AuthManager.shared.currentUser.nickname
        

        GlobalLoadingView.show()
        ApiServiceManager.shared.scanQRCode(qr_code: qr_code, url: sa_url, nickname: nickname, token: token) { [weak self] response, isSAEnv, saId, tempIp in
            guard let self = self else { return }

            let area = Area()
            area.sa_lan_address = sa_url
            area.id = response.area_info.id
            area.sa_user_id = response.user_info.user_id
            area.is_bind_sa = true
            area.sa_user_token = response.user_info.token
            area.name = area_name
            area.id = response.area_info.id
            if isSAEnv {
                area.ssid = NetworkStateManager.shared.getWifiSSID()
                area.bssid = NetworkStateManager.shared.getWifiBSSID()
            }

            
            
            
            /// 如果本地没有该家庭id的家庭 并且是登录状态 要绑定该家庭到云端
            if  AuthManager.shared.isLogin {
                area.cloud_user_id = AuthManager.shared.currentUser.user_id
                // 如果本地已存在该家庭
                if let existedArea = AreaCache.areaList().filter({ $0.id == response.area_info.id }).first {
                    existedArea.sa_user_token = response.user_info.token
                    AreaCache.removeArea(by: existedArea.id)
                    AreaCache.cacheArea(areaCache: existedArea.toAreaCache())
                    AuthManager.shared.currentArea = existedArea
                    
                    GlobalLoadingView.hide()
                    AppDelegate.shared.appDependency.tabbarController.homeVC?.view.makeToast("你已成功加入\(area_name)")
                    self.navigationController?.tabBarController?.selectedIndex = 0
                    self.navigationController?.popToRootViewController(animated: false)
                    return
                }
                
                /// 先移除本地相同id的家庭相关数据
                AreaCache.removeArea(by: area.id)
                
                /// 缓存该家庭
                AreaCache.cacheArea(areaCache: area.toAreaCache())

                
                /// 创建一个云端家庭并绑定该SA家庭到这个云端家庭
                ApiServiceManager.shared.createArea(name: area.name, locations_name: []) { [weak self] response in
                    guard let self = self else { return }
                    /// 绑定SA <-> 云 (可以直接走SA 也可以通过临时通道)
                    
                    var url = area.sa_lan_address ?? ""
                    
                    if !isSAEnv { // 非SA环境走临时通道
                        url = tempIp ?? ""
                    }

                    ApiServiceManager.shared.bindCloud(area: area, cloud_area_id: response.id, cloud_user_id: AuthManager.shared.currentUser.user_id, url: url) { [weak self] response in
                        guard let self = self else { return }
                        GlobalLoadingView.hide()
                        
                        AuthManager.shared.currentArea = area
                        AppDelegate.shared.appDependency.tabbarController.homeVC?.view.makeToast("你已成功加入\(area_name)")
                        self.navigationController?.tabBarController?.selectedIndex = 0
                        self.navigationController?.popToRootViewController(animated: false)
                    } failureCallback: { code, err in
                        /// 绑定SA到云失败
                        GlobalLoadingView.hide()
                        
                        AuthManager.shared.currentArea = area
                        AppDelegate.shared.appDependency.tabbarController.homeVC?.view.makeToast("你已成功加入\(area_name)")
                        self.navigationController?.tabBarController?.selectedIndex = 0
                        self.navigationController?.popToRootViewController(animated: false)
                    }



                } failureCallback: { [weak self] code, err in
                    /// 创建云端家庭失败
                    guard let self = self else { return }
                    GlobalLoadingView.hide()
                    self.view.makeToast("扫码失败".localizedString)
                }

            } else {
                /// 先移除本地相同id的家庭相关数据
                AreaCache.removeArea(by: area.id)
                /// 缓存该家庭
                AreaCache.cacheArea(areaCache: area.toAreaCache())

                GlobalLoadingView.hide()
                AuthManager.shared.currentArea = area
                AppDelegate.shared.appDependency.tabbarController.homeVC?.view.makeToast("你已成功加入\(area_name)")
                self.navigationController?.tabBarController?.selectedIndex = 0
                self.navigationController?.popToRootViewController(animated: false)
            }
            
        } failureCallback: { [weak self] (code, err) in
            /// 扫码失败回调
            GlobalLoadingView.hide()
            guard let self = self else { return }
            if code == -2 { //扫描二维码的人与家庭的SA不在同一个局域网且未登录时, 提示请在局域网内扫描或登录后重新扫描。
                TipsAlertView.show(message: "请在局域网内扫描或登录后重新扫描".localizedString, sureTitle: "去登录") {
                    AuthManager.checkLoginWhenComplete(loginComplete: nil, jumpAfterLogin: false)
                }

                self.navigationController?.popToRootViewController(animated: true)
                
                
            } else {
                self.view.makeToast(err)
                self.startScan()
            }
            
                
        }
        
    }


}

// MARK: - Navigation stuff
extension ScanQRCodeViewController: UIGestureRecognizerDelegate {
    private func setupNavigation() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.shadowImage = UIImage()
        
        navigationBarAppearance.backgroundColor = .black
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.font(size: 18, type: .bold), NSAttributedString.Key.foregroundColor: UIColor.custom(.black_3f4663)]
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        if navigationController?.children.first != self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navBackBtn)
        }
        
        
        
    }

    @objc func navPop() {
        navigationController?.popViewController(animated: true)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


extension ScanQRCodeViewController {
      
    private class QRCodeResultModel: BaseModel {
        var qr_code = ""
        var url = ""
        var area_name = ""
        var area_id: Int64?
    }
}
