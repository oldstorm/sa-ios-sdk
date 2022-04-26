//
//  LocationDetailViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/15.
//

import UIKit

class LocationDetailViewController: BaseViewController {
    
    var rolePermission = RolePermission()
    
    var area = Area()
    
    var location_id: Int?
    
    lazy var devices = [Device]()
    
    private lazy var header = LocationDetailHeader()
    
    var tipsAlert: TipsAlertView?
    
    private lazy var deleteButton = Button().then {
        $0.setTitle("删除".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        if getCurrentLanguage() == .chinese {
            $0.titleLabel?.font = .font(size: 14, type: .bold)
        } else {
            $0.titleLabel?.font = .font(size: 12, type: .bold)
        }
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let str0 = getCurrentLanguage() == .chinese ? "确定删除该房间吗?\n\n" : "Are you sure to delete it?\n\n"
            let str1 = getCurrentLanguage() == .chinese ? "删除房间,不会把房间内设备清除" : "After deletion,  devices under this location will not be remove together"
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
            
            self.tipsAlert = TipsAlertView.show(attributedString: attributedString) { [weak self] in
                self?.deleteLocation()
            }
        }
    }
    
    private lazy var flowLayout = UICollectionViewFlowLayout().then {
        let sizeW = (Screen.screenWidth - 45) / 2
        let sizeH = sizeW * 140 / 165
        $0.itemSize = CGSize(width: sizeW, height: sizeH)
        $0.minimumLineSpacing = 15
        $0.minimumInteritemSpacing = 15
        $0.headerReferenceSize = CGSize(width: Screen.screenWidth - 30, height: 15)
        $0.footerReferenceSize = CGSize(width: Screen.screenWidth - 30, height: 15)
        
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.delegate = self
        $0.dataSource = self
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.register(LocationDetailDeviceCell.self, forCellWithReuseIdentifier: LocationDetailDeviceCell.reusableIdentifier)
        $0.layer.cornerRadius = 10
    }
    
    private var changeNameAlerView: InputAlertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "房间".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: deleteButton)
        requestNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(header)
        view.addSubview(collectionView)
        
        header.changeNameCallback = { [weak self] in
            guard let self = self else { return }
            let alertView = InputAlertView(labelText: "房间名称".localizedString, placeHolder: "请输入房间名称".localizedString) { [weak self] text in
                guard let self = self else { return }
                self.changeLocationName(name: text)
            }
            alertView.textField.text = self.header.valueLabel.text
            self.changeNameAlerView = alertView
            
            SceneDelegate.shared.window?.addSubview(alertView)
            
        }
    }
    
    override func setupConstraints() {
        header.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview()
        }
        
        
    }
}


extension LocationDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        header.deviceLabel.isHidden = (devices.count == 0)
        return devices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationDetailDeviceCell.reusableIdentifier, for: indexPath) as! LocationDetailDeviceCell
        cell.device = devices[indexPath.row]
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if devices[indexPath.row].is_sa {
            let vc = SADeviceViewController()
            vc.device_id = devices[indexPath.row].id
            vc.deviceImg.setImage(urlString: devices[indexPath.row].logo_url, placeHolder: .assets(.default_device))
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        //        if let link = devices[indexPath.row].plugin_url {
        //            let vc = DeviceWebViewController(link: link, device_id: devices[indexPath.row].id)
        //            vc.area = area
        //            navigationController?.pushViewController(vc, animated: true)
        //        }
        //检测插件包是否需要更新
        self.showLoadingView()
        ApiServiceManager.shared.checkPluginUpdate(id: devices[indexPath.row].plugin_id) { [weak self] response in
            guard let self = self else { return }
            let filepath = ZTZipTool.getDocumentPath() + "/" + self.devices[indexPath.row].plugin_id
            
            @UserDefaultWrapper(key: .plugin(id: self.devices[indexPath.row].plugin_id))
            var info: String?

            let cachePluginInfo = Plugin.deserialize(from: info ?? "")
            
            
            //检测本地是否有文件，以及是否为最新版本
            if ZTZipTool.fileExists(path: filepath) && cachePluginInfo?.version == response.plugin.version {
                self.hideLoadingView()
                //直接打开插件包获取信息
                let urlPath = "file://" + ZTZipTool.getDocumentPath() + "/" + self.devices[indexPath.row].plugin_id + "/" + self.devices[indexPath.row].control
                let vc = DeviceWebViewController(link: urlPath, device_id: self.devices[indexPath.row].id)
                vc.area = self.area
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                //根据路径下载最新插件包，存储在document
                ZTZipTool.downloadZipToDocument(urlString: response.plugin.download_url ?? "",fileName: self.devices[indexPath.row].plugin_id) { [weak self] success in
                    guard let self = self else { return }
                    self.hideLoadingView()
                    if success {
                        //根据相对路径打开本地静态文件
                        let urlPath = "file://" + ZTZipTool.getDocumentPath() + "/" + self.devices[indexPath.row].plugin_id + "/" + self.devices[indexPath.row].control
                        let vc = DeviceWebViewController(link: urlPath, device_id: self.devices[indexPath.row].id)
                        vc.area = self.area
                        self.navigationController?.pushViewController(vc, animated: true)
                        //存储插件信息
                        info = response.plugin.toJSONString(prettyPrint:true)
                        
                    } else {
                        self.showToast(string: "下载插件包失败".localizedString)
                    }
                    
                }
                
            }
            
            
            
        } failureCallback: { [weak self] code, err in
            self?.hideLoadingView()
        }
        
    }
    
}


