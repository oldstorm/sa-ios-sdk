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
        
        if UserManager.shared.isLogin {
            logoutButton.isHidden = false
            cellTypeArray = [.avatar, .nickName, .phone, .account]

        } else {
            logoutButton.isHidden = true
            cellTypeArray = [.avatar, .nickName]
        }
        
        tableView.reloadData()
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
        AuthManager.shared.logOut { [weak self] in
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
        switch cellTypeArray[indexPath.row] {
        case .avatar:
            if let userAvatarData = UserManager.shared.userAvatarData {
                cell.avatar.image = UIImage(data: userAvatarData)
            } else {
                cell.avatar.setImage(urlString: UserManager.shared.currentUser.avatar_url, placeHolder: .assets(.default_avatar))
            }
            
        case .nickName:
            cell.valueLabel.text = UserManager.shared.currentUser.nickname
        case .phone:
            cell.valueLabel.text = UserManager.shared.currentUser.phone
        case .account:
            cell.valueLabel.text = " "
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch cellTypeArray[indexPath.row] {
        case .avatar:
            let vc = AvatarViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case .nickName:
            let alert = InputAlertView(labelText: "修改昵称".localizedString, placeHolder: "请输入昵称".localizedString) { [weak self] text in
                self?.changeNickname(text: text)
            }
            alert.textField.text = UserManager.shared.currentUser.nickname
            self.changeNickNameAlertView = alert
            
            SceneDelegate.shared.window?.addSubview(alert)
        case .phone:
            break
        case .account:
            let vc = AccountSettingViewcontroller()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension MineInfoViewController {
    private func changeNickname(text: String) {
        if text.count < 6 {
            showToast(string: "昵称不能少于6位".localizedString)
            return
        }
        
        if text.count > 20 {
            showToast(string: "昵称不能大于20位".localizedString)
            return
        }
        
        UserManager.shared.currentUser.nickname = text
        let realm = try! Realm()
        let sas = realm.objects(UserCache.self)
        try? realm.write {
            sas.forEach { $0.nickname = text }
        }
        
        changeNickNameAlertView?.removeFromSuperview()
        tableView.reloadData()
        
        let user_id = authManager.currentArea.sa_user_id
        ApiServiceManager.shared.editSAUser(user_id: user_id, nickname: text, successCallback: nil, failureCallback: nil)
         
        if UserManager.shared.isLogin {
            let user_id = UserManager.shared.currentUser.user_id
            ApiServiceManager.shared.editCloudUser(user_id: user_id, nickname: text, successCallback: nil, failureCallback: nil)
        }
        
        showToast(string: "保存成功".localizedString)
        

    }
}
