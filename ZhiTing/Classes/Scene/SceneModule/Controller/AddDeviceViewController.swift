//
//  AddDeviceViewController.swift
//  ZhiTing
//
//  Created by mac on 2021/4/20.
//

import UIKit

class AddDeviceViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    enum AddDeviceType {
        /// 设备状态发送变化时
        case deviceStateChanged
        /// 控制设备
        case controlDevice
    }
    
    let type: AddDeviceType
    
    init(type: AddDeviceType) {
        self.type = type
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 设备变化时条件回调
    var addDeviceConditionChangedCallback: ((_ condition: SceneCondition) -> ())?
    
    private lazy var emptyView = EmptyStyleView(frame: .zero, style: .noList)

    private lazy var loadingView = LodingView().then {
        $0.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight - Screen.k_nav_height)
        $0.containerView.backgroundColor = .custom(.white_ffffff)
    }
    
    /// 控制设备回调
    var addControlDeviceCallback: ((_ task: SceneTask) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    var isExistNilLocation = false
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.estimatedSectionHeaderHeight = 10
        $0.estimatedSectionFooterHeight = 0
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        //创建Cell
        $0.register(AddDeviceCell.self, forCellReuseIdentifier: AddDeviceCell.reusableIdentifier)
        $0.alwaysBounceVertical = false
    }

    var currentDeviceList : [Device]?
    var locationData = [Location]()
    
    var currentData : [AddDeviceModel]?

    var menuSelectedIndex = 0
    
    private lazy var screenButton = Button().then {
        $0.setTitle("筛选".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.showMenuAlertView()
            //展示分类选项
        }
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: screenButton)
        navigationItem.title = self.type == .controlDevice ? "控制设备".localizedString : "设备状态变化时".localizedString
        requestLocations()
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        tableView.addSubview(emptyView)
        emptyView.isHidden = true
        view.addSubview(line)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.width.equalTo(tableView)
            $0.height.equalTo(tableView)
            $0.center.equalToSuperview()
        }
        
        line.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(0.5)
        }

    }

}

extension AddDeviceViewController {
    
    private func showMenuAlertView() {
        //弹出菜单栏
        let menuAlertView = MenuAlertView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        menuAlertView.currentDataArry = self.locationData
        menuAlertView.currentSeletedIndex = menuSelectedIndex
        SceneDelegate.shared.window?.addSubview(menuAlertView)
        menuAlertView.SelectCallback = {[weak self] index in
            guard let self = self else {
                return
            }
            self.menuSelectedIndex = index
            if index != 0 {
                let dataArr = self.currentData!.filter({$0.location_name == self.locationData[index].name})
                let devices = dataArr.first?.devices
                self.emptyView.isHidden = !(devices?.count == 0 || devices?.count == nil)
            }else{
                if self.currentData?.count != 0 {
                    self.emptyView.isHidden = true
                }else{
                    self.emptyView.isHidden = false
                }
            }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
        }
    }

    
    private func requestNetwork() {

        //roomData
        self.currentData = nil
        self.currentDeviceList = nil
//        self.tableView.isHidden = true
        ApiServiceManager.shared.deviceList(type: 1, area: authManager.currentArea) {[weak self] (respond) in
            guard let self = self else {
                return
            }
            self.hideLoadingView()
            if respond.devices.count == 0 {
                self.emptyView.isHidden = false
            }else{
                self.emptyView.isHidden = true
            }
            self.currentDeviceList = respond.devices
            //获取所有空间名称

            //获取对应空间数据
            var devicesModels = [AddDeviceModel]()
            
            self.currentDeviceList?.forEach {
                if $0.location_name == "" {
                    self.isExistNilLocation = true//存在未绑定房间数据
                }
            }
            
            if self.isExistNilLocation {//若存在未绑定房间数据
                let devicesModel = AddDeviceModel()
                devicesModel.location_name = ""
                devicesModel.devices = (self.currentDeviceList?.filter({ $0.location_name == ""}))!
                devicesModels.append(devicesModel)
            }
            
            let locations = self.locationData
            
                locations.forEach { locations in
                    let devicesModel = AddDeviceModel()
                    devicesModel.location_name = locations.name
                    self.currentDeviceList?.forEach { device in
                        if locations.name == device.location_name{
                            devicesModel.devices.append(device)
                        }
                    }
                    if devicesModel.devices.count != 0{
                        devicesModels.append(devicesModel)
                    }
                }

            self.currentData = devicesModels
            
            self.tableView.reloadData()
        } failureCallback: { (_, error) in
            print("\(error)")
        }

    }

    
    private func requestLocations() {
        self.locationData.removeAll()
        showLoadingView()
        
        ApiServiceManager.shared.areaLocationsList(area: authManager.currentArea) { [weak self] (respond) in
            guard let self = self else {
                return
            }
            let allLocation = Location()
            allLocation.name = "全部"
            self.locationData.append(allLocation)
            self.locationData.append(contentsOf: respond.locations)
            self.requestNetwork()
        } failureCallback: { (code, err) in
            self.showToast(string: err)
        }
        
    }
    
