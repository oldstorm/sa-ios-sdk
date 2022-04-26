//
//  AddCameraViewController.swift
//  ZhiTing
//
//  Created by zy on 2022/4/12.
//

import UIKit
#if !(targetEnvironment(simulator))
class AddCameraViewController: BaseViewController {

    var model = QRCodeCameraResultModel()
    
    private lazy var wifiLabel = Label().then {
        $0.textColor = .custom(.black_333333)
    }
    
    private lazy var wifiPwd = UITextField().then {
        $0.placeholder = "请输入密码"
    }

    private lazy var btn = Button().then {
        $0.setTitle("开始配网", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
    }

    
    let soundWaveSender = VSSoundWaveSender()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupViews() {
        view.addSubview(wifiLabel)
        view.addSubview(wifiPwd)
        view.addSubview(btn)
        
        btn.addTarget(self, action: #selector(btnOnClick), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        wifiLabel.snp.makeConstraints {
            $0.top.equalTo(ZTScaleValue(200))
            $0.left.equalTo(ZTScaleValue(100))
            $0.width.equalTo(ZTScaleValue(100))
        }
        
        wifiPwd.snp.makeConstraints {
            $0.top.equalTo(wifiLabel.snp.bottom).offset(ZTScaleValue(10))
            $0.left.equalTo(ZTScaleValue(100))
            $0.width.equalTo(ZTScaleValue(200))
        }
        
        btn.snp.makeConstraints {
            $0.bottom.equalTo(-ZTScaleValue(200))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(100))
            $0.height.equalTo(ZTScaleValue(50))
        }
        
        wifiLabel.text = networkStateManager.getWifiSSID() ?? ""
    }
    
    @objc private func btnOnClick(){
        print("开始声波配网")
        
        startProvision()
        
        let vc = CameraGuideViewController()
        vc.model = model
        vc.stopCallback = {[weak self] in
            self?.stopProvision()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func startProvision() {
        let bssid = networkStateManager.getWifiBSSID() ?? ""
        soundWaveSender.playWiFiMac(bssid, password: wifiPwd.text ?? "", userId: "10000", playCount: 5)
    }
    
    private func stopProvision() {
        soundWaveSender.stopPlaying()
    }

}
#endif
