//
//  SetProAccountViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/8.
//
import RealmSwift
import UIKit

class SetProAccountViewController: BaseViewController {
    private lazy var userNameCell = SetProAccountCell().then {
        $0.label.text = "用户名".localizedString
        $0.placeHolder = "请输入用户名".localizedString
    }
    
    private lazy var pwdCell = SetProAccountCell().then {
        $0.label.text = "密码".localizedString
        $0.placeHolder = "请输入密码".localizedString
    }

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorColor = .custom(.gray_eeeeee)
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = 50
        $0.isScrollEnabled = false
    }
    
    private lazy var saveButton = LoadingButton(title: "保存".localizedString)
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "设置".localizedString
        navBackBtn.setImage(.assets(.nav_back_white), for: .normal)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.font(size: 18, type: .bold), NSAttributedString.Key.foregroundColor: UIColor.custom(.white_ffffff)]
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(saveButton)

        
        saveButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.saveClick()
        }
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(50)
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.equalTo(50)
        }
        
    }

}

extension SetProAccountViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return userNameCell
        } else {
            return pwdCell
        }
    }
    
}

extension SetProAccountViewController {
    
    private func saveClick() {
        guard let username = userNameCell.textField.text, let pwd = pwdCell.textField.text else { return }
        if username == "" {
            self.showToast(string: "请输入用户".localizedString)
            return
        }

        if pwd == "" {
            self.showToast(string: "请输入密码".localizedString)
            return
        }

        saveButton.buttonState = .waiting
        view.isUserInteractionEnabled = false

        ApiServiceManager.shared.editUser(user_id: authManager.currentArea.sa_user_id, account_name: username, password: pwd) { [weak self] response in
            guard let self = self else { return }
            let realm = try! Realm()

            try? realm.write {
                self.authManager.currentArea.setAccount = true
                self.authManager.currentArea.accountName = username
                if let saCache = realm.objects(AreaCache.self).filter("sa_user_token = '\(self.authManager.currentArea.sa_user_token)'").first {
                    saCache.setAccount = true
                    saCache.accountName = username
                }
            }
            
            
            self.saveButton.buttonState = .normal
            self.navigationController?.popViewController(animated: true)

        } failureCallback: { [weak self] (code, err) in
            self?.view.isUserInteractionEnabled = true
            self?.showToast(string: err)
            self?.saveButton.buttonState = .normal
        }

    }
    
}


