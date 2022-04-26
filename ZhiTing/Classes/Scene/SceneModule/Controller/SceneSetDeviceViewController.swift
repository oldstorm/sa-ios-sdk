//
//  SceneSetDeviceViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/25.
//

import UIKit
import FlexColorPicker

class SceneSetDeviceViewController: BaseViewController {
    enum SceneSetDeviceType {
        /// 设备状态发送变化时
        case deviceStateChanged
        /// 控制设备
        case controlDevice
    }
    
    let type: SceneSetDeviceType
    
    var device_id = 0
    
    var device: Device?
    
    /// 是否为修改  判断是添加还是修改
    var isEdit = false
    
    /// 修改时 actions的默认赋值
    var editDefaultActions: [SceneDeviceControlAction]?
    
    /// 修改时 actions的operator默认赋值
    var editDefaultOperator = ""
    
    /// 修改时 延时的默认赋值
    var defaultDelay: Int? {
        didSet {
            guard var delay = defaultDelay else { return }
            let h = delay / 3600
            delay = delay % 3600
            let m = delay / 60
            let s = delay % 60
            delayCell.valueLabel.text = String(format: "%.2d:%.2d:%.2d 后", h,m,s)
            
            let format = DateFormatter()
            format.dateFormat = "HH:mm:ss"
            let date = format.date(from: String(format: "%.2d:%.2d:%.2d", h,m,s)) ?? Date()
            datePicker.setCurrentTime(timestamp: Int(date.timeIntervalSince1970))
        }
    }
    
    init(type: SceneSetDeviceType) {
        self.type = type
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设备变化时条件回调
    var addDeviceConditionChangedCallback: ((_ condition: SceneCondition) -> ())?
    
    /// 控制设备回调
    var addControlDeviceCallback: ((_ task: SceneTask) -> ())?
    
    lazy var deviceControlActions = [SceneDeviceControlAction]()

    private lazy var resetButton = Button().then {
        $0.setTitle("重置".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.clickCallBack = { [weak self] _ in
            self?.deviceControlActions.forEach { $0.val = nil }
            self?.delayCell.valueLabel.text = " "
            self?.tableView.reloadData()

        }
    }

    
    private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.register(SceneSetDeviceCell.self, forCellReuseIdentifier: SceneSetDeviceCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
    }
    
    private lazy var nextButton = ImageTitleButton(frame: .zero, icon: nil, title: "下一步".localizedString, titleColor: .custom(.white_ffffff), backgroundColor: .custom(.blue_2da3f6))
    
    private lazy var delayCell = ValueDetailCell().then {
        $0.title.text = "延时".localizedString
    }
    
    private lazy var datePicker = SceneConditionPickerView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight)).then {
        $0.titleLabel.text = "延时"
        $0.pickerCallback = { [weak self] time in
            guard let self = self else { return }
            let format = DateFormatter()
            format.dateStyle = .medium
            format.timeStyle = .medium
            format.dateFormat = "HH:mm:ss"
            let date = Date(timeIntervalSince1970: TimeInterval(time))
            let str = format.string(from: date)
            self.delayCell.valueLabel.text = str + " 后"
            self.tableView.reloadData()
        }
    }
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(nextButton)
        
        
        delayCell.isHidden = (type == .deviceStateChanged)
        nextButton.isHidden = (type == .deviceStateChanged)
        
