//
//  ConnectDeviceViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit

class ConnectDeviceViewController: BaseViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "设备连接".localizedString
    }
    
    private lazy var percentageView = ConnectPercentageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    private func setupViews() {
        view.backgroundColor = Colors.white
        view.addSubview(percentageView)
        
        percentageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(75)
            make.width.height.equalTo(Screen.screenWidth - 175)
        }
        
        percentageView.setProgress(progress: 0)
    }
    
}
