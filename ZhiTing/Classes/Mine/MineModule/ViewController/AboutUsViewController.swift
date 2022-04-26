//
//  AboutUsViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/6/15.
//

import UIKit

class AboutUsViewController: BaseViewController {
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.estimatedSectionHeaderHeight = 0
        $0.estimatedSectionFooterHeight = 0
        $0.separatorStyle = .none
        $0.register(ValueDetailCell.self, forCellReuseIdentifier: ValueDetailCell.reusableIdentifier)

    }
    
    lazy var aboutUsView = AboutUsView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "关于我们".localizedString
    }
    
    override func setupViews() {
        view.addSubview(aboutUsView)
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        aboutUsView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(aboutUsView.snp.bottom)
        }
    }
}


extension AboutUsViewController {
    class AboutUsView: UIView {
        private lazy var logo = ImageView().then {
            $0.image = .assets(.app_logo)
            $0.contentMode = .scaleAspectFit
        }
        
        private lazy var nameLabel = Label().then {
            $0.font = .font(size: ZTScaleValue(20), type: .bold)
            $0.text = "智汀家庭云".localizedString
            $0.textAlignment = .center
            $0.textColor = .custom(.black_3f4663)
        }
        
        private lazy var versionLabel = Label().then {
            $0.font = .font(size: ZTScaleValue(14), type: .bold)
            $0.textColor = .custom(.gray_94a5be)
            $0.text = "版本号:".localizedString
            $0.textAlignment = .center
        }
        
        private lazy var line = UIView().then {
            $0.backgroundColor = .custom(.gray_f6f8fd)
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .custom(.white_ffffff)
            addSubview(logo)
            addSubview(nameLabel)
            addSubview(versionLabel)
            addSubview(line)
            setupConstraints()
            
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                versionLabel.text = "版本号:".localizedString + " V\(appVersion)"
            }

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupConstraints() {
            logo.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().offset(ZTScaleValue(36) + Screen.k_nav_height)
                $0.width.height.equalTo(ZTScaleValue(120))
            }
            
            nameLabel.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(logo.snp.bottom).offset(ZTScaleValue(28))
            }
            
            versionLabel.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(nameLabel.snp.bottom).offset(ZTScaleValue(15))
            }
            
            line.snp.makeConstraints {
                $0.left.right.bottom.equalToSuperview()
                $0.height.equalTo(10)
                $0.top.equalTo(versionLabel.snp.bottom).offset(15)
            }
        }

    }
}


extension AboutUsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ValueDetailCell.reusableIdentifier, for: indexPath) as! ValueDetailCell

        if indexPath.row == 0 {
            cell.title.text = "用户协议".localizedString
        } else if indexPath.row == 1 {
            cell.title.text = "隐私政策".localizedString
        }else{
            cell.title.text = "检测更新".localizedString
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let vc = WKWebViewController(linkEnum: .userAgreement)
            vc.title = "用户协议".localizedString
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            let vc = WKWebViewController(linkEnum: .privacy)
            vc.title = "隐私政策".localizedString
            navigationController?.pushViewController(vc, animated: true)
        }else{//app检测更新
            //获取当前app版本信息
            let infoDic = Bundle.main.infoDictionary
            let appVersion = infoDic?["CFBundleShortVersionString"] as? String
            
            ApiServiceManager.shared.getAppVersions { response in
                let appNewVersion = response.max_app_version
                if ZTVersionTool.compareVersionIsNewBigger(nowVersion: appVersion ?? "1.0.0", newVersion: appNewVersion) {//当前版本并非最新版本
                    //app更新弹窗
                    AppUpdateAlertView.show(checkAppModel: response) {
                        //跳转去appstore
                        let str = "itms-apps://itunes.apple.com/app/id1591550488"
                        guard let url = URL(string: str) else { return }
                        let can = UIApplication.shared.canOpenURL(url)
                        if can {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:]) { (b) in
                                    print("打开结果: \(b)")
                                }
                            } else {
                                //iOS 10 以前
                                UIApplication.shared.openURL(url)
                            }
                        }
                    } cancelCallback: {
                        
                    }

                }else{
                    //进入app
                    self.showToast(string: "当前已是最新版本")
                }
            } failureCallback: { code, err in
                self.showToast(string: err)
            }


        }

    }
    
    
}
