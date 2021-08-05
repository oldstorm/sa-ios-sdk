//
//  BaseViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit
import Moya
import Combine
import Toast_Swift
import JXSegmentedView

// MARK: - BaseViewController
class BaseViewController: UIViewController {
    lazy var cancellables = [AnyCancellable]()
    
    public var disableSideSliding = false

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("\(String(describing: self.classForCoder)) deinit.")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }

    lazy var navBackBtn: Button = {
        let btn = Button()
        btn.frame.size = CGSize.init(width: 30, height: 30)
        btn.setImage(.assets(.navigation_back), for: .normal)
        btn.addTarget(self, action: #selector(navPop), for: .touchUpInside)
        btn.contentHorizontalAlignment = .left
        return btn
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .custom(.white_ffffff)
        setupViews()
        setupConstraints()
        setupSubscriptions()

        networkStateManager.networkStatusPublisher
            .sink { [weak self] state in
                guard let self = self else { return }
                if state == .reachable {
                    DispatchQueue.main.async {
                        self.reloadWhenNetworkChange()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func setupViews() {}
    
    func setupConstraints() {}
    
    func setupSubscriptions() {}

}

// MARK: - AppDependcy stuff
extension BaseViewController {
    var dependency: AppDependency {
        return (UIApplication.shared.delegate as! AppDelegate).appDependency
          }
    
    var apiService: MoyaProvider<ApiService> {
           return dependency.apiService
       }
    
    var websocket: ZTWebSocket {
        return dependency.websocket
    }
    
    var authManager: AuthManager {
        return dependency.authManager
    }
    
    var networkStateManager: NetworkStateManager {
        return dependency.networkManager
    }
    
    
}

// MARK: - Navigation stuff
extension BaseViewController: UIGestureRecognizerDelegate {
    private func setupNavigation() {
        if !(self is HomeSubViewController) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        if navigationController?.children.first != self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navBackBtn)
        }
        
        if self is DeviceWebViewController {
            return
        }
        navigationController?.navigationBar.backgroundColor = .custom(.white_ffffff)
        navigationController?.navigationBar.tintColor = .custom(.white_ffffff)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.font(size: 18, type: .bold), NSAttributedString.Key.foregroundColor: UIColor.custom(.black_3f4663)]
        
        
    }

    @objc func navPop() {
        navigationController?.popViewController(animated: true)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !disableSideSliding
    }
    
}

// MARK: - Toast
extension BaseViewController {
    func showToast(string: String) {
        SceneDelegate.shared.window?.makeToast(string)
    }
}


extension BaseViewController {
    
    /// 网络变化时调用刷新请求
    func reloadWhenNetworkChange() {
        #if DEBUG
        UserDefaults.standard.setValue(true, forKey: "NetWorkState")
        #else
        
        #endif
        
        
    }
}
