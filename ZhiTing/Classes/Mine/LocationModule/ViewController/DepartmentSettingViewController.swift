//
//  DepartmentSettingViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/16.
//

import UIKit

class DepartmentSettingViewController: BaseViewController {
    var area: Area?
    var department: Location?
    
    private lazy var requestQueue = DispatchQueue(label: "ZhiTing.DepartmentSettingViewController.requestQueue")
    
    private var originInfo = ""
    
    private lazy var saveButton = DoneButton(frame: CGRect(x: 0, y: 0, width: 50, height: 25)).then {
        $0.setTitle("保存".localizedString, for: .normal)
        $0.isEnhanceClick = true
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.save()
        }
        
    }
    
    private lazy var header = DepartmentSettingHeader().then {
        $0.textField.delegate = self
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.dataSource = self
        $0.delegate = self
        $0.separatorStyle = .none
        $0.alwaysBounceVertical = false
        $0.rowHeight = 50
    }
    
    private lazy var managerCell = DepartmentSettingCell()
    
    private var tipsAlert: TipsAlertView?
    
    private lazy var selectManagerAlert = DepartmentSelectManagerAlert()
    
    private lazy var deleteButton = ImageTitleButton(frame: .zero, icon: nil, title: "删除部门".localizedString, titleColor: UIColor.custom(.black_333333), backgroundColor: UIColor.custom(.white_ffffff)).then {
        $0.clickCallBack = { [weak self] in
            guard let self = self else { return }
            
            let str0 = getCurrentLanguage() == .chinese ? "确定删除该部门吗?\n\n" : "Are you sure to delete it?\n\n"
            let str1 = getCurrentLanguage() == .chinese ? "删除部门，不会把成员删除" : "It will just delete the department, members of it will be reserved."
            var attributedString = NSMutableAttributedString(
                string: str0,
                attributes: [
                    NSAttributedString.Key.font : UIFont.font(size: ZTScaleValue(14), type: .bold),
                    NSAttributedString.Key.foregroundColor : UIColor.custom(.black_3f4663)
                ]
            )
            
            let attributedString2 = NSMutableAttributedString(
                string: str1,
                attributes: [
                    NSAttributedString.Key.font : UIFont.font(size: ZTScaleValue(12), type: .bold),
                    NSAttributedString.Key.foregroundColor : UIColor.custom(.black_3f4663)
                ]
            )
            
            attributedString.append(attributedString2)
            
            self.tipsAlert = TipsAlertView.show(attributedString: attributedString, sureCallback: { [weak self] in
                guard let self = self else { return }
                self.deleteDeparment()
            }, removeWithSure: false)
            
            
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "部门设置".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestNetwork()
    }

    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(deleteButton)
        
        
        selectManagerAlert.selectCallback = { [weak self] user in
            guard let self = self else { return }
            self.managerCell.member = user
        }
        
    }
    
    override func setupConstraints() {
        header.snp.makeConstraints {
            $0.right.left.equalToSuperview()
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            
        }
        
        deleteButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(deleteButton.snp.top).offset(-18.5)
        }
    }
    
    override func navPop() {
        let ifAfterEdit = department?.name != header.textField.text

        if ifAfterEdit {
            TipsAlertView.show(message: "信息未保存,是否退出".localizedString) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let ifAfterEdit = department?.name != header.textField.text

        if ifAfterEdit {
            TipsAlertView.show(message: "信息未保存,是否退出".localizedString) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return false
        } else {
            return true
        }
        
    }
    
}


extension DepartmentSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return managerCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        SceneDelegate.shared.window?.addSubview(selectManagerAlert)
        
    }
}



extension DepartmentSettingViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        if let point = touches.first?.location(in: tableView),
           tableView.point(inside: point, with: event) {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
        
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.count > 30 {
            textField.text = String(text.prefix(30))
        }
        
        
        
        if textField.text?.replacingOccurrences(of: " ", with: "").count == 0 {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = (text.count > 0)
        }
        
    }
}

// MARK: - NetworkRequest
extension DepartmentSettingViewController {
    
    private func requestNetwork() {
        guard let area = self.area, let department = self.department else { return }
        /// cache
        if !area.is_bind_sa && !UserManager.shared.isLogin {
            self.header.textField.text = department.name
            self.deleteButton.isHidden = false
            return
        }

        showLoadingView()
        requestQueue.async { [weak self] in
            guard let self = self else { return }
            let sema = DispatchSemaphore(value: 0)
            
            sema.signal()
            
            sema.wait()
            /// 获取用户权限
            ApiServiceManager.shared.rolesPermissions(area: area, user_id: area.sa_user_id) { [weak self] response in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.deleteButton.isHidden = !response.permissions.update_department
                    sema.signal()
                }
                
                
            } failureCallback: { code, err in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.deleteButton.isHidden = true
                    sema.signal()
                }
                
            }
            
            sema.wait()
            /// 获取部门详情
            ApiServiceManager.shared.departmentDetail(area: area, id: department.id) { [weak self] response in
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.header.textField.text = response.name
                    self.selectManagerAlert.users = response.users
                    self.selectManagerAlert.selectedUser = response.users.first(where: { $0.is_manager == true })
                    self.managerCell.member = response.users.first(where: { $0.is_manager == true })
                    sema.signal()
                }
            } failureCallback: { [weak self] code, err in
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.header.textField.text = department.name
                    sema.signal()
                }
            }
            
            
            sema.wait()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.hideLoadingView()
                sema.signal()
            }
            
        }
        
        
    }
    
    
    
    private func deleteDeparment() {
        guard let area = self.area, let department = self.department else { return }
        
        /// cache
        if !area.is_bind_sa && !UserManager.shared.isLogin {
            LocationCache.deleteLocation(location_id: department.id, sa_token: area.sa_user_token)
            showToast(string: "删除成功".localizedString)
            navigationController?.popViewController(animated: true)
            return
        }
        
        tipsAlert?.isSureBtnLoading = true
        ApiServiceManager.shared.deleteDepartment(area: area, id: department.id) { [weak self] (response) in
            guard let self = self else { return }
            LocationCache.deleteLocation(location_id: department.id, sa_token: area.sa_user_token)
            self.showToast(string: "删除成功".localizedString)
            self.tipsAlert?.isSureBtnLoading = false
            self.tipsAlert?.removeFromSuperview()
            if let count = self.navigationController?.viewControllers.count, count - 2 > 0 {
                self.navigationController?.viewControllers.remove(at: count - 2)
            }
            self.navigationController?.popViewController(animated: true)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.tipsAlert?.isSureBtnLoading = false
        }
        
    }
    
    private func save() {
        guard let area = self.area,
              let department = self.department,
              let name = header.textField.text
        else {
            return
        }
        
        /// cache
        if !area.is_bind_sa && !UserManager.shared.isLogin {
            LocationCache.changeLocationName(location_id: department.id, name: name, sa_token: area.sa_user_token)
            showToast(string: "保存成功".localizedString)
            navigationController?.popViewController(animated: true)
            return
        }

        let manager_id = selectManagerAlert.selectedUser?.user_id ?? 0
        showLoadingView()
        ApiServiceManager.shared.updateDeparment(area: area, id: department.id, name: name, manager_id: manager_id) { [weak self] (response) in
            guard let self = self else { return }
            self.department?.name = name
            self.hideLoadingView()
            self.showToast(string: "保存成功".localizedString)
            self.navigationController?.popViewController(animated: true)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.hideLoadingView()
        }

    }
    
}