    private func showLoadingView(){
        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        loadingView.show()
    }
    
    private func hideLoadingView(){
        loadingView.hide()
        loadingView.removeFromSuperview()
    }
}

extension AddDeviceViewController {
     class LocationListResponse: BaseModel {
        var locations = [Location]()
    }
}

//UITableViewDelegate,UITableViewDataSource
extension AddDeviceViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if menuSelectedIndex == 0 {
            return currentData?.count ?? 0
        }else{
            let dataArr = currentData!.filter({$0.location_name == locationData[menuSelectedIndex].name})
            if dataArr.first?.devices.count == 0 {
                return 0
            }else{
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = .clear
        let lable = UILabel()
        lable.font = .font(size: ZTScaleValue(12), type: .regular)
        lable.textColor = .custom(.gray_94a5be)
        lable.backgroundColor = .clear
        view.addSubview(lable)
        lable.snp.makeConstraints {
            $0.left.equalTo(ZTScaleValue(14))
            $0.top.bottom.right.equalToSuperview()
        }
        
        if menuSelectedIndex == 0 {
            if self.isExistNilLocation {
                if section == 0 {
                    lable.text = ""
                }else{
                    lable.text = currentData?[section].location_name
                }
            }else{
                    lable.text = currentData?[section].location_name
            }
        }else{
            let dataArr = currentData!.filter({$0.location_name == locationData[menuSelectedIndex].name})
            lable.text = dataArr.first?.location_name
        }
        
        return view

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if menuSelectedIndex == 0{
                if self.isExistNilLocation  {
                    return 0
                }
            }
        }
        
        return ZTScaleValue(40)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if menuSelectedIndex == 0 {
            return currentData?[section].devices.count ?? 0
        }else{
            //判断分区所存在的device数量
            let dataArr = currentData!.filter({$0.location_name == locationData[menuSelectedIndex].name})
            let devices = dataArr.first?.devices
            if devices?.count == 0 {
                return 0
                //展示无场景列表视图
            }else{
                if (devices != nil) {
                    return devices!.count
                }else{
                    return 0
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(70)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddDeviceCell.reusableIdentifier, for: indexPath) as! AddDeviceCell
        cell.selectionStyle = .none
        
        if menuSelectedIndex == 0 {
            cell.currentModel = currentData?[indexPath.section].devices[indexPath.row]
            let devices = currentData?[indexPath.section].devices
            if devices?.count == indexPath.row + 1 {
                cell.line.isHidden = true
            }else{
                cell.line.isHidden = false
            }
        }else{
            let dataArr = currentData!.filter({$0.location_name == locationData[menuSelectedIndex].name})
            let devices = dataArr.first?.devices
            if devices?.count == 0 {
                //
            }else{
                cell.currentModel = devices?[indexPath.row]
                if devices?.count == indexPath.row + 1 {
                    cell.line.isHidden = true
                }else{
                    cell.line.isHidden = false
                }

            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var device = Device()
        
        if menuSelectedIndex == 0 {
            device = (currentData?[indexPath.section].devices[indexPath.row])!
               
        }else{
            let dataArr = currentData!.filter({$0.location_name == locationData[menuSelectedIndex].name})
            device = (dataArr.first?.devices[indexPath.row])!
        }

        pushVCWithDevice(device: device)
            
    }
    
    private func pushVCWithDevice(device: Device){
        if type == .deviceStateChanged {
            let vc = SceneSetDeviceViewController(type: .deviceStateChanged)
            vc.device_id = device.id
            vc.title = device.name
            vc.addDeviceConditionChangedCallback = { [weak self] condition in
                self?.addDeviceConditionChangedCallback?(condition)
                
            }
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = SceneSetDeviceViewController(type: .controlDevice)
            vc.device_id = device.id
            vc.title = device.name
            vc.addControlDeviceCallback = { [weak self] task in
                self?.addControlDeviceCallback?(task)
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}



extension AddDeviceViewController {

    class AddDeviceModel: BaseModel {
        var location_name = ""
        var devices = [Device]()
    }

}

