//
//  MineViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit
import RealmSwift

class MineViewController: BaseViewController {
    private lazy var header = MineHeaderView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: ZTScaleValue(100) + Screen.statusBarHeight))

    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.estimatedSectionHeaderHeight = 10
        $0.estimatedSectionFooterHeight = 0
        $0.separatorStyle = .none
        $0.tableHeaderView = header
        $0.register(MineViewCell.self, forCellReuseIdentifier: MineViewCell.reusableIdentifier)
        $0.alwaysBounceVertical = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        requestNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(tableView)
        
        header.infoCallback = { [weak self] in
            let vc = MineInfoViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        header.scanBtn.clickCallBack = { [weak self] _ in
            let vc = ScanQRCodeViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func setupSubscriptions() {
        authManager.roleRefreshPublisher
            .sink {  [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.statusBarHeight)
            $0.left.right.bottom.equalToSuperview()
        }
    }
}

extension MineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .custom(.gray_f6f8fd)
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MineViewCell.reusableIdentifier, for: indexPath) as! MineViewCell
        switch indexPath.row {
        case 0:
            cell.title.text = "家庭/公司".localizedString
            cell.icon.image = .assets(.icon_family_brand)
        case 1:
            cell.title.text = "支持品牌".localizedString
            cell.icon.image = .assets(.icon_brand)
        case 2:
            if !authManager.isSAEnviroment {
                cell.isUserInteractionEnabled = false
                cell.contentView.alpha = 0.5
            } else {
                cell.isUserInteractionEnabled = true
                cell.contentView.alpha = 1
            }
            cell.title.text = "第三方平台".localizedString
            cell.icon.image = .assets(.icon_thirdParty)
        case 3:
            if !authManager.isSAEnviroment {
                cell.isUserInteractionEnabled = false
                cell.contentView.alpha = 0.5
            } else {
                cell.isUserInteractionEnabled = true
                cell.contentView.alpha = 1
            }
            cell.title.text = "专业版".localizedString
            cell.icon.image = .assets(.icon_professional)
        default:
            break
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let vc = AreaListViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = BrandListViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = WKWebViewController(link: "http://\(authManager.currentSA.ip_address)/sa/#/third-platform")
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = ProEditionViewController(link: "http://\(authManager.currentSA.ip_address)/sa/#/")
            let nav = BaseProNavigationViewController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        default:
            break
        }

    }
    
    func requestNetwork() {
        if authManager.isSAEnviroment || authManager.currentArea.sa_token.contains("unbind") {
            header.scanBtn.isHidden = false
        } else {
            header.scanBtn.isHidden = true
        }

        apiService.requestModel(.userDetail(id: authManager.currentSA.user_id), modelType: User.self) { [weak self] (response) in
            guard let self = self else { return }
            self.header.avatar.setImage(urlString: response.icon_url, placeHolder: .assets(.default_avatar))
            self.header.nickNameLabel.text = response.nickname
            self.tableView.reloadData()
            let realm = try! Realm()
            try? realm.write {
                self.authManager.currentSA.nickname = response.nickname
            }
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.header.avatar.setImage(urlString: self.authManager.currentUser.icon_url, placeHolder: .assets(.default_avatar))
            self.header.nickNameLabel.text = self.authManager.currentSA.nickname
            self.tableView.reloadData()
        }
    }
}