extension LocationDetailViewController {
    func requestNetwork() {
        /// auth
        getRolePermission()
        
        guard let id = location_id else { return }
        
        /// cache
        if !area.is_bind_sa && !UserManager.shared.isLogin {
            if let area = LocationCache.locationDetail(location_id: id, sa_token: area.sa_user_token) {
                header.valueLabel.text = area.name
                devices = area.devices
                collectionView.reloadData()
            }
            
            return
        }
        
        showLoadingView()
        ApiServiceManager.shared.locationDetail(area: area, id: id) { [weak self] (response) in
            self?.hideLoadingView()
            self?.devices = response.devices
            self?.header.valueLabel.text = response.name
            self?.collectionView.reloadData()
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.hideLoadingView()
            if let area = LocationCache.locationDetail(location_id: id, sa_token: self.area.sa_user_token) {
                self.header.valueLabel.text = area.name
                self.devices = area.devices
                self.collectionView.reloadData()
            }
        }
        
    }
    
    func changeLocationName(name: String) {
        guard let id = location_id else { return }
        
        /// cache
        if !area.is_bind_sa && !UserManager.shared.isLogin {
            LocationCache.changeLocationName(location_id: id, name: name, sa_token: self.area.sa_user_token)
            header.valueLabel.text = name
            changeNameAlerView?.removeFromSuperview()
            return
        }
        
        changeNameAlerView?.isSureBtnLoading = true
        
        ApiServiceManager.shared.changeLocationName(area: area, id: id, name: name) { [weak self] (response) in
            guard let self = self else { return }
            LocationCache.changeLocationName(location_id: id, name: name, sa_token: self.area.sa_user_token)
            self.changeNameAlerView?.isSureBtnLoading = false
            self.header.valueLabel.text = name
            self.changeNameAlerView?.removeFromSuperview()
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.changeNameAlerView?.isSureBtnLoading = false
        }
        
    }
    
    func deleteLocation() {
        guard let id = location_id else { return }
        
        /// cache
        if !area.is_bind_sa && !UserManager.shared.isLogin {
            LocationCache.deleteLocation(location_id: id, sa_token: area.sa_user_token)
            showToast(string: "删除成功".localizedString)
            navigationController?.popViewController(animated: true)
            return
        }
        
        tipsAlert?.isSureBtnLoading = true
        ApiServiceManager.shared.deleteLocation(area: area, id: id) { [weak self] (response) in
            guard let self = self else { return }
            LocationCache.deleteLocation(location_id: id, sa_token: self.area.sa_user_token)
            self.showToast(string: "删除成功".localizedString)
            self.tipsAlert?.isSureBtnLoading = false
            self.navigationController?.popViewController(animated: true)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.tipsAlert?.isSureBtnLoading = false
        }
        
    }
}


extension LocationDetailViewController {
    private func getRolePermission() {
        if !area.is_bind_sa && !UserManager.shared.isLogin {
            checkAuth()
            return
        }
        
        ApiServiceManager.shared.rolesPermissions(area: area, user_id: area.sa_user_id) { [weak self] response in
            guard let self = self else { return }
            self.rolePermission = response.permissions
            self.checkAuth()
            
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.rolePermission = RolePermission()
            self.checkAuth()
        }
        
    }
    
    private func checkAuth() {
        if !area.is_bind_sa {
            header.isUserInteractionEnabled = true
            header.alpha = 1
            deleteButton.isHidden = false
            
            return
        }
        
        if rolePermission.update_location_name {
            header.isUserInteractionEnabled = true
            header.alpha = 1
        } else {
            header.isUserInteractionEnabled = false
            header.alpha = 0.5
        }
        
        if rolePermission.delete_location {
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
        
    }
}
