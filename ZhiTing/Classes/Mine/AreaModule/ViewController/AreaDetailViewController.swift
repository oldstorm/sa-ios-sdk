//
//  AreaDetailViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/15.
//
import RealmSwift
import UIKit

class AreaDetailViewController: BaseViewController {

    var area: Area? {
        didSet {
            guard let area = area else { return }
            nameCell.valueLabel.text = area.name
            
        }
    }
    
    var locations = [Location]()
    
    var members = [User]()

    private lazy var nameCell = ValueDetailCell().then {
        $0.title.text = "名称".localizedString
        $0.valueLabel.text = " "
    }
    
    private lazy var qrCodeCell = ValueDetailCell().then {
        $0.title.text = "二维码".localizedString
        $0.valueLabel.text = " "
    }
    
    private lazy var areasNumCell = ValueDetailCell().then {
        $0.title.text = "房间/区域".localizedString
        $0.valueLabel.text = " "
    }

    private lazy var section1Header = AreaMemberSectionHeader()
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.register(ValueDetailCell.self, forCellReuseIdentifier: ValueDetailCell.reusableIdentifier)
        $0.register(AreaMemberCell.self, forCellReuseIdentifier: AreaMemberCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 50
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var deleteButton = ImageTitleButton(frame: .zero, icon: nil, title: "删除".localizedString, titleColor: UIColor.custom(.black_333333), backgroundColor: UIColor.custom(.white_ffffff)).then {
        $0.isHidden = true
        $0.clickCallBack = { [weak self] in
            let str0 = getCurrentLanguage() == .chinese ? "确定删除吗?\n\n" : "Are you sure to delete it?\n\n"
            let str1 = getCurrentLanguage() == .chinese ? "删除后，该家庭/公司下的全部设备自动解除绑定" : "After deletion, all devices under the family/company are automatically unbound"
            var attributedString = NSMutableAttributedString(
                string: str0,
                attributes: [
                    NSAttributedString.Key.font : UIFont.font(size: 14, type: .bold),
                    NSAttributedString.Key.foregroundColor : UIColor.custom(.black_3f4663)
                ]
            )
            
            let attributedString2 = NSMutableAttributedString(
                string: str1,
                attributes: [
                    NSAttributedString.Key.font : UIFont.font(size: 12, type: .bold),
                    NSAttributedString.Key.foregroundColor : UIColor.custom(.black_3f4663)
                ]
            )
            
            attributedString.append(attributedString2)

            TipsAlertView.show(attributedString: attributedString) { [weak self] in
                self?.deleteArea()
            }
        }
    }
    
    private lazy var quitButton = ImageTitleButton(frame: .zero, icon: nil, title: "退出".localizedString, titleColor: UIColor.custom(.black_333333), backgroundColor: UIColor.custom(.white_ffffff)).then {
        $0.isHidden = true
        $0.clickCallBack = { [weak self] in
            let str0 = getCurrentLanguage() == .chinese ? "确定退出吗?\n\n" : "Are you sure to delete it?\n\n"
            let str1 = getCurrentLanguage() == .chinese ? "退出后，不能查看并控制该家庭的房间设备" : "After quit, all areas and devices under the family/company will be invisable"
            var attributedString = NSMutableAttributedString(
                string: str0,
                attributes: [
                    NSAttributedString.Key.font : UIFont.font(size: 14, type: .bold),
                    NSAttributedString.Key.foregroundColor : UIColor.custom(.black_3f4663)
                ]
            )
            
            let attributedString2 = NSMutableAttributedString(
                string: str1,
                attributes: [
                    NSAttributedString.Key.font : UIFont.font(size: 12, type: .bold),
                    NSAttributedString.Key.foregroundColor : UIColor.custom(.black_3f4663)
                ]
            )
            
            attributedString.append(attributedString2)

            TipsAlertView.show(attributedString: attributedString) { [weak self] in
                self?.quitArea()
            }
        }
    }
    
    private var setNameAlertView: InputAlertView?
    
    private lazy var generateQRCodeAlert = GenerateQRCodeAlert(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    
    private lazy var noAuthTipsView = NoAuthTipsView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAreaDetail()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "家庭/公司".localizedString
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(deleteButton)
        view.addSubview(quitButton)
        
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(getAreaDetail))
        
        generateQRCodeAlert.callback = { [weak self] roles in
            guard let self = self else { return }
            let ids = roles.map(\.id)
            self.getInviteQRCode(role_ids: ids)
        }
    }
    
    override func setupConstraints() {
        deleteButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
        }
        
