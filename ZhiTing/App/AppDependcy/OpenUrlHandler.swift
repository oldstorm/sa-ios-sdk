//
//  OpenUrlHandler.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/22.
//

import Foundation

// MARK: - OpenUrlHandler
struct OpenUrlHandler {
    var tabbarController: TabbarController {
        return AppDelegate.shared.appDependency.tabbarController
    }
    
    enum Action: String {
        case open
    }

    var navigationController: BaseNavigationViewController? {
        return tabbarController.selectedViewController as? BaseNavigationViewController
    }

    func open(url: URL) {
        let urlString = url.absoluteString
        
        print("--------------------- open from other app ----------------------------------")
        print(Date())
        print("---------------------------------------------------------------------------")
        print("open url from \(urlString)")
        print("---------------------------------------------------------------------------\n\n")
        // zhiting://operation?action=open&params=http://192.168.0.184/doc/test.html
        // action=open&params=http://192.168.0.184/doc/test.html
        guard
            let components = urlString.components(separatedBy: "zhiting://operation?").last,
            let action = components.components(separatedBy: "&").first?.components(separatedBy: "=").last,
            let params = components.components(separatedBy: "&").last?.components(separatedBy: "=").last
        else {
            return
        }
        
        switch Action(rawValue: action) {
        case .open:
            let vc = DeviceWebViewController(link: params)
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }

    }
    
}
