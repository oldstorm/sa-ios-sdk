//
//  HomekitCodeController.swift
//  ZhiTing
//
//  Created by iMac on 2021/5/27.
//

import UIKit

class HomekitCodeController: BaseViewController {
    var removeCallback: (() -> ())?
    
    var device: DiscoverDeviceModel?
    
    var area = Area()
    
    /// 设备详情地址
    var deviceUrl = ""
    
    var device_id = -1

    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.homekit_icon)
    }

    private lazy var tipsLabel1 = Label().then {
        $0.font = .font(size: ZTScaleValue(20), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "输入HomeKit设置代码".localizedString
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var tipsLabel2 = Label().then {
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "请在包装或配件上查找8位设置代码".localizedString
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var inputCodeView = HomekitInputView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Homekit设置代码".localizedString
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.inputCodeView.startEditing()
        }

    }
    
    override func setupViews() {
        view.addSubview(icon)
        view.addSubview(tipsLabel1)
        view.addSubview(tipsLabel2)
        view.addSubview(inputCodeView)
        
        inputCodeView.completeCallback = { [weak self] code in
            guard let self = self else { return }
            self.sendHomekitCode(code: code)

        }

    }

    override func setupConstraints() {
        icon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(Screen.k_nav_height + ZTScaleValue(43))
            $0.height.equalTo(ZTScaleValue(65))
            $0.width.equalTo(ZTScaleValue(140))
        }
        
        tipsLabel1.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(icon.snp.bottom).offset(ZTScaleValue(14))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        tipsLabel2.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(tipsLabel1.snp.bottom).offset(ZTScaleValue(10.5))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        inputCodeView.snp.makeConstraints {
            $0.top.equalTo(tipsLabel2.snp.bottom).offset(ZTScaleValue(40))
            $0.left.right.equalToSuperview()
        }


    }
    
    private func sendHomekitCode(code: String) {
        let vc = ConnectDeviceViewController()
        vc.homekitCode = code
        vc.area = self.area
        vc.device = self.device
        vc.homekitCodeFailCallback = { [weak self] in
            guard let self = self else { return }
            self.inputCodeView.clearCode(warning: "设置代码不正确,请重新输入!".localizedString)
        }
        inputCodeView.clearCode(warning: "")
        view.endEditing(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
}

