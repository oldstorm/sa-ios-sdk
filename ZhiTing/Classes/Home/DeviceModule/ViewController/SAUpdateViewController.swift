//
//  SAUpdateViewController.swift
//  ZhiTing
//
//  Created by macbook on 2021/10/26.
//

import UIKit

enum SAUpdateType {
    case software
    case firmware
}

class SAUpdateViewController: BaseViewController {
    var currentVersion = ""

    var updateType = SAUpdateType.software
    
    lazy var bgImg = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.software_update)
    }
    
    private var checkUpdateAlertView: CheckUpdateAlertView?
    
    private lazy var versionLabel = Label().then {
        $0.text = ""
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
                                                                            backgroundColor: .custom(.blue_2da3f6)
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
            ApiServiceManager.shared.getSoftwareVersion(area: authManager.currentArea) { [weak self] response in
                guard let self = self else { return }
                self.versionLabel.text = "当前版本：\(response.version)"
                self.currentVersion = response.version
                self.hideLoadingView()
                self.checkUpdateBtn.backgroundColor = .custom(.blue_2da3f6)
                self.checkUpdateBtn.isEnabled = true

            } failureCallback: { [weak self] code, err in
                self?.hideLoadingView()
                self?.showToast(string: err)
                self?.currentVersion = ""
                self?.versionLabel.text = "当前版本：获取失败"
                self?.checkUpdateBtn.backgroundColor = .custom(.gray_eeeeee)
                self?.checkUpdateBtn.isEnabled = false
            }
            
        case .firmware:
            ApiServiceManager.shared.getFirmwareVersion(area: authManager.currentArea) { [weak self] response in
                guard let self = self else { return }
                self.versionLabel.text = "当前版本：\(response.version)"
                self.currentVersion = response.version
                self.hideLoadingView()
                self.checkUpdateBtn.backgroundColor = .custom(.blue_2da3f6)
                self.checkUpdateBtn.isEnabled = true

            } failureCallback: { [weak self] code, err in
                self?.hideLoadingView()
                self?.showToast(string: err)
                self?.currentVersion = ""
                self?.versionLabel.text = "当前版本：获取失败"
                self?.checkUpdateBtn.backgroundColor = .custom(.gray_eeeeee)
                self?.checkUpdateBtn.isEnabled = false
            }

        }


    }
    
   @objc private func onClickCheck(){
        print("点击检查升级")
       switch updateType {
       case .software:
           showLoadingView()
           ApiServiceManager.shared.getSoftwareLatestVersion(area: authManager.currentArea) { [weak self] response in
               guard let self = self else {return}
               self.hideLoadingView()

               if self.currentVersion != "" && response.latest_version == self.currentVersion {
                   self.showToast(string: "当前已是最新版本")
               } else {
                   self.checkUpdateAlertView = CheckUpdateAlertView.show(version: response.latest_version, checkCallback: { [weak self] isUpdate in
                       guard let self = self else {return}
                       if isUpdate {
                           GlobalLoadingView.show()
                           ApiServiceManager.shared.updateSoftware(area: self.authManager.currentArea, version: response.latest_version) { [weak self] _ in
                               guard let self = self else {return}
                               GlobalLoadingView.hide()
                               self.showToast(string: "更新成功")
                               self.versionLabel.text =  "当前版本：\(response.latest_version)"
                               self.currentVersion = response.latest_version
                           } failureCallback: { [weak self] code, error in
                               GlobalLoadingView.hide()
                               self?.showToast(string: "更新失败")
                           }
                       }
                   })
               }
           } failureCallback: { code, error in
               self.showToast(string: error)
               self.hideLoadingView()
           }
           
       case .firmware:
           showLoadingView()
           ApiServiceManager.shared.getFirmwareLatestVersion(area: authManager.currentArea) { [weak self] response in
               guard let self = self else {return}
               self.hideLoadingView()
               if self.currentVersion != "" && self.currentVersion == response.latest_version {
                   self.showToast(string: "当前已是最新版本")
               } else {
                   self.checkUpdateAlertView = CheckUpdateAlertView.show(version: response.latest_version, checkCallback: { [weak self] isUpdate in
                       guard let self = self else {return}
                       if isUpdate {
                           GlobalLoadingView.show()
                           ApiServiceManager.shared.updateFirmware(area: self.authManager.currentArea, version: response.latest_version) { [weak self] _ in
                               guard let self = self else {return}
                               GlobalLoadingView.hide()
                               self.showToast(string: "更新成功")
                               self.versionLabel.text =  "当前版本：\(response.latest_version)"
                               self.currentVersion = response.latest_version
                           } failureCallback: { [weak self] code, error in
                               GlobalLoadingView.hide()
                               self?.showToast(string: "更新失败")
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
}
