//
//  CameraGuideViewController.swift
//  ZhiTing
//
//  Created by zy on 2022/4/12.
//

import UIKit

class CameraGuideViewController: BaseViewController {

    var model = QRCodeCameraResultModel()
    
    var stopCallback: (() -> ())?


    private lazy var tipsLabel = Label().then {
        $0.textColor = .custom(.black_333333)
        $0.text = "请听到Wi-Fi连接成功后点击下一步"
        $0.textAlignment = .center
    }
    
    private lazy var btn = Button().then {
        $0.setTitle("下一步", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.titleLabel?.textAlignment = .center
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupViews() {
        view.addSubview(tipsLabel)
        view.addSubview(btn)
        
        btn.addTarget(self, action: #selector(btnOnClick), for: .touchUpInside)

    }
    
    override func setupConstraints() {
        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(ZTScaleValue(200))
            $0.left.equalTo(ZTScaleValue(100))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(100))
        }
        
        btn.snp.makeConstraints {
            $0.bottom.equalTo(-ZTScaleValue(200))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(100))
            $0.height.equalTo(ZTScaleValue(50))
        }
    }
    
    @objc private func btnOnClick(){
        print("连接摄像头")
        stopCallback?()
        #if !(targetEnvironment(simulator))
        let vc = CameraViewController()
        vc.myUID = model.ID
        vc.mypwd = "888888"
        self.navigationController?.pushViewController(vc, animated: true)
        #endif
    }

}
