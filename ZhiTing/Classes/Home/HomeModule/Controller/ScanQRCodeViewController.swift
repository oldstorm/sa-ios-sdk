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
            
            
            requestQRCodeResult(qr_code: model.qr_code, sa_url: model.url, token: token, area_name: model.area_name, area_id: model.area_id)
            
            
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
    private func requestQRCodeResult(qr_code: String, sa_url: String, token: String?, area_name: String = "", area_id: Int) {
        let nickname = AppDelegate.shared.appDependency.authManager.currentUser.nickname
        var url = sa_url
        
        if area_id > 0 && AppDelegate.shared.appDependency.authManager.isLogin { /// 家庭绑定了云端且已经登录的情况下走云 否则走sa
            url = "\(cloudUrl)"

        }

        GlobalLoadingView.show()
        ApiServiceManager.shared.scanQRCode(qr_code: qr_code, url: url, nickname: nickname, token: token, area_id: area_id) { [weak self] response in
            guard let self = self else { return }

            let area = Area()
           
            area.sa_lan_address = sa_url
            
            
            if area_id > 0 && AppDelegate.shared.appDependency.authManager.isLogin { /// 家庭绑定了云端且已经登录的情况下area的id 为绑定云后id 否则为0
                area.id = response.area_id ?? 0
            } else {
                if let id = AreaCache.areaList().first(where: { $0.sa_user_token == response.user_info.token })?.id {
                    area.id = id
                } else {
                    area.id = 0
                }
                area.ssid = AppDelegate.shared.appDependency.networkManager.getWifiSSID()
                area.macAddr = AppDelegate.shared.appDependency.networkManager.getWifiBSSID()
            }

            area.sa_user_id = response.user_info.user_id
            area.is_bind_sa = true
            area.sa_user_token = response.user_info.token
            area.name = area_name
            
            
            AreaCache.cacheArea(areaCache: area.toAreaCache())
            
            if AppDelegate.shared.appDependency.authManager.isLogin && area.id == 0 {
                AppDelegate.shared.appDependency.authManager.syncLocalAreasToCloud { [weak self] in
                    GlobalLoadingView.hide()
                    guard let self = self else { return }
                    
                    if let switchArea = AreaCache.areaList().first(where: { $0.sa_user_token == response.user_info.token }) {
                        AppDelegate.shared.appDependency.authManager.currentArea = switchArea
                    }
                    
                    AppDelegate.shared.appDependency.tabbarController.homeVC?.view.makeToast("你已成功加入\(area_name)")
                    self.navigationController?.tabBarController?.selectedIndex = 0
                    self.navigationController?.popToRootViewController(animated: false)
                }
            } else {
                GlobalLoadingView.hide()
                AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
                AppDelegate.shared.appDependency.authManager.currentArea = area
                AppDelegate.shared.appDependency.tabbarController.homeVC?.view.makeToast("你已成功加入\(area_name)")
                self.navigationController?.tabBarController?.selectedIndex = 0
                self.navigationController?.popToRootViewController(animated: false)
            }
            
        } failureCallback: { [weak self] (code, err) in
            GlobalLoadingView.hide()
            guard let self = self else { return }
            self.view.makeToast(err)
            self.startScan()
                
        }
        
    }


}

// MARK: - Navigation stuff
extension ScanQRCodeViewController: UIGestureRecognizerDelegate {
    private func setupNavigation() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        if navigationController?.children.first != self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navBackBtn)
        }
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.font(size: 18, type: .bold), NSAttributedString.Key.foregroundColor: UIColor.custom(.black_3f4663)]
        
        
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
        var area_id = 0
    }
}