        nextButton.clickCallBack = { [weak self] in
            self?.addControlDevice()
        }
    }
    
    override func setupConstraints() {
        nextButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
        }
    
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(ZTScaleValue(-10))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if type == .controlDevice {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: resetButton)
        }
        
        requestNetwork()
    }
    
    
    /// 添加设备变化时
    private func addDeviceStateChangedCondition(action_val: Any?, permission: Int?, val_type: String, max: Any?, min: Any?, aid: Int?, operator: String, type: String) {

        let condition = SceneCondition()
        condition.condition_type = 2
        condition.device_id = device_id
        condition.operator = `operator`

        let item = SceneDeviceControlAction()
        item.val = action_val
        item.val_type = val_type
        item.max = max
        item.min = min
        item.type = type
        item.aid = aid
        item.permission = permission
        
        condition.condition_attr = item
        
        let device_info = SceneDetailDeviceInfo()
        device_info.name = device?.name ?? ""
        device_info.location_name = device?.location?.name
        device_info.department_name = device?.department?.name
        device_info.logo_url = device?.logo_url ?? ""
        condition.device_info = device_info
               
        addDeviceConditionChangedCallback?(condition)
        
        if let count = self.navigationController?.viewControllers.count, count - 2 > 0 && !isEdit {
            self.navigationController?.viewControllers.remove(at: count - 2)
        }
        navigationController?.popViewController(animated: true)


    }
    
    /// 添加控制设备
    private func addControlDevice() {
        if deviceControlActions.filter({ $0.val != nil}).count == 0 {
            showToast(string: "请先设置控制项")
            return
        }
        
        let task = SceneTask()
        task.type = 1
        
        let scene_task_devices = deviceControlActions
            .filter({ $0.val != nil})

        
        task.device_id = device_id
        task.attributes = scene_task_devices
        
        let currentTime = datePicker.currentTime
        
        if currentTime != "00:00:00" {
            var secs = 0
            let cons = currentTime.components(separatedBy: ":").map { Int($0) ?? 0}
            if cons.count == 3 {
                secs += cons[0] * 3600
                secs += cons[1] * 60
                secs += cons[2]
            }

            task.delay_seconds = secs
        }
        
        let device_info = SceneDetailDeviceInfo()
        device_info.name = device?.name ?? ""
        device_info.logo_url = device?.logo_url ?? ""
        device_info.location_name = device?.location?.name
        device_info.department_name = device?.department?.name

        task.device_info = device_info

        addControlDeviceCallback?(task)
        if let count = self.navigationController?.viewControllers.count, count - 2 > 0 && !isEdit {
            self.navigationController?.viewControllers.remove(at: count - 2)
        }
        navigationController?.popViewController(animated: true)
    }
}

extension SceneSetDeviceViewController {    
    
    private func requestNetwork() {
        showLoadingView()
        let reqType = self.type == .controlDevice ? 1 : 2
        ApiServiceManager.shared.deviceDetail(area: authManager.currentArea, type: reqType, device_id: device_id) { [weak self] response in
            guard let self = self else { return }
            self.hideLoadingView()
            if self.type == .controlDevice { // 控制设备时 需要展示的attributes
                let showAttrs = ["on_off", "power", "powers_1", "powers_2", "powers_3", "brightness", "color_temp", "rgb", "target_state", "target_position", "switch_event"]
                response.device_info.attributes = response.device_info.attributes.filter { showAttrs.contains($0.type) }

            } else { // 设备变化时 需要展示的attributes
                let showAttrs = ["on_off", "power", "powers_1", "powers_2", "powers_3", "brightness", "color_temp", "rgb", "humidity", "temperature", "motion_detected", "contact_sensor_state", "leak_detected", "target_state", "target_position", "switch_event"]
                response.device_info.attributes = response.device_info.attributes.filter { showAttrs.contains($0.type) }
            }

            self.deviceControlActions = response.device_info.attributes.map({ (deviceAction) -> SceneDeviceControlAction in
                let control = SceneDeviceControlAction()
                control.aid = deviceAction.aid
                control.val_type = deviceAction.val_type ?? ""
                control.max = deviceAction.max
                control.min = deviceAction.min
                control.permission = deviceAction.permission
                control.type = deviceAction.type
                return control
            })
            

            if let defaultActions = self.editDefaultActions { /// 编辑时默认赋值
                defaultActions.forEach { `default` in
                    if let action = self.deviceControlActions.first(where: { $0.type == `default`.type && $0.aid == `default`.aid }) {
                        action.val = `default`.val
                        action.max = `default`.max
                        action.min = `default`.min
                        action.aid = `default`.aid
                        action.val_type = `default`.val_type
                        
                        
                    }
                }
            }

            self.device = response.device_info
            self.tableView.reloadData()

        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }


    }
    

}

