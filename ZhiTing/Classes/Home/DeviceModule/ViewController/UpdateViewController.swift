//
//  UpdateViewController.swift
//  ZhiTing
//
//  Created by macbook on 2021/10/26.
//

import UIKit

enum UpdateType {
    case software
    case firmware
}

class UpdateViewController: BaseViewController {
    
    var updateType = UpdateType.software
    
    var softwareModel = SoftwareUpdateResponse()
    
    lazy var bgImg = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.software_update)
    }
    
    private var checkUpdateAlertView: CheckUpdateAlertView?
    
    private lazy var versionLabel = Label().then {
        $0.text = "当前版本：2.0.6-0054841"
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.numberOfLines = 0
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
    }
    
    private lazy var checkUpdateBtn = CustomButton(buttonType:
                                                .centerTitleAndLoading(normalModel:
                                                                        .init(
                                                                            title: "检查更新".localizedString,
                                                                            titleColor: .custom(.white_ffffff),
                                                                            font: .font(size: ZTScaleValue(14), type: .bold),
                                                                            bagroundColor: .custom(.blue_2da3f6)
                                                                        )
                                                )).then {
                                                    $0.layer.cornerRadius = ZTScaleValue(10)
                                                    $0.addTarget(self, action: #selector(onClickCheck), for: .touchUpInside)
                                                }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch updateType {
        case .software:
            navigationItem.title = "软件升级".localizedString
        case .firmware:
            navigationItem.title = "固件升级".localizedString
        }
        checkVersionData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupViews() {
        view.addSubview(bgImg)
        view.addSubview(versionLabel)
        view.addSubview(checkUpdateBtn)
    }
    
    override func setupConstraints() {
        bgImg.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(54)+Screen.k_nav_height)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(121.5))
            $0.height.equalTo(ZTScaleValue(109))
        }
        
        versionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bgImg.snp.bottom).offset(ZTScaleValue(31.5))
            $0.left.right.equalToSuperview()
        }
        
        checkUpdateBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(40))
            $0.height.equalTo(ZTScaleValue(50))
            $0.width.equalTo(ZTScaleValue(300))
            
        }
    }
    
    private func checkVersionData(){
        showLoadingView()
        switch updateType {
        case .software:
            
            ApiServiceManager.shared.checkSABindState(url: authManager.currentArea.sa_lan_address ?? "http://") { [weak self] (response) in
                guard let self = self else { return }
                self.hideLoadingView()
                self.versionLabel.text =  "当前版本：\(response.version)"
            }
            
        case .firmware:
            break
        }


    }
    
   @objc private func onClickCheck(){
        print("点击检查升级")
       showLoadingView()
       
       ApiServiceManager.shared.checkSoftwareUpdate(area: authManager.currentArea) {[weak self] response in
           guard let self = self else {return}
           self.hideLoadingView()
           self.softwareModel = response
           if !self.softwareModel.latest_version.isEmpty && self.softwareModel.latest_version == self.softwareModel.version {
               self.showToast(string: "当前已是最新版本")
           }else{
               self.checkUpdateAlertView = CheckUpdateAlertView.show(softwareModel: self.softwareModel, checkCallback: { [weak self] isUpdate in
                   guard let self = self else {return}
                   if isUpdate {
                       ApiServiceManager.shared.updateSoftware(area: self.authManager.currentArea, version: self.softwareModel.latest_version) { [weak self] _ in
                           guard let self = self else {return}
                           self.showToast(string: "更新成功")
                           self.versionLabel.text =  "当前版本：\(self.softwareModel.latest_version)"
                       } failureCallback: { code, error in
                           self.showToast(string: "更新失败")
                       }
                   }
               })
           }
       } failureCallback: { code, error in
           self.showToast(string: error)
           self.hideLoadingView()
       }
       
       

    }
}
