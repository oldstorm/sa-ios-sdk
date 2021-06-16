//
//  MineInfoViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/23.
//

import UIKit
import RealmSwift


class MineInfoViewController: BaseViewController {
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
        
        logoutButton.isHidden = true
        logoutButton.clickCallBack = {
            TipsAlertView.show(message: "是否退出登录？".localizedString) {
                AppDelegate.shared.appDependency.authManager.logOut()
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
    
    
}


extension MineInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MineInfoCell.reusableIdentifier, for: indexPath) as! MineInfoCell
        switch indexPath.row {
        case 0:
            cell.infoType = .avatar
            cell.avatar.setImage(urlString: authManager.currentUser.icon_url, placeHolder: .assets(.default_avatar))
        case 1:
            cell.infoType = .nickName
            cell.valueLabel.text = authManager.currentSA.nickname
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
            alert.textField.text = authManager.currentSA.nickname
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
        
        let realm = try! Realm()
        let sas = realm.objects(SmartAssistantCache.self)
        try? realm.write {
            sas.forEach { $0.nickname = text }
        }
//        SmartAssistantCache.cacheSmartAssistants(sa: authManager.currentSA)
        changeNickNameAlertView?.removeFromSuperview()
        tableView.reloadData()
        
        apiService.requestModel(.editUser(user_id: authManager.currentSA.user_id, nickname: text, account_name: "", password: ""), modelType: BaseModel.self, successCallback: nil)
        
        showToast(string: "保存成功".localizedString)
        

    }
}
