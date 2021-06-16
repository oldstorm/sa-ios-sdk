//
//  BaseNavigationViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit

class BaseNavigationViewController: UINavigationController {
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !(viewController is HomeViewController || viewController is HomeSubViewController || viewController is MineViewController||viewController is SceneViewController) {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

class BaseProNavigationViewController: BaseNavigationViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
