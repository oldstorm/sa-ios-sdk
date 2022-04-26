//
//  LaunchViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/30.
//

import UIKit
import RealmSwift
import SwiftUI

class LaunchViewController: BaseViewController {

    @UserDefaultBool(key: .isAgreePrivacy) var isAgreePrivacy

    var launchTap = 0
    lazy var image = ImageView().then {
        $0.image = .assets(.icon_launch)
    }
    
    lazy var launchImgView = ImageView().then {
        $0.image = .assets(.Launch1)
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
    }
    
    lazy var nextBtn = Button().then {
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.titleLabel?.textAlignment = .center
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(20)
        $0.layer.masksToBounds = true
    }
    
    lazy var label = Label().then {
        $0.text = "你的智能生活助手".localizedString
        $0.font = .font(size: 30, type: .light)
        $0.numberOfLines = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        checkIfExistAccordingLocalSA()
        
        if isAgreePrivacy == true {
            requestPhoneAuth()
            checkAppVersion()
        } else {
            agreePrivacy()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(image)
        view.addSubview(label)
        
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(27.5)
        }
        
        image.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16.5 - Screen.bottomSafeAreaHeight)
            $0.width.equalTo(70)
            $0.height.equalTo(65)
            $0.centerX.equalToSuperview()
        }
    }
}


extension LaunchViewController {
    /// 获取手机相关权限
    private func requestPhoneAuth() {
        /// 位置权限 (获取wifi的信息必须要开启此权限)
        networkStateManager.locationManager?.requestAlwaysAuthorization()
        /// 用于触发本地网络权限弹窗或者更新SA地址
        UDPDeviceTool.updateAreaSAAddress(force: true)
    }
    

    private func checkIfExistAccordingLocalSA() {
        let areas = AreaCache.areaList()
        let wifiSSID = networkStateManager.getWifiSSID()
        let wifiMac = networkStateManager.getWifiBSSID()
        
        print("wifi SSID: \(String(describing: wifiSSID))")
        print("wifi Mac:\(String(describing: wifiMac))")

        if let user = UserCache.getUsers().first {
            UserManager.shared.currentUser = user
        } else {
            let user = User()
            user.nickname = "User_" + UUID().uuidString.prefix(6)
            UserCache.update(from: user)
            UserManager.shared.currentUser = user
        }

        if let area = areas.first(where: { $0.ssid == wifiSSID && $0.bssid == wifiMac && $0.ssid != nil && $0.bssid != nil }) {
            AuthManager.shared.currentArea = area
        } else {
            if areas.count == 0 {
                setupNewLocalSAandUser()
            }
            
            if let currentArea = AreaCache.areaList().first {
                AuthManager.shared.currentArea = currentArea
            }
        }

    }
    
    private func agreePrivacy(){
        let alert = PrivacyAlert { [weak self] in
            guard let self = self else { return }
            self.isAgreePrivacy = true
            self.setupLaunchView()
        } cancel: {
            
            let tipsAlert = PrivacyTipsView { [weak self] in
                guard let self = self else { return }
                //查看协议
                self.agreePrivacy()
            } cancel: {
                //退出
                exit(0)
            }

            self.view.addSubview(tipsAlert)
            
        } privacy: { [weak self] in
            guard let self = self else { return }
            let vc = WKWebViewController(linkEnum: .privacy)
            vc.title = "隐私政策".localizedString
            self.navigationController?.pushViewController(vc, animated: true)
        } userAgreement: { [weak self] in
            guard let self = self else { return }
            let vc = WKWebViewController(linkEnum: .userAgreement)
            vc.title = "用户协议".localizedString
            self.navigationController?.pushViewController(vc, animated: true)
        }
        view.addSubview(alert)
    }
    
    
    func checkAppVersion(){
        //获取当前app版本信息
        let infoDic = Bundle.main.infoDictionary
        let appVersion = infoDic?["CFBundleShortVersionString"] as? String
        
        ApiServiceManager.shared.getAppVersions { response in
            let appNewVersion = response.max_app_version
            if ZTVersionTool.compareVersionIsNewBigger(nowVersion: appVersion ?? "1.0.0", newVersion: appNewVersion) {//当前版本并非最新版本
                //app更新弹窗
                AppUpdateAlertView.show(checkAppModel: response) {
                    //跳转去appstore
                    let str = "itms-apps://itunes.apple.com/app/id1591550488"
                    guard let url = URL(string: str) else { return }
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:]) { (b) in
                            print("打开结果: \(b)")
                        }
                    }
                } cancelCallback: {
                    //进入app
                    DispatchQueue.main.async {
                        SceneDelegate.shared.window?.rootViewController = AppDelegate.shared.appDependency.tabbarController
                    }
                }

            } else {
                //进入app
                DispatchQueue.main.async {
                    SceneDelegate.shared.window?.rootViewController = AppDelegate.shared.appDependency.tabbarController
                }
            }
        } failureCallback: { code, err in
            //进入app
            DispatchQueue.main.async {
                SceneDelegate.shared.window?.rootViewController = AppDelegate.shared.appDependency.tabbarController
            }
        }

    }
    
    func setupLaunchView(){
        view.addSubview(launchImgView)
        view.bringSubviewToFront(launchImgView)
        launchImgView.addSubview(nextBtn)
        launchImgView.bringSubviewToFront(nextBtn)

        launchImgView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        nextBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(81.5))
            $0.width.equalTo(ZTScaleValue(120))
            $0.height.equalTo(ZTScaleValue(40))
        }
        
        if Screen.isiPhoneXScreen {
            self.launchImgView.image = .assets(.Launch1_iPhoneX)

        }else{
            self.launchImgView.image = .assets(.Launch1)
        }
        nextBtn.setTitle("下一步（1/4）", for: .normal)
        launchTap = 1
        nextBtn.clickCallBack = { [weak self] _ in
            guard let self = self else {return}
            self.launchTap += 1
            switch self.launchTap {
            case 2:
                self.nextBtn.setTitle("下一步（2/4）", for: .normal)
                if Screen.isiPhoneXScreen {
                    self.launchImgView.image = .assets(.Launch2_iPhoneX)

                } else {
                    self.launchImgView.image = .assets(.Launch2)
                }
            case 3:
                self.nextBtn.setTitle("下一步（3/4）", for: .normal)
                if Screen.isiPhoneXScreen {
                    self.launchImgView.image = .assets(.Launch3_iPhoneX)

                } else {
                    self.launchImgView.image = .assets(.Launch3)
                }
            case 4:
                self.nextBtn.setTitle("完成（4/4）", for: .normal)
                if Screen.isiPhoneXScreen {
                    self.launchImgView.image = .assets(.Launch4_iPhoneX)

                } else {
                    self.launchImgView.image = .assets(.Launch4)
                }
            default:
                self.requestPhoneAuth()
                SceneDelegate.shared.window?.rootViewController = AppDelegate.shared.appDependency.tabbarController
            }
        }
    }
    
    
    func setupNewLocalSAandUser() {
        let area = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)", mode: .family)

        AuthManager.shared.currentArea = area.transferToArea()
        
        
    }
}

