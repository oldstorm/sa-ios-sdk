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
    var device_id: Int = -1
    var area = Area()
    
    init(link:String, device_id: Int = -1) {
        /// 处理编码问题
        self.device_id = device_id
        super.init(link: link.urlDecoded().urlEncoded())
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
            vc.device_id = self.device_id
            vc.area = self.area
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRolePermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
   
    
    private func getRolePermission() {
        ApiServiceManager.shared.deviceDetail(area: area, device_id: device_id) { [weak self] (response) in
            guard let self = self else { return }
            if response.device_info.permissions.delete_device || response.device_info.permissions.update_device {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.settingButton)
                 
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        } failureCallback: { code, err in
            
        }

    }
}
