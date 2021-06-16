//
//  SceneSetDeviceViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/25.
//

import UIKit

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
            self?.deviceControlActions.forEach { $0.action_val = "" }
            self?.delayCell.valueLabel.text = " "
            self?.tableView.reloadData()

        }
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.register(ValueDetailCell.self, forCellReuseIdentifier: ValueDetailCell.reusableIdentifier)
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
    
    var actionAlert: VarietyAlertView?

    
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
    private func addDeviceStateChangedCondition(action: String, action_val: String, operator: String, attr: String) {

        let condition = SceneCondition()
        condition.condition_type = 2
        condition.device_id = device_id
        let item = SceneConditionItem()
        item.action = action
        item.action_val = action_val
        item.operator = `operator`
        item.attribute = attr
        condition.condition_item = item
        
        let device_info = SceneDetailDeviceInfo()
        device_info.name = device?.name ?? ""
        device_info.location_name = device?.location.name ?? ""
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
        if deviceControlActions.filter({ $0.action_val != ""}).count == 0 {
            showToast(string: "请先设置控制项")
            return
        }
        
        let task = SceneTask()
        task.type = 1
        
        let scene_task_devices = deviceControlActions
            .filter({ $0.action_val != ""})
            .map { control -> SceneTaskPerformItem in
                let item = SceneTaskPerformItem()
                item.action = control.action
                item.action_val = control.action_val
                item.device_id = device_id
                item.attribute = control.attribute
                return item
            }
        task.scene_task_devices = scene_task_devices
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
        device_info.location_name = device?.location.name ?? ""

        task.device_info = device_info

        addControlDeviceCallback?(task)
        if let count = self.navigationController?.viewControllers.count, count - 2 > 0 && !isEdit {
            self.navigationController?.viewControllers.remove(at: count - 2)
        }
        navigationController?.popViewController(animated: true)
    }
}

extension SceneSetDeviceViewController {
    