extension SceneSetDeviceViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if deviceControlActions.count > 0 {
            return 2
        } else {
            return 0
        }
        
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 10
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return deviceControlActions.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView()
            view.backgroundColor = .custom(.gray_f6f8fd)
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SceneSetDeviceCell.reusableIdentifier, for: indexPath) as! SceneSetDeviceCell
            let controlAction = deviceControlActions[indexPath.row]
            if controlAction.type == "rgb" {
                cell.title.text = controlAction.actionName
                cell.valueLabel.text = " "
                cell.colorBlock.isHidden = false
                if let val = controlAction.val as? String, let color = UIColor(hex: val) {
                    cell.colorBlock.backgroundColor = color
                }

            } else {
                cell.colorBlock.isHidden = true
                cell.title.text = controlAction.actionName
                if type == .controlDevice {
                    cell.valueLabel.text = controlAction.displayActionValue
                    
                    
                    if controlAction.type == "target_position" {
                        if (controlAction.val as? Int == controlAction.max as? Int) && controlAction.val != nil {
                            cell.valueLabel.text = "打开窗帘".localizedString
                        } else if (controlAction.val as? Int == controlAction.min as? Int) && controlAction.val != nil {
                            cell.valueLabel.text = "关闭窗帘".localizedString
                        }
                    }

                }
                
            }
            
            

            return cell
        } else {
            return delayCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let controlAction = deviceControlActions[indexPath.row]
            switch controlAction.controlActionType {
            case .brightness: /// 设置亮度
                let value: Int
                let maxValue = controlAction.max as? Int ?? 0
                let minValue = controlAction.min as? Int ?? 0
                if let val = (controlAction.val as? Int) {
                    value = val
                } else {
                    value = minValue
                }


                if type == .deviceStateChanged { /// 设备状态发送变化时
                    var seg = 2
                    if editDefaultOperator == "<" && controlAction.val != nil {
                        seg = 1
                    } else if editDefaultOperator == "=" && controlAction.val != nil {
                        seg = 2
                    } else if editDefaultOperator == ">" && controlAction.val != nil {
                        seg = 3
                    }

                    let alert = DeviceBrightnessAttrAlert(value: value, maxValue: maxValue, minValue: minValue, segmentTag: seg)
                    alert.valueCallback = { [weak self] value,seletedTag in
                        guard let self = self else { return }
                        var `operator` = ""
                        if seletedTag == 1 {
                            `operator` = "<"
                        } else if seletedTag == 2 {
                            `operator` = "="
                        } else if seletedTag == 3 {
                            `operator` = ">"
                        }
                        
                        self.addDeviceStateChangedCondition(action_val: value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: `operator`, type: controlAction.type)
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                } else {  /// 控制设备
                    let alert = DeviceBrightnessAttrAlert(value: value, maxValue: maxValue, minValue: minValue, segmentTag: 0)
                    alert.valueCallback = { value, seletedTag in
                        controlAction.val = value
                        tableView.reloadData()

                    }
                    
                    SceneDelegate.shared.window?.addSubview(alert)
                }
                
                
                

            case .color_temp: /// 设置色温
                let value: Int
                let maxValue = controlAction.max as? Int ?? 0
                let minValue = controlAction.min as? Int ?? 0
                if let val = (controlAction.val as? Int) {
                    value = val
                } else {
                    value = minValue
                }
                
                if type == .deviceStateChanged { /// 设备状态发送变化时
                    var seg = 2
                    if editDefaultOperator == "<" && controlAction.val != nil {
                        seg = 1
                    } else if editDefaultOperator == "=" && controlAction.val != nil {
                        seg = 2
                    } else if editDefaultOperator == ">" && controlAction.val != nil {
                        seg = 3
                    }
                    
                    let alert = DeviceColorTemperatureAttrAlert(value: value, maxValue: maxValue, minValue: minValue, segmentTag: seg)
                    alert.valueCallback = { [weak self] value,seletedTag in
                        guard let self = self else { return }
                        var `operator` = ""
                        if seletedTag == 1 {
                            `operator` = "<"
                        } else if seletedTag == 2 {
                            `operator` = "="
                        } else if seletedTag == 3 {
                            `operator` = ">"
                        }
                        
                        self.addDeviceStateChangedCondition(action_val: value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: `operator`, type: controlAction.type)
                        
                    }
                    SceneDelegate.shared.window?.addSubview(alert)

                } else {  /// 控制设备
                    let alert = DeviceColorTemperatureAttrAlert(value: value, maxValue: maxValue, minValue: minValue, segmentTag: 0)
                    alert.valueCallback = { value, seletedTag in
                        controlAction.val = value
                        tableView.reloadData()

                    }
                    
                    SceneDelegate.shared.window?.addSubview(alert)
                }

                
                
                
            case .power: /// 设置开关
                if type == .controlDevice {  /// 控制设备
                    let item1 = DeviceSelectionAttrAlert.Item(title: "打开".localizedString, value: "on")
                    let item2 = DeviceSelectionAttrAlert.Item(title: "关闭".localizedString, value: "off")
                    let item3 = DeviceSelectionAttrAlert.Item(title: "开关切换".localizedString, value: "toggle")
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1, item2, item3])
                    if let val = controlAction.val as? String {
                        if val == "on" {
                            alert.selectedItem = item1
                        } else if val == "off" {
                            alert.selectedItem = item2
                        } else if val == "toggle" {
                            alert.selectedItem = item3
                        }
                    }
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                } else if type == .deviceStateChanged { /// 设备状态发送变化时
                    
                    let item1 = DeviceSelectionAttrAlert.Item(title: "打开".localizedString, value: "on")
                    let item2 = DeviceSelectionAttrAlert.Item(title: "关闭".localizedString, value: "off")
                    
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1, item2])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                        self.addDeviceStateChangedCondition(action_val: item.value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                    }
                    if let val = controlAction.val as? String {
                        if val == "on" {
                            alert.selectedItem = item1
                        } else if val == "off" {
                            alert.selectedItem = item2
                        }
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                }
                
            case .on_off: /// 设置开关
                if type == .controlDevice {  /// 控制设备
                    let item1 = DeviceSelectionAttrAlert.Item(title: "打开".localizedString, value: "on")
                    let item2 = DeviceSelectionAttrAlert.Item(title: "关闭".localizedString, value: "off")
                    let item3 = DeviceSelectionAttrAlert.Item(title: "开关切换".localizedString, value: "toggle")
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1, item2, item3])
                    if let val = controlAction.val as? String {
                        if val == "on" {
                            alert.selectedItem = item1
                        } else if val == "off" {
                            alert.selectedItem = item2
                        } else if val == "toggle" {
                            alert.selectedItem = item3
                        }
                    }
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                } else if type == .deviceStateChanged { /// 设备状态发送变化时
                    
                    let item1 = DeviceSelectionAttrAlert.Item(title: "打开".localizedString, value: "on")
                    let item2 = DeviceSelectionAttrAlert.Item(title: "关闭".localizedString, value: "off")
                    
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1, item2])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                        self.addDeviceStateChangedCondition(action_val: item.value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                    }
                    if let val = controlAction.val as? String {
                        if val == "on" {
                            alert.selectedItem = item1
                        } else if val == "off" {
                            alert.selectedItem = item2
                        }
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                }
                
            case .powers_1: /// 一键
                if type == .controlDevice {  /// 控制设备
                    let item1 = DeviceSelectionAttrAlert.Item(title: "打开".localizedString, value: "on")
                    let item2 = DeviceSelectionAttrAlert.Item(title: "关闭".localizedString, value: "off")
                    let item3 = DeviceSelectionAttrAlert.Item(title: "开关切换".localizedString, value: "toggle")
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1, item2, item3])
                    if let val = controlAction.val as? String {
                        if val == "on" {
                            alert.selectedItem = item1
                        } else if val == "off" {
                            alert.selectedItem = item2
                        } else if val == "toggle" {
                            alert.selectedItem = item3
                        }
                    }
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                } else if type == .deviceStateChanged { /// 设备状态发送变化时
                    
                    let item1 = DeviceSelectionAttrAlert.Item(title: "打开".localizedString, value: "on")
                    let item2 = DeviceSelectionAttrAlert.Item(title: "关闭".localizedString, value: "off")
                    
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1, item2])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                        self.addDeviceStateChangedCondition(action_val: item.value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                    }
                    if let val = controlAction.val as? String {
                        if val == "on" {
                            alert.selectedItem = item1
                        } else if val == "off" {
                            alert.selectedItem = item2
                        }
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                }
                
            case .powers_2: /// 二键
                if type == .controlDevice {  /// 控制设备
                    let item1 = DeviceSelectionAttrAlert.Item(title: "打开".localizedString, value: "on")
                    let item2 = DeviceSelectionAttrAlert.Item(title: "关闭".localizedString, value: "off")
                    let item3 = DeviceSelectionAttrAlert.Item(title: "开关切换".localizedString, value: "toggle")
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1, item2, item3])
                    if let val = controlAction.val as? String {
                        if val == "on" {
                            alert.selectedItem = item1
                        } else if val == "off" {
                            alert.selectedItem = item2
                        } else if val == "toggle" {
                            alert.selectedItem = item3
                        }
                    }
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                } else if type == .deviceStateChanged { /// 设备状态发送变化时
                    
                    let item1 = DeviceSelectionAttrAlert.Item(title: "打开".localizedString, value: "on")
                    let item2 = DeviceSelectionAttrAlert.Item(title: "关闭".localizedString, value: "off")
                    
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1, item2])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                        self.addDeviceStateChangedCondition(action_val: item.value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                    }
                    if let val = controlAction.val as? String {
                        if val == "on" {
                            alert.selectedItem = item1
                        } else if val == "off" {
                            alert.selectedItem = item2
                        }
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                }
                
            case .powers_3: /// 三键
                if type == .controlDevice {  /// 控制设备
                    let item1 = DeviceSelectionAttrAlert.Item(title: "打开".localizedString, value: "on")
                    let item2 = DeviceSelectionAttrAlert.Item(title: "关闭".localizedString, value: "off")
                    let item3 = DeviceSelectionAttrAlert.Item(title: "开关切换".localizedString, value: "toggle")
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1, item2, item3])
                    if let val = controlAction.val as? String {
                        if val == "on" {
                            alert.selectedItem = item1
                        } else if val == "off" {
                            alert.selectedItem = item2
                        } else if val == "toggle" {
                            alert.selectedItem = item3
                        }
                    }
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                } else if type == .deviceStateChanged { /// 设备状态发送变化时
                    
                    let item1 = DeviceSelectionAttrAlert.Item(title: "打开".localizedString, value: "on")
                    let item2 = DeviceSelectionAttrAlert.Item(title: "关闭".localizedString, value: "off")
                    
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1, item2])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                        self.addDeviceStateChangedCondition(action_val: item.value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                    }
                    if let val = controlAction.val as? String {
                        if val == "on" {
                            alert.selectedItem = item1
                        } else if val == "off" {
                            alert.selectedItem = item2
                        }
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                }
                
            case .switch_event: /// 无状态开关
                if type == .controlDevice {  /// 控制设备
                    let item1 = DeviceSelectionAttrAlert.Item(title: "单击".localizedString, value: 0)
                    let item2 = DeviceSelectionAttrAlert.Item(title: "双击".localizedString, value: 1)
                    let item3 = DeviceSelectionAttrAlert.Item(title: "长按".localizedString, value: 2)
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1, item2, item3])
                    if let val = controlAction.val as? Int {
                        if val == 0 {
                            alert.selectedItem = item1
                        } else if val == 1 {
                            alert.selectedItem = item2
                        } else if val == 2 {
                            alert.selectedItem = item3
                        }
                    }
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                } else if type == .deviceStateChanged { /// 设备状态发送变化时
                    let item1 = DeviceSelectionAttrAlert.Item(title: "单击".localizedString, value: 0)
                    let item2 = DeviceSelectionAttrAlert.Item(title: "双击".localizedString, value: 1)
                    let item3 = DeviceSelectionAttrAlert.Item(title: "长按".localizedString, value: 2)
                    
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1, item2, item3])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                        self.addDeviceStateChangedCondition(action_val: item.value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                    }
                    if let val = controlAction.val as? Int {
                        if val == 0 {
                            alert.selectedItem = item1
                        } else if val == 1 {
                            alert.selectedItem = item2
                        } else if val == 2 {
                            alert.selectedItem = item3
                        }
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                }
                
            case .target_position: /// 窗帘位置
                let value: Int
                let maxValue = controlAction.max as? Int ?? 0
                let minValue = controlAction.min as? Int ?? 0
                if let val = (controlAction.val as? Int) {
                    value = val
                } else {
                    value = minValue
                }
                
                if type == .deviceStateChanged { /// 设备状态发送变化时
                    let item1 = DeviceSelectionAttrAlert.Item(title: "打开窗帘".localizedString, value: maxValue)
                    let item2 = DeviceSelectionAttrAlert.Item(title: "关闭窗帘".localizedString, value: minValue)
                    let item3 = DeviceSelectionAttrAlert.Item(title: "打开窗帘百分比".localizedString, value: nil)
                    let stateAlert = DeviceSelectionAttrAlert(title: "窗帘状态".localizedString, datas: [item1, item2, item3])
                    if let val = controlAction.val as? Int {
                        if val == maxValue && self.editDefaultOperator == "=" {
                            stateAlert.selectedItem = item1
                        } else if val == minValue && self.editDefaultOperator == "=" {
                            stateAlert.selectedItem = item2
                        } else {
                            stateAlert.selectedItem = item3
                        }
                    }
                    stateAlert.selectCallback = { [weak self] item in
                        guard let self = self else { return }

                        if item.title == item1.title || item.title == item2.title {
                            controlAction.val = item.value
                            self.tableView.reloadData()
                            self.addDeviceStateChangedCondition(action_val: item.value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                            
                        } else {
                            var seg = 2
                            if self.editDefaultOperator == "<" && controlAction.val != nil {
                                seg = 1
                            } else if self.editDefaultOperator == "=" && controlAction.val != nil {
                                seg = 2
                            } else if self.editDefaultOperator == ">" && controlAction.val != nil {
                                seg = 3
                            }
                            
                            let alert = DeviceCurtainStatusAttrAlert(value: value, maxValue: maxValue, minValue: minValue, segmentTag: seg)
                            alert.valueCallback = { [weak self] value,seletedTag in
                                guard let self = self else { return }
                                
                                var `operator` = ""
                                if seletedTag == 1 {
                                    `operator` = "<"
                                } else if seletedTag == 2 {
                                    `operator` = "="
                                } else if seletedTag == 3 {
                                    `operator` = ">"
                                }
                                
                                self.addDeviceStateChangedCondition(action_val: value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: `operator`, type: controlAction.type)
                                
                            }
                            SceneDelegate.shared.window?.addSubview(alert)
                        }
                        
                        stateAlert.removeFromSuperview()
                        
                    }
                    SceneDelegate.shared.window?.addSubview(stateAlert)

                    
                    
                } else {  /// 控制设备
                    let item1 = DeviceSelectionAttrAlert.Item(title: "打开窗帘".localizedString, value: maxValue)
                    let item2 = DeviceSelectionAttrAlert.Item(title: "关闭窗帘".localizedString, value: minValue)
                    let item3 = DeviceSelectionAttrAlert.Item(title: "打开窗帘百分比".localizedString, value: nil)
                    let stateAlert = DeviceSelectionAttrAlert(title: "窗帘状态".localizedString, datas: [item1, item2, item3])
                    if let val = controlAction.val as? Int {
                        if val == maxValue {
                            stateAlert.selectedItem = item1
                        } else if val == minValue {
                            stateAlert.selectedItem = item2
                        } else {
                            stateAlert.selectedItem = item3
                        }
                    }
                    stateAlert.selectCallback = { [weak self] item in
                        guard let self = self else { return }

                        if item.title == item1.title || item.title == item2.title {
                            controlAction.val = item.value
                            self.tableView.reloadData()
                            
                            
                        } else {
                            let alert = DeviceCurtainStatusAttrAlert(value: value, maxValue: maxValue, minValue: minValue, segmentTag: 0)
                            alert.valueCallback = { [weak self] value, seletedTag in
                                guard let self = self else { return }
                                controlAction.val = value
                                self.tableView.reloadData()
                            }
                            SceneDelegate.shared.window?.addSubview(alert)
                        }
                        
                        stateAlert.removeFromSuperview()
                        
                    }
                    SceneDelegate.shared.window?.addSubview(stateAlert)
                    
                }
                
                
                
                
            case .rgb: /// 色彩
                if type == .deviceStateChanged { /// 设备状态发送变化时
                    let val = controlAction.val as? String ?? "#FFFFFF"
                    let hsbColor = UIColor(hex: val)?.hsbColor ?? UIColor.white.hsbColor
                    let alert = DeviceRGBAlert(color: hsbColor)
                    alert.colorPaletteCallback = { [weak self] hsbColor in
                        guard let self = self else { return }
                        controlAction.val = hsbColor.toUIColor().hexString
                        tableView.reloadData()
                        self.addDeviceStateChangedCondition(action_val: hsbColor.toUIColor().hexString, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                        
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                } else {  /// 控制设备
                    let val = controlAction.val as? String ?? "#FFFFFF"
                    let hsbColor = UIColor(hex: val)?.hsbColor ?? UIColor.white.hsbColor
                    let alert = DeviceRGBAlert(color: hsbColor)
                    alert.colorPaletteCallback = { hsbColor in
                        controlAction.val = hsbColor.toUIColor().hexString
                        tableView.reloadData()
                        
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                }
                
                
            case .humidity: /// 湿度
                let value: Int
                let maxValue = controlAction.max as? Int ?? 0
                let minValue = controlAction.min as? Int ?? 0
                if let val = (controlAction.val as? Int) {
                    value = val
                } else {
                    value = minValue
                }

                if type == .deviceStateChanged { /// 设备状态发送变化时
                    var seg = 2
                    if editDefaultOperator == "<" && controlAction.val != nil {
                        seg = 1
                    } else if editDefaultOperator == "=" && controlAction.val != nil {
                        seg = 2
                    } else if editDefaultOperator == ">" && controlAction.val != nil {
                        seg = 3
                    }

                    let alert = DeviceBrightnessAttrAlert(value: value, maxValue: maxValue, minValue: minValue, segmentTag: seg)
                    alert.valueCallback = { [weak self] value,seletedTag in
                        guard let self = self else { return }
                        var `operator` = ""
                        if seletedTag == 1 {
                            `operator` = "<"
                        } else if seletedTag == 2 {
                            `operator` = "="
                        } else if seletedTag == 3 {
                            `operator` = ">"
                        }
                        
                        self.addDeviceStateChangedCondition(action_val: value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: `operator`, type: controlAction.type)
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                } else {  /// 控制设备
                    let alert = DeviceBrightnessAttrAlert(value: value, maxValue: maxValue, minValue: minValue, segmentTag: 0)
                    alert.valueCallback = { value, seletedTag in
                        controlAction.val = value
                        tableView.reloadData()

                    }
                    
                    SceneDelegate.shared.window?.addSubview(alert)
                }
                
                
            case .temperature: /// 温度
                let value: Float
                let maxValue = controlAction.max as? Float ?? 0
                let minValue = controlAction.min as? Float ?? 0
                if let val = (controlAction.val as? Float) {
                    value = val
                } else {
                    value = 0
                }

                if type == .deviceStateChanged { /// 设备状态发送变化时
                    var seg = 2
                    if editDefaultOperator == "<" && controlAction.val != nil {
                        seg = 1
                    } else if editDefaultOperator == "=" && controlAction.val != nil {
                        seg = 2
                    } else if editDefaultOperator == ">" && controlAction.val != nil {
                        seg = 3
                    }

                    let alert = DeviceTemperatureAttrAlert(value: value, maxValue: maxValue, minValue: minValue, segmentTag: seg)
                    alert.valueCallback = { [weak self] value,seletedTag in
                        guard let self = self else { return }
                        var `operator` = ""
                        if seletedTag == 1 {
                            `operator` = "<"
                        } else if seletedTag == 2 {
                            `operator` = "="
                        } else if seletedTag == 3 {
                            `operator` = ">"
                        }
                        
                        self.addDeviceStateChangedCondition(action_val: value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: `operator`, type: controlAction.type)
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                } else {  /// 控制设备
                    let alert = DeviceTemperatureAttrAlert(value: value, maxValue: maxValue, minValue: minValue, segmentTag: 0)
                    alert.valueCallback = { value, seletedTag in
                        controlAction.val = value
                        tableView.reloadData()

                    }
                    
                    SceneDelegate.shared.window?.addSubview(alert)
                }
                
            case .motion_detected: /// 人体传感器
                if type == .deviceStateChanged { /// 设备状态发送变化时
                    let item1 = DeviceSelectionAttrAlert.Item(title: "检测到动作时".localizedString, value: 1)
                    
                    let alert = DeviceSelectionAttrAlert(title: "开关".localizedString, datas: [item1])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                        self.addDeviceStateChangedCondition(action_val: item.value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                    }
                    
                    if let val = controlAction.val as? Int, val == 1 {
                        alert.selectedItem = item1
                    }
                    
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                } else { /// 控制设备
                    let item1 = DeviceSelectionAttrAlert.Item(title: "检测到动作时".localizedString, value: 1)
                    
                    let alert = DeviceSelectionAttrAlert(title: "状态".localizedString, datas: [item1])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                        self.addDeviceStateChangedCondition(action_val: item.value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                    }
                    
                    if let val = controlAction.val as? Int, val == 1 {
                        alert.selectedItem = item1
                    }
                    
                    SceneDelegate.shared.window?.addSubview(alert)
                }
                
            case .leak_detected: /// 水浸传感器
                if type == .deviceStateChanged { /// 设备状态发送变化时
                    let item1 = DeviceSelectionAttrAlert.Item(title: "检测到浸水时".localizedString, value: 1)
            
                    
                    let alert = DeviceSelectionAttrAlert(title: "状态".localizedString, datas: [item1])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                        self.addDeviceStateChangedCondition(action_val: item.value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                    }
                    
                    if let val = controlAction.val as? Int, val == 1 {
                        alert.selectedItem = item1
                    }
                    
                    SceneDelegate.shared.window?.addSubview(alert)
                } else { /// 控制设备
                    let item1 = DeviceSelectionAttrAlert.Item(title: "检测到浸水时".localizedString, value: 1)
            
                    
                    let alert = DeviceSelectionAttrAlert(title: "状态".localizedString, datas: [item1])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                    }
                    
                    if let val = controlAction.val as? Int, val == 1 {
                        alert.selectedItem = item1
                    }
                    
                    SceneDelegate.shared.window?.addSubview(alert)
                }
                
            case .contact_sensor_state: /// 门窗传感器
                if type == .deviceStateChanged { /// 设备状态发送变化时
                    let item1 = DeviceSelectionAttrAlert.Item(title: "由关闭变为打开时".localizedString, value: 1)
                    let item2 = DeviceSelectionAttrAlert.Item(title: "由打开变为关闭时".localizedString, value: 0)
            
                    
                    let alert = DeviceSelectionAttrAlert(title: "状态".localizedString, datas: [item1, item2])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                        self.addDeviceStateChangedCondition(action_val: item.value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                    }
                    
                    if let val = controlAction.val as? Int {
                        if val == 1 {
                            alert.selectedItem = item1
                        } else {
                            alert.selectedItem = item2
                        }
                        
                    }
                    
                    SceneDelegate.shared.window?.addSubview(alert)
                } else { /// 控制设备
                    let item1 = DeviceSelectionAttrAlert.Item(title: "由关闭变为打开时".localizedString, value: 1)
                    let item2 = DeviceSelectionAttrAlert.Item(title: "由打开变为关闭时".localizedString, value: 0)
            
                    
                    let alert = DeviceSelectionAttrAlert(title: "状态".localizedString, datas: [item1, item2])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                    }
                    
                    if let val = controlAction.val as? Int {
                        if val == 1 {
                            alert.selectedItem = item1
                        } else {
                            alert.selectedItem = item2
                        }
                        
                    }
                    
                    SceneDelegate.shared.window?.addSubview(alert)
                }
                
                
            case .target_state:
                if type == .deviceStateChanged { /// 设备状态发送变化时
                    let item1 = DeviceSelectionAttrAlert.Item(title: "开启在家模式".localizedString, value: 0)
                    let item2 = DeviceSelectionAttrAlert.Item(title: "开启离家模式".localizedString, value: 1)
                    let item3 = DeviceSelectionAttrAlert.Item(title: "开启睡眠模式".localizedString, value: 2)
                    let item4 = DeviceSelectionAttrAlert.Item(title: "关闭守护模式".localizedString, value: 3)
                    
                    let alert = DeviceSelectionAttrAlert(title: "守护".localizedString, datas: [item1, item2, item3, item4])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                        self.addDeviceStateChangedCondition(action_val: item.value, permission: controlAction.permission, val_type: controlAction.val_type, max: controlAction.max, min: controlAction.min, aid: controlAction.aid, operator: "=", type: controlAction.type)
                    }
                    
                    if let val = controlAction.val as? Int {
                        if val == 0 {
                            alert.selectedItem = item1
                        } else if val == 1 {
                            alert.selectedItem = item2
                        } else if val == 2 {
                            alert.selectedItem = item3
                        } else if val == 3 {
                            alert.selectedItem = item4
                        }
                        
                    }
                    
                    SceneDelegate.shared.window?.addSubview(alert)
                } else { /// 控制设备
                    let item1 = DeviceSelectionAttrAlert.Item(title: "开启在家模式".localizedString, value: 0)
                    let item2 = DeviceSelectionAttrAlert.Item(title: "开启离家模式".localizedString, value: 1)
                    let item3 = DeviceSelectionAttrAlert.Item(title: "开启睡眠模式".localizedString, value: 2)
                    let item4 = DeviceSelectionAttrAlert.Item(title: "关闭守护模式".localizedString, value: 3)
            
                    
                    let alert = DeviceSelectionAttrAlert(title: "守护".localizedString, datas: [item1, item2, item3, item4])
                    alert.selectCallback = { item in
                        controlAction.val = item.value
                        tableView.reloadData()
                        
                    }
                    
                    if let val = controlAction.val as? Int {
                        if val == 0 {
                            alert.selectedItem = item1
                        } else if val == 1 {
                            alert.selectedItem = item2
                        } else if val == 2 {
                            alert.selectedItem = item3
                        } else if val == 3 {
                            alert.selectedItem = item4
                        }
                        
                    }
                    
                    SceneDelegate.shared.window?.addSubview(alert)
                }
                
            default:
                break
            }
            
        } else {
            SceneDelegate.shared.window?.addSubview(datePicker)
        }
    }
    
    
    
}




