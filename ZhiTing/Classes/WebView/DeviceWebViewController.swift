//
//  DeviceWebViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/3.
//

import Foundation
import UIKit
import WebKit
import Alamofire
import CoreTelephony

class DeviceWebViewController: WKWebViewController {
    // 初始url
    var originLink: String?
    var device_id: Int?
    var area = AuthManager.shared.currentArea
    
    init(link: String, device_id: Int? = nil) {
        self.device_id = device_id
        self.originLink = link

        /// 处理编码问题
        let encodedLink = link.urlDecoded().urlEncoded().replacingOccurrences(of: "%23", with: "#")

        super.init(link: encodedLink)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    private lazy var progress: UIProgressView = {
        let progres = UIProgressView.init(progressViewStyle: .default)
        progres.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 1.5)
        progres.progress = 0
        progres.progressTintColor = .custom(.blue_2da3f6)
        progres.trackTintColor = UIColor.clear
        return progres
    }()
    
    private lazy var settingButton = Button().then {
        $0.setImage(.assets(.settings), for: .normal)
        $0.frame.size = CGSize(width: 18, height: 18)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let vc = DeviceDetailViewController()
            vc.device_id = self.device_id ?? -1
            vc.area = self.area
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDeviceDetail()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
   
    
    private func getDeviceDetail() {
        guard let device_id = device_id else {
            return
        }
        
        ApiServiceManager.shared.deviceDetail(area: area, device_id: device_id) { [weak self] (response) in
            guard let self = self else { return }
            if response.device_info.permissions.delete_device || response.device_info.permissions.update_device {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.settingButton)
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
            
            // http://192.168.22.123:9020/api/static/ivrkqc-sa/plugin/philips-hue/?device_id=9&identity=00:17:88:01:09:5b:ef:5d-0b&model=Hue white Lamp&name=Philips Hue_Hue&plugin_id=philips-hue&sa_id=ivrkqc-sa&token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjMxNTM2MDAwMCwiYXJlYV9pZCI6MjI1NzEyNDI0NzczNTc2MTgsImFjY2Vzc19jcmVhdGVfYXQiOjE2MzU3MzU5NDksImNsaWVudF9pZCI6Ijk5Y2Y1OTBkLWI4ZWMtNDc1MC04ZDU5LTY2NGQ4OTM2Y2JkMiIsInNjb3BlIjoidXNlcixhcmVhLGRldmljZSJ9.EWjMAYjc3gZ3MgUU17WPkXzS7iuUehqebedYENMvg7w
            
            // 如果设备名字发生了变化,替换url中name部分并刷新webview页面
            guard let originLink = self.originLink,
                  let originName = originLink.components(separatedBy: "&name=").last?.components(separatedBy: "&").first
            else {
                return
            }
            
            let newLink = originLink.replacingOccurrences(of: originName, with: response.device_info.name)
            /// 处理编码问题
            let encodedLink = newLink.urlDecoded().urlEncoded().replacingOccurrences(of: "%23", with: "#")
            if let linkURL = URL(string: encodedLink) {
                self.webView.load(URLRequest(url: linkURL))
            }

        } failureCallback: { code, err in
            
        }

    }
}
