//
//  TabbarController.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/2.
//

import UIKit

class TabbarController: UITabBarController {

    var homeVC: HomeViewController?
    var mineVC: MineViewController?
    var sceneVC: SceneViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpChilds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let url = AppDelegate.shared.appDependency.openUrlHandler.waitOpenUrl {
            AppDelegate.shared.appDependency.openUrlHandler.open(url: url)
        }

    }
}

extension TabbarController {
    private func setUpChilds() {
        tabBar.backgroundColor = .custom(.white_ffffff)
        tabBar.barTintColor = .custom(.white_ffffff)
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()

        let homeVC = HomeViewController()
        set(vc: homeVC, title: "家居".localizedString, image: .assets(.home), selImage: .assets(.home_sel))
        homeVC.tabBarItem.tag = 0
        let homeNav = BaseNavigationViewController(rootViewController: homeVC)
        self.homeVC = homeVC
        
        let sceneVC = SceneViewController()
        set(vc: sceneVC, title: "场景".localizedString, image: .assets(.scene), selImage: .assets(.scene_sel))
        sceneVC.tabBarItem.tag = 1
        let sceneNav = BaseNavigationViewController(rootViewController: sceneVC)
        self.sceneVC = sceneVC
        
        let mineVC = MineViewController()
        set(vc: mineVC, title: "我的".localizedString, image: .assets(.mine), selImage: .assets(.mine_sel))
        mineVC.tabBarItem.tag = 2
        let mineNav = BaseNavigationViewController(rootViewController: mineVC)
        self.mineVC = mineVC
        
        addChild(homeNav)
        addChild(sceneNav)
        addChild(mineNav)
    }

    private func set(vc: UIViewController, title: String, image: UIImage?, selImage: UIImage?) {
        vc.title = title

        let titleAttNormal = [NSAttributedString.Key.font: UIFont.font(size: 11),NSAttributedString.Key.foregroundColor: UIColor.custom(.gray_cfd6e0)]
        let titleAttSel = [NSAttributedString.Key.font: UIFont.font(size: 11),NSAttributedString.Key.foregroundColor: UIColor.custom(.blue_2da3f6)]

        vc.tabBarItem.setTitleTextAttributes(titleAttNormal, for: .normal)
        vc.tabBarItem.setTitleTextAttributes(titleAttSel, for: .selected)
        vc.tabBarItem.image = image?.withRenderingMode(.alwaysOriginal)
        vc.tabBarItem.selectedImage = selImage?.withRenderingMode(.alwaysOriginal)

    }
}
