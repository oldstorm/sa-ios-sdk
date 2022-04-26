//
//  ProEditionSettingViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/19.
//

import UIKit


class ProEditionSettingViewController: BaseViewController {
    private lazy var header = UIView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 40)).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        let label = Label()
        label.text = "可用以下用户名和密码登录网页专业版，局域网下可查看专业版地址".localizedString
        label.font = .font(size: 12, type: .regular)
        label.textColor = .custom(.gray_94a5be)
        label.lineBreakMode = .byTruncatingTail
        
        $0.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(ZTScaleValue(15))
        }
    }

    private lazy var userNameCell = ValueDetailCell().then {
        $0.title.text = "用户名".localizedString
    }
    
    private lazy var pwdCell = ValueDetailCell().then {
        $0.title.text = "密码".localizedString
    }
    
    private var changePwdTextFieldAlertView: TextFieldAlertView?
    private var changeUserNameTextFieldAlertView: TextFieldAlertView?


    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = UITableView.automaticDimension
        $0.isScrollEnabled = false
        $0.tableHeaderView = header
    }
    
    private lazy var urlPathCoverView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var urlPathLabel = Label().then {
        $0.text = "专业版地址".localizedString
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.lineBreakMode = .byTruncatingTail
    }
    //SA地址
    private lazy var urlPathDetailLabel = Label().then {
        $0.text = AuthManager.shared.currentArea.sa_lan_address
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.lineBreakMode = .byTruncatingTail
    }
    //提示
    private lazy var urlPathTipsLabel = Label().then {
        $0.text = "ip地址可能会因为重新接入网络等原因改变，如果如无法访问请刷新页面获取最新地址".localizedString
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
    }
    
    private lazy var copyBtn = Button().then {
        $0.setTitle("复制", for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
    }
    
    private lazy var saveButton = LoadingButton(title: "保存".localizedString)
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.shadowImage = UIImage()
        
        navigationBarAppearance.backgroundColor = UIColor.custom(.black_3f4663)
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.font(size: 18, type: .bold), NSAttributedString.Key.foregroundColor: UIColor.custom(.white_ffffff)]
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance

        navigationItem.title = "设置".localizedString
        navBackBtn.setImage(.assets(.nav_back_white), for: .normal)
        
        requestNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(urlPathCoverView)
        urlPathCoverView.addSubview(urlPathLabel)
        urlPathCoverView.addSubview(urlPathDetailLabel)
        urlPathCoverView.addSubview(copyBtn)
        urlPathCoverView.addSubview(urlPathTipsLabel)
        
        AuthManager.shared.checkIfSAAvailable(addr: AuthManager.shared.currentArea.sa_lan_address ?? "" ) { [weak self] available in
            guard let self = self else { return }
            self.urlPathCoverView.isHidden = !available
        }
        
        copyBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            UIPasteboard.general.string = self.urlPathDetailLabel.text
            self.showToast(string: "复制成功")
        }
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(145))
        }
    
        urlPathCoverView.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(ZTScaleValue(20))
            $0.left.right.equalToSuperview()
        }
        
        urlPathLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(20))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(100))

        }
        
        urlPathDetailLabel.snp.makeConstraints {
            $0.centerY.equalTo(urlPathLabel)
            $0.right.equalTo(copyBtn.snp.left).offset(-ZTScaleValue(10))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(200))
        }
        
        copyBtn.snp.makeConstraints {
            $0.centerY.equalTo(urlPathLabel)
            $0.right.equalToSuperview().offset(-ZTScaleValue(15))
            $0.width.equalTo(50)
            $0.height.equalTo(20)
        }
        urlPathTipsLabel.snp.makeConstraints {
            $0.top.equalTo(urlPathLabel.snp.bottom).offset(ZTScaleValue(10))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(-ZTScaleValue(15))
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(10))
        }
    }
    
    private func requestNetwork() {
        self.tableView.isUserInteractionEnabled = false
        ApiServiceManager.shared.userDetail(area: authManager.currentArea, id: authManager.currentArea.sa_user_id) { [weak self] (response) in
            guard let self = self else { return }
            if response.is_set_password {
                if !(self.authManager.currentArea.setAccount ?? false) {
                    self.authManager.currentArea.setAccount = true
                    AreaCache.cacheArea(areaCache: self.authManager.currentArea.toAreaCache())
                }
                
                self.userNameCell.valueLabel.text = response.account_name
                self.pwdCell.valueLabel.text = "已设置".localizedString
                self.tableView.isUserInteractionEnabled = true
            } else {
                self.userNameCell.valueLabel.text = "未设置".localizedString
                self.pwdCell.valueLabel.text = "未设置".localizedString
                self.tableView.isUserInteractionEnabled = true
            }

            self.tableView.reloadData()

        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            if self.authManager.currentArea.setAccount ?? false {
                self.userNameCell.valueLabel.text = self.authManager.currentArea.accountName
                self.pwdCell.valueLabel.text = "已设置".localizedString
                self.tableView.isUserInteractionEnabled = true
            } else {
                self.userNameCell.valueLabel.text = "未设置".localizedString
                self.pwdCell.valueLabel.text = "未设置".localizedString
                self.tableView.isUserInteractionEnabled = true
            }
            
            self.tableView.reloadData()
        }

    }

}

