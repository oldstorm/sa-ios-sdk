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
    
    lazy var loadingView = LoadingView().then {
        $0.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: view.bounds.height - Screen.k_nav_height)
    }

    lazy var navBackBtn: Button = {
        let btn = Button()
        btn.frame.size = CGSize.init(width: 30, height: 30)
        btn.setImage(.assets(.navigation_back), for: .normal)
        btn.addTarget(self, action: #selector(navPop), for: .touchUpInside)
        btn.contentHorizontalAlignment = .left
        return btn
    }()
    
    lazy var navCloseBtn: Button = {
        let btn = Button()
        btn.frame.size = CGSize.init(width: 30, height: 30)
        btn.imageView?.contentMode = .scaleToFill
        btn.setImage(.assets(.close_button), for: .normal)
        btn.addTarget(self, action: #selector(navClose), for: .touchUpInside)
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
        return AuthManager.shared
    }
    
    var networkStateManager: NetworkStateManager {
        return NetworkStateManager.shared
    }
    
    var appPreference: AppPreference {
        return dependency.appPreference
    }
    
    
}

// MARK: - Navigation stuff
extension BaseViewController: UIGestureRecognizerDelegate {
    private func setupNavigation() {
        if !(self is HomeSubViewController || self is SceneSubViewController || self is BrandSystemViewController || self is BrandCreationViewController) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }

        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        if navigationController?.children.first != self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navBackBtn)
        }
        

        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.shadowImage = UIImage()
        
        navigationBarAppearance.backgroundColor = .custom(.white_ffffff)
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.font(size: 18, type: .bold), NSAttributedString.Key.foregroundColor: UIColor.custom(.black_3f4663)]
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance

        

    
        
        
    }

    @objc func navPop() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func navClose() {
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
    
    func showLoadingView() {
        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        loadingView.show()
    }
    
    func hideLoadingView(){
         loadingView.hide()
         loadingView.removeFromSuperview()
     }
}


extension BaseViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
        
    }
}