        quitButton.snp.makeConstraints {
            $0.edges.equalTo(deleteButton)
        }
        
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(deleteButton.snp.top).offset(-10)
        }
    }

}

extension AreaDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if authManager.currentRolePermissions.get_area_invite_code && !(area?.sa_token.contains("unbind") ?? true) {
                return 3
            } else {
                return 2
            }
        } else {
            return members.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 && members.count > 0  {
            return section1Header
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && members.count > 0  {
            return 45
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return nameCell
            } else if indexPath.row == 1 {
                if authManager.currentRolePermissions.get_area_invite_code && !(area?.sa_token.contains("unbind") ?? true) {
                    return qrCodeCell
                } else {
                    return areasNumCell
                }
                
            } else {
                return areasNumCell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AreaMemberCell.reusableIdentifier, for: indexPath) as! AreaMemberCell
            cell.member = members[indexPath.row]
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let setNameAlertView = InputAlertView(labelText: "家庭/公司名称".localizedString, placeHolder: "请输入家庭/公司名称".localizedString) { [weak self] text in
                    guard let self = self else { return }
                    self.changeAreaName(name: text)
                }
                setNameAlertView.textField.text = nameCell.valueLabel.text
                
                self.setNameAlertView = setNameAlertView
                
                SceneDelegate.shared.window?.addSubview(setNameAlertView)
            } else if indexPath.row == 1 {
                
                if authManager.currentRolePermissions.get_area_invite_code && !(area?.sa_token.contains("unbind") ?? true) {
                    SceneDelegate.shared.window?.addSubview(generateQRCodeAlert)
                } else {
                    let vc = LocationsManagementViewController()
                    vc.sa_token = area?.sa_token ?? ""
                    vc.area_id = area?.id
                    navigationController?.pushViewController(vc, animated: true)
                }

                
            } else {
                let vc = LocationsManagementViewController()
                vc.sa_token = area?.sa_token ?? ""
                vc.area_id = area?.id
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = MemberInfoViewController()
            vc.member_id = members[indexPath.row].user_id
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}

extension AreaDetailViewController {
    @objc private func getAreaDetail() {
        guard let area = area else { return }
        let sa_token = area.sa_token
        checkAuthState()
        
        if area.sa_token == authManager.currentSA.token && authManager.isSAEnviroment {
            getMembers()
            getRolesList()
        }
        
        
        /// cache
        if sa_token.contains("unbind") || !authManager.isSAEnviroment {
            let result = AreaCache.areaDetail(id: area.id, sa_token: sa_token)
            tableView.mj_header?.endRefreshing()
            areasNumCell.valueLabel.text = "\(result.locations_count)"
            nameCell.valueLabel.text = result.name == "" ? " " : result.name
            return
        }

        apiService.requestModel(.areaDetail(area_id: area.id), modelType: AreaDetailResponse.self) { [weak self] (response) in
            self?.tableView.mj_header?.endRefreshing()
            self?.areasNumCell.valueLabel.text = "\(response.location_count)"
            self?.nameCell.valueLabel.text = response.name == "" ? " " : response.name
            self?.tableView.reloadData()
        } failureCallback: { [weak self] (code, err) in
            self?.tableView.mj_header?.endRefreshing()
        }
    }
    
    private func changeAreaName(name: String) {
        guard let id = area?.id, let sa_token = area?.sa_token else { return }
        
        /// cache
        if sa_token.contains("unbind") {
            AreaCache.changeAreaName(id: id, name: name, sa_token: sa_token)
            setNameAlertView?.removeFromSuperview()
            nameCell.valueLabel.text = name
            AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
            return
        }

        apiService.requestModel(.changeAreaName(area_id: id, name: name), modelType: BaseModel.self) { [weak self] (response) in
            guard let self = self else { return }
            AreaCache.changeAreaName(id: id, name: name, sa_token: sa_token)
            self.setNameAlertView?.removeFromSuperview()
            self.nameCell.valueLabel.text = name
            AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
    }
    
    private func deleteArea() {
        guard let id = area?.id, let sa_token = area?.sa_token else { return }
        
        /// cache
        if sa_token.contains("unbind") {
            AreaCache.deleteArea(id: id, sa_token: sa_token)
            
            if AreaCache.areaList().count == 0 {
                AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)")
            }
            
            showToast(string: "删除成功".localizedString)
            AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
            navigationController?.popViewController(animated: true)
            return
        }

        apiService.requestModel(.deleteArea(area_id: id), modelType: BaseModel.self) { [weak self] (response) in
            guard let self = self else { return }
            AreaCache.deleteArea(id: id, sa_token: sa_token)
            
            
            let realm = try! Realm()
            if let cacheSA = realm.objects(SmartAssistantCache.self).filter("token = '\(sa_token)'").first {
                try? realm.write {
                    realm.delete(cacheSA)
                }
            }
            if let sa = SmartAssistantCache.getSmartAssistantsFromCache().first {
                self.authManager.currentSA = sa
            }
            
            if AreaCache.areaList().count == 0 {
                AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)")
            }

            self.showToast(string: "删除成功".localizedString)
            AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
            self.navigationController?.popViewController(animated: true)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
    }
    
    private func quitArea() {
        guard let id = area?.id, let sa_token = area?.sa_token else { return }
        apiService.requestModel(.quitArea(area_id: id, user_id: authManager.currentSA.user_id), modelType: BaseModel.self) { [weak self] _ in
            guard let self = self else { return }
            AreaCache.deleteArea(id: id, sa_token: sa_token)
            
            let realm = try! Realm()
            if let cacheSA = realm.objects(SmartAssistantCache.self).filter("token = '\(sa_token)'").first {
                try? realm.write {
                    realm.delete(cacheSA)
                }
            }
            if let sa = SmartAssistantCache.getSmartAssistantsFromCache().first {
                self.authManager.currentSA = sa
            }
            
            if AreaCache.areaList().count == 0 {
                AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)")
            }
            
            self.showToast(string: "退出成功".localizedString)
            AppDelegate.shared.appDependency.tabbarController.homeVC?.needSwitchToCurrentSAArea = true
            self.navigationController?.popViewController(animated: true)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
    }

    
    private func getInviteQRCode(role_ids: [Int]) {
        guard let id = area?.id, let areaName = area?.name else { return }
       
        
        apiService.requestModel(.getInviteQRCode(token: authManager.currentSA.token, user_id: authManager.currentSA.user_id, area_id: id, role_ids: role_ids), modelType: QRCodeResponse.self) { [weak self] (response) in
            guard let self = self else { return }
            self.generateQRCodeAlert.removeFromSuperview()
            QRCodePresentAlert.show(qrcodeString: response.qr_code, nickname: self.authManager.currentSA.nickname, areaName: areaName)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }
        
    }
    
    private func getMembers() {
        if area?.sa_token != authManager.currentSA.token {
            return
        }

        apiService.requestModel(.memberList, modelType: MembersResponse.self) { [weak self] response in
            guard let self = self else { return }
            self.section1Header.titleLabel.text = "成员 ".localizedString + " (\(response.users.count))"
            self.members = response.users
            if !response.is_creator {
                self.quitButton.isHidden = false
            } else {
                self.quitButton.isHidden = true
                self.deleteButton.isHidden = false
            }
            self.tableView.reloadData()
            
        }

    }
    
    private func getRolesList() {
        apiService.requestModel(.rolesList, modelType: RoleListResponse.self) { [weak self] response in
            guard let self = self else { return }
            self.generateQRCodeAlert.setupRoles(roles: response.roles)
        } failureCallback: { (code, err) in
            
        }

    }
    


}

extension AreaDetailViewController {
    private func checkAuthState() {
        guard let area = area else { return }
        let sa_token = area.sa_token
        
        if !area.sa_token.contains("unbind") && !authManager.isSAEnviroment {
            view.addSubview(noAuthTipsView)
            noAuthTipsView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(15)
                $0.left.equalToSuperview().offset(15)
                $0.right.equalToSuperview().offset(-15)
                $0.height.equalTo(40)
            }
            
            tableView.snp.remakeConstraints {
                $0.top.equalTo(noAuthTipsView.snp.bottom).offset(15)
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(deleteButton.snp.top).offset(-10)
            }
            tableView.isUserInteractionEnabled = false
            tableView.alpha = 0.5
            return
        }
        
        if sa_token.contains("unbind") {
            deleteButton.isHidden = false
            return
        }

        
        
        if authManager.currentRolePermissions.update_area_name {
            nameCell.isUserInteractionEnabled = true
            nameCell.contentView.alpha = 1
            
        } else {
            nameCell.contentView.alpha = 0.5
            nameCell.isUserInteractionEnabled = false
            
        }
        
        
        tableView.reloadData()


    }
}

extension AreaDetailViewController {
    private class AreaDetailResponse: BaseModel {
        var name = ""
        var location_count = 0
    }
    
    private class QRCodeResponse: BaseModel {
        var qr_code = ""
        
    }
    
    private class MembersResponse: BaseModel {
        var self_id = 0
        var is_creator = false
        var users = [User]()
    }

    private class RoleListResponse: BaseModel {
        var roles = [Role]()
    }
}