extension ProEditionSettingViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.authManager.currentArea.setAccount ?? false {//已设置
            //进入修改页面
            if indexPath.row == 1 {
                self.changePwdTextFieldAlertView = TextFieldAlertView.show(title: "修改密码", textFieldType: .changePwd, changePwdCallback: {[weak self] oldPWd, newPwd in
                    guard let self = self else { return }
                    print("点击修改密码")
                    self.changePwdTextFieldAlertView?.isSureBtnLoading = true
                    ApiServiceManager.shared.editSAUser(user_id: AuthManager.shared.currentArea.sa_user_id, account_name: "", password: newPwd, old_password: oldPWd) { [weak self] response in
                        guard let self = self else { return }
                        self.changePwdTextFieldAlertView?.isSureBtnLoading = false
                        self.changePwdTextFieldAlertView?.removeFromSuperview()
                        self.showToast(string: "修改密码成功")
                        print("修改密码成功")
                        self.requestNetwork()
                    } failureCallback: {[weak self] code, err in
                        guard let self = self else { return }
                        self.changePwdTextFieldAlertView?.isSureBtnLoading = false
                        self.showToast(string: err)
                    }
                }, changeUserNameCallback: nil, cancelCallback: {
                    print("取消修改密码")
                }, removeWithSure: false)

            }else{
                
                self.changeUserNameTextFieldAlertView = TextFieldAlertView.show(title: "修改用户名", textFieldType: .changeUserName(userName: self.userNameCell.valueLabel.text ?? ""), changePwdCallback: nil, changeUserNameCallback: { userName in
                    print("点击修改用户名")
                    self.changeUserNameTextFieldAlertView?.isSureBtnLoading = true
                    ApiServiceManager.shared.editSAUser(user_id: AuthManager.shared.currentArea.sa_user_id, account_name: userName, password: "", old_password: "") {[weak self] response in
                        guard let self = self else { return }
                        self.changeUserNameTextFieldAlertView?.isSureBtnLoading = false
                        self.changeUserNameTextFieldAlertView?.removeFromSuperview()
                        print("修改用户名成功")
                        self.showToast(string: "保存成功")
                        self.requestNetwork()
                    } failureCallback: {[weak self] code, err in
                        guard let self = self else { return }
                        self.changeUserNameTextFieldAlertView?.isSureBtnLoading = false
                        self.showToast(string: err)
                    }
                }, cancelCallback: {
                    print("取消修改用户名")
                }, removeWithSure: false)
               
            }
        }else{//未设置
            let vc = SetProAccountViewController()
            navigationController?.pushViewController(vc, animated: true)
        }

        
    }
    
}




