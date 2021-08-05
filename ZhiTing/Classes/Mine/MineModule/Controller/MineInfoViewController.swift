//
//  MineInfoViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/23.
//

import UIKit
import RealmSwift


class MineInfoViewController: BaseViewController {
    var cellTypeArray = [MineInfoCell.InfoType]()
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.separatorStyle = .none
        $0.rowHeight = 60
        $0.register(MineInfoCell.self, forCellReuseIdentifier: MineInfoCell.reusableIdentifier)
    }
    
    private lazy var logoutButton = ImageTitleButton(frame: .zero, icon: nil, title: "退出登录".localizedString, titleColor: .custom(.red_fe0000), backgroundColor: .custom(.white_ffffff))

    private var changeNickNameAlertView: InputAlertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "个人信息".localizedString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(logoutButton)
        
        
        logoutButton.clickCallBack = {
            TipsAlertView.show(message: "是否退出登录？".localizedString) { [weak self] in
                self?.logout()
            }

        }
        
        if authManager.isLogin {
            logoutButton.isHidden = false
            cellTypeArray = [.avatar, .nickName, .phone]

        } else {
            logoutButton.isHidden = true
            cellTypeArray = [.avatar, .nickName]
        }
        
        tableView.reloadData()
    }

    override func setupConstraints() {
        logoutButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
        }
        
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(logoutButton.snp.top).offset(-5)
        }
    }
    
    private func logout() {
        AppDelegate.shared.appDependency.authManager.logOut { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
}


extension MineInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MineInfoCell.reusableIdentifier, for: indexPath) as! MineInfoCell
        cell.infoType = cellTypeArray[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.avatar.setImage(urlString: authManager.currentUser.icon_url, placeHolder: .assets(.default_avatar))
        case 1:
            cell.valueLabel.text = authManager.currentUser.nickname
        case 2:
            cell.valueLabel.text = authManager.currentUser.phone
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            break
        case 1:
            let alert = InputAlertView(labelText: "修改昵称".localizedString, placeHolder: "请输入昵称".localizedString) { [weak self] text in
                self?.changeNickname(text: text)
            }
            alert.textField.text = authManager.currentUser.nickname
            self.changeNickNameAlertView = alert
            
            SceneDelegate.shared.window?.addSubview(alert)
        default:
            break
        }
    }
    
}

extension MineInfoViewController {
    private func changeNickname(text: String) {
        if text.count < 6 {
            showToast(string: "昵称不能少于6位")
            return
        }
        
        if text.count > 20 {
            showToast(string: "昵称不能大于20位")
            return
        }
        
        authManager.currentUser.nickname = text
        let realm = try! Realm()
        let sas = realm.objects(UserCache.self)
        try? realm.write {
            sas.forEach { $0.nickname = text }
        }
        
        changeNickNameAlertView?.removeFromSuperview()
        tableView.reloadData()
        
        let user_id = authManager.currentArea.sa_user_id
        ApiServiceManager.shared.editUser(user_id: user_id, nickname: text, account_name: "", password: "", successCallback: nil, failureCallback: nil)
         
        if authManager.isLogin {
            let user_id = authManager.currentUser.user_id
            ApiServiceManager.shared.editCloudUser(user_id: user_id, successCallback: nil, failureCallback: nil)
        }
        
        showToast(string: "保存成功".localizedString)
        

    }
}
