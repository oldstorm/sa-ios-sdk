//
//  OpenUrlHandler.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/22.
//

import Foundation

// MARK: - OpenUrlHandler
class OpenUrlHandler {
    var tabbarController: TabbarController {
        return AppDelegate.shared.appDependency.tabbarController
    }
    
    var waitOpenUrl: URL?

    enum Action: String {
        /// 打开设备详情
        case open
        /// 网盘授权
        case diskAuth
    }

    var navigationController: BaseNavigationViewController? {
        return tabbarController.selectedViewController as? BaseNavigationViewController
    }

    func open(url: URL) {
        let urlString = url.absoluteString
        
        if let nav = SceneDelegate.shared.window?.rootViewController as? BaseNavigationViewController,
           nav.viewControllers.first is LaunchViewController {
            self.waitOpenUrl = url
            return
        }
        
        self.waitOpenUrl = nil
        print("--------------------- open from other app ----------------------------------")
        print(Date())
        print("---------------------------------------------------------------------------")
        print("open url from \(urlString)")
        print("---------------------------------------------------------------------------\n\n")
        guard
            let components = urlString.components(separatedBy: "zhiting://operation?").last,
            let action = components.components(separatedBy: "&").first?.components(separatedBy: "=").last
        else {
            return
        }
        
        switch Action(rawValue: action) {
        case .open:
            // zhiting://operation?action=open&params=http://192.168.0.184/doc/test.html
            if let params = components.components(separatedBy: "&").last?.components(separatedBy: "=").last {
                let vc = DeviceWebViewController(link: params)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        case .diskAuth:
            // zhiting://operation?action=diskAuth
            let vc = BaseNavigationViewController(rootViewController: NasAuthorizationViewController()) 
            tabbarController.present(vc, animated: true, completion: nil)
            
        default:
            break
        }

    }
    
}
