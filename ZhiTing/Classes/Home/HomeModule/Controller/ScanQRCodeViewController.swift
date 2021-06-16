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
            if let ip = model.url.components(separatedBy: "//").last {
                if let cacheSA = SmartAssistantCache.getSmartAssistantsFromCache().filter({ $0.ip_address == ip }).first {
                    token = cacheSA.token
                }
            }

            requestQRCodeResult(qr_code: model.qr_code, url: model.url, token: token, area_name: model.area_name)
            
            
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
    private func requestQRCodeResult(qr_code: String, url: String, token: String?, area_name: String = "") {
        let nickname = AppDelegate.shared.appDependency.authManager.currentSA.nickname

        GlobalLoadingView.show()
        AppDelegate.shared.appDependency.apiService.requestModel(
            .scanQRCode(qr_code: qr_code, url: url, nickname: nickname, token: token),
            modelType: ScanResponse.self
        ) { [weak self] response in
            GlobalLoadingView.hide()
            guard let self = self else { return }
            let sa = SmartAssistantCache()
            if let ip = url.components(separatedBy: "//").last {
                sa.ip_address = ip
            }
            

            sa.ssid = ""
            sa.token = response.user_info.token
            sa.user_id = response.user_info.user_id
            sa.nickname = nickname

            SmartAssistantCache.cacheSmartAssistants(sa: sa)
            AppDelegate.shared.appDependency.authManager.currentSA = sa.transformToSAModel()
            AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
            
            AppDelegate.shared.appDependency.tabbarController.homeVC?.view.makeToast("你已成功加入\(area_name)")
            self.navigationController?.tabBarController?.selectedIndex = 0
            self.navigationController?.popToRootViewController(animated: false)
            
            
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
    private class ScanResponse: BaseModel {
        var user_info = User()
    }
    
      
    private class QRCodeResultModel: BaseModel {
        var qr_code = ""
        var url = ""
        var area_name = ""
    }
}
