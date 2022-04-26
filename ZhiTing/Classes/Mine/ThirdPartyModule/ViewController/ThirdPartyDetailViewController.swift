//
//  ThirdPartyDetailViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/10.
//

import UIKit

class ThirdPartyDetailViewController: WKWebViewController {
    let item: ThirdPartyCloudModel

    init(link: String, item: ThirdPartyCloudModel) {
        self.item = item
        super.init(link: link)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var alert: ThirdPartyUnbindAlert?
    
    private lazy var unbindButton = Button().then {
        $0.setTitle("解除授权".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.frame.size = CGSize(width: 55, height: 20)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.showAlert()
        }
        $0.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.unbindButton)
        getUserInfo()
    }
    
    
    private func showAlert() {
        if !UserManager.shared.isLogin { /// 需要先登录
            let vc = LoginViewController()
            vc.hidesBottomBarWhenPushed = true
            let nav = BaseNavigationViewController(rootViewController: vc)
            nav.modalPresentationStyle = .overFullScreen
            AppDelegate.shared.appDependency.tabbarController.present(nav, animated: true, completion: nil)
            return
        }

        alert = ThirdPartyUnbindAlert()
        alert?.tipsLabel.text = "解除授权后,“\(item.name)”无法继续获得你的相关信息或权限。"
        alert?.unbindBtnCallback = { [weak self] in
            guard let self = self else { return }
            self.unbindThirdPartyCloud()
        }

        SceneDelegate.shared.window?.addSubview(alert!)
    }

    private func unbindThirdPartyCloud() {
        alert?.isLoading = true
        ApiServiceManager.shared.unbindThirdPartyCloud(area: AuthManager.shared.currentArea, app_id: item.app_id) { [weak self] _ in
            guard let self = self else { return }
            self.alert?.isLoading = false
            self.alert?.removeFromSuperview()
            self.navigationController?.popViewController(animated: true)
            self.showToast(string: "解绑成功".localizedString)
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.showToast(string: err)
            self.alert?.isLoading = false
        }

    }
    
    private func getUserInfo() {
        if !UserManager.shared.isLogin && !AuthManager.shared.isSAEnviroment {
            return
        }

        ApiServiceManager.shared.userDetail(area: AuthManager.shared.currentArea, id: AuthManager.shared.currentArea.sa_user_id) { [weak self] user in
            if self?.item.is_bind == true && user.is_owner {
                self?.unbindButton.isHidden = false
            }
        } failureCallback: { code, err in
            
        }

    }

}