    private class DeviceInfoResponse: BaseModel {
        var device_info = Device()
    }
    
    
    private func requestNetwork() {
        apiService.requestModel(.deviceDetail(device_id: device_id), modelType: DeviceInfoResponse.self) { [weak self] response in
            guard let self = self else { return }
            self.deviceControlActions = response.device_info.actions.map({ (deviceAction) -> SceneDeviceControlAction in
                let control = SceneDeviceControlAction()
                control.action = deviceAction.action
                control.name = deviceAction.name
                control.attribute = deviceAction.attr
                return control
            })
            
            if let defaultActions = self.editDefaultActions { /// 编辑时默认赋值
                defaultActions.forEach { `default` in
                    if let action = self.deviceControlActions.first(where: { $0.action == `default`.action }) {
                        action.action_val = `default`.action_val
                        action.operator = `default`.operator
                        
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
            let cell = tableView.dequeueReusableCell(withIdentifier: ValueDetailCell.reusableIdentifier, for: indexPath) as! ValueDetailCell
            let controlAction = deviceControlActions[indexPath.row]
            cell.title.text = controlAction.name
            cell.valueLabel.text = controlAction.displayActionValue

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
            case .set_bright:
                let value = CGFloat((Double(controlAction.action_val) ?? 0.0) / 100)
                if type == .deviceStateChanged {
                    var seg = 2
                    if controlAction.operator == "<" {
                        seg = 1
                    } else if controlAction.operator == "=" {
                        seg = 2
                    } else if controlAction.operator == ">" {
                        seg = 3
                    }
                    actionAlert = VarietyAlertView(title: "亮度", type: .lightDegreeType(value: value, segmentSegmentTag: seg))
                } else {
                    actionAlert = VarietyAlertView(title: "亮度", type: .lightDegreeType(value: value, segmentSegmentTag: 0))
                }
                
                actionAlert?.valueCallback = { [weak self] value,seletedTag in
                    guard let self = self else { return }
                    if self.type == .deviceStateChanged {
                        if seletedTag == 1 {
                            controlAction.operator = "<"
                        } else if seletedTag == 2 {
                            controlAction.operator = "="
                        } else if seletedTag == 3 {
                            controlAction.operator = ">"
                        }
                        
                        self.addDeviceStateChangedCondition(action: controlAction.action, action_val: String(Int(value * 100)), operator: controlAction.operator, attr: controlAction.attribute)
                    } else {
                        controlAction.action_val = String(Int(value * 100))
                        tableView.reloadData()
                    }
                }
                SceneDelegate.shared.window?.addSubview(actionAlert!)

            case .set_color_temp:
                let value = CGFloat((Double(controlAction.action_val) ?? 0.0) / 100)
                if type == .deviceStateChanged {
                    var seg = 2
                    if controlAction.operator == "<" {
                        seg = 1
                    } else if controlAction.operator == "=" {
                        seg = 2
                    } else if controlAction.operator == ">" {
                        seg = 3
                    }
                    actionAlert = VarietyAlertView(title: "色温", type: .colorTemperatureType(value: value, segmentSegmentTag: seg))
                } else {
                    actionAlert = VarietyAlertView(title: "色温", type: .colorTemperatureType(value: value, segmentSegmentTag: 0))
                }

                
                actionAlert?.valueCallback = { [weak self] value,seletedTag in
                    guard let self = self else { return }
                    if self.type == .deviceStateChanged {
                        if seletedTag == 1 {
                            controlAction.operator = "<"
                        } else if seletedTag == 2 {
                            controlAction.operator = "="
                        } else if seletedTag == 3 {
                            controlAction.operator = ">"
                        }
                        
                        self.addDeviceStateChangedCondition(action: controlAction.action, action_val: String(Int(value * 100)), operator: controlAction.operator, attr: controlAction.attribute)
                    } else {
                        controlAction.action_val = String(Int(value * 100))
                        tableView.reloadData()
                    }
                }
                SceneDelegate.shared.window?.addSubview(actionAlert!)
            case .switch:
                if type == .controlDevice {
                    actionAlert = VarietyAlertView(title: "开关", type: .tableViewType(data: ["打开".localizedString, "关闭".localizedString, "开关切换".localizedString]))
                    actionAlert?.selectedIndex = -1
                    
                    if controlAction.action_val == "on" {
                        actionAlert?.selectedIndex = 0
                    } else if controlAction.action_val == "off" {
                        actionAlert?.selectedIndex = 1
                    } else if controlAction.action_val == "toggle" {
                        actionAlert?.selectedIndex = 2
                    }
                    
                    actionAlert?.selectCallback = { [weak self] index in
                        guard let self = self else { return }
                        if self.type == .deviceStateChanged {
                            var value = "on"
                            if index == 0 {
                                value = "on"
                            } else if index == 1 {
                                value = "off"
                            } else {
                                value = "toggle"
                            }
                            self.addDeviceStateChangedCondition(action: controlAction.action, action_val: value, operator: controlAction.operator, attr:  controlAction.attribute)
                        } else {
                            var value = "on"
                            if index == 0 {
                                value = "on"
                            } else if index == 1 {
                                value = "off"
                            } else {
                                value = "toggle"
                            }
                            controlAction.action_val = value
                            tableView.reloadData()
                        }
                    }
                    SceneDelegate.shared.window?.addSubview(actionAlert!)
                } else if type == .deviceStateChanged {

                    actionAlert = VarietyAlertView(title: "开关", type: .tableViewType(data: ["打开".localizedString, "关闭".localizedString]))
                    actionAlert?.selectedIndex = -1
                    
                    if controlAction.action_val == "on" {
                        actionAlert?.selectedIndex = 0
                    } else if controlAction.action_val == "off" {
                        actionAlert?.selectedIndex = 1
                    } else if controlAction.action_val == "toggle" {
                        actionAlert?.selectedIndex = 2
                    }
                    

                    actionAlert?.selectCallback = { [weak self] index in
                        guard let self = self else { return }
                        if self.type == .deviceStateChanged {
                            var value = "on"
                            if index == 0 {
                                value = "on"
                            } else {
                                value = "off"
                            }
                            self.addDeviceStateChangedCondition(action: controlAction.action, action_val: value, operator: controlAction.operator, attr: controlAction.attribute)
                        } else {
                            var value = "on"
                            if index == 0 {
                                value = "on"
                            } else {
                                value = "off"
                            }
                            controlAction.action_val = value
                            tableView.reloadData()
                        }
                    }
                    SceneDelegate.shared.window?.addSubview(actionAlert!)
                }
                
                
                
                
            default:
                break
            }
        } else {
            SceneDelegate.shared.window?.addSubview(datePicker)
        }
    }
    
    
    
}

extension SceneSetDeviceViewController {
    class SceneDeviceControlAction: BaseModel {
        enum ControlActionType: String {
            /// 开关
            case `switch`
            /// 亮度
            case set_bright
            /// 色温
            case set_color_temp
            
            case none
        }

        var name = ""
        var action = ""
        var action_val = ""
        var `operator` = "="
        var attribute = ""
        
        var controlActionType: ControlActionType {
            return ControlActionType(rawValue: action) ?? .none
        }
        
        var actionName: String {
            switch controlActionType {
            case .switch:
                return "开关".localizedString
            case .set_bright:
                return "亮度".localizedString
            case .set_color_temp:
                return  "色温".localizedString
            default:
                return ""
            }
        }
        
        var displayActionValue: String {
            if action_val == "" {
                return " "
            }

            if action == "switch" {
                if action_val == "on" {
                    return "打开".localizedString
                } else if action_val == "off" {
                    return "关闭".localizedString
                } else if action_val == "toggle" {
                    return "开关切换".localizedString
                }
            } else if action == "set_bright" {
                return "\(action_val)%"
                
            } else if action == "set_color_temp" {
                return "\(action_val)%"
            }
            
            return " "
        }
        
    }

}



