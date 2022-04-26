//
//  ProvisioningWebViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/14.
//

import Foundation


class ProvisioningWebViewController: WKWebViewController {
    
    override func navPop() {
        if webView.canGoBack {
            if let first = webView.backForwardList.backList.first {
                webView.go(to: first)
            } else {
                navigationController?.popViewController(animated: true)
            }
            
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
