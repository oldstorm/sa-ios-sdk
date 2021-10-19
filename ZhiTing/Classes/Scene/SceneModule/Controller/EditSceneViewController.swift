//
//  EditSceneViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/12.
//

import UIKit
import IQKeyboardManagerSwift


class EditSceneViewController: BaseViewController {
    enum SceneType {
        case edit
        case create
    }
    
    var scene: SceneDetailModel = SceneDetailModel() {
        didSet {
            compareScene = scene.toJSONString() ?? ""
            reloadSceneDetail()
        }
       
        
    }
    
    var firstIn = true

    var compareScene: String = ""
    
    let type: SceneType
    
    var scene_id: Int?

    init(type: SceneType) {
        self.type = type
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private var currentSceneList: SceneListModel?

    private lazy var inputHeader = SceneInputHeader(placeHolder: "场景名".localizedString)
    private lazy var addConditionCell = EditSceneAddCell().then {
        $0.titleLabel.text = "添加触发条件".localizedString
    }
    private lazy var addActionCell = EditSceneAddCell().then {
        $0.titleLabel.text = "添加执行任务".localizedString
    }
    
    private lazy var addConditionAlert = EditSceneAddAlertView(
        title: "添加触发条件".localizedString,
        items: [
            .init(image: .assets(.icon_condition_manual), title: "手动执行".localizedString, detail: "点击即可执行".localizedString),
            .init(image: .assets(.icon_condition_timer), title: "定时".localizedString, detail: "如每天8点".localizedString),
            .init(image: .assets(.icon_condition_state), title: "设备状态变化时".localizedString, detail: "如打开灯时，感应到人时".localizedString)
        ])
    
    private lazy var addActionAlert = EditSceneAddAlertView(
        title: "添加执行任务".localizedString,
        items: [
            .init(image: .assets(.icon_smart_device), title: "智能设备".localizedString, detail: "如开灯、播放音乐".localizedString),
            .init(image: .assets(.icon_control_scene), title: "控制场景".localizedString, detail: "如开启夏季晚会场景".localizedString),
            
        ])
    
    private lazy var conditionHeader = EditSceneSectionHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: ZTScaleValue(50)),type: .condition)
    
    private lazy var actionHeader = EditSceneSectionHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: ZTScaleValue(50)),type: .action)
        
    private lazy var conditionRelationshipAlert = VarietyAlertView(title: "请选择多条件关系".localizedString, type: .tableViewType(data: ["满足所有条件".localizedString, "满足任一条件".localizedString]))
    
    private lazy var controlSceneAlert = VarietyAlertView(title: "控制场景".localizedString, type: .tableViewType(data: ["执行某条场景".localizedString, "开启自动执行".localizedString, "关闭自动执行".localizedString])).then {
        $0.selectedIndex = -1
    }
    
    private lazy var datePicker = SceneConditionPickerView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight)).then {
        $0.pickerCallback = { [weak self] time in
            guard let self = self else { return }
            let timerCondition = SceneCondition()
            timerCondition.condition_type = 1
            timerCondition.timing = time
            self.scene.scene_conditions.append(timerCondition)
            self.tableView.reloadData()
        }
    }
    
    private lazy var editDatePicker = SceneConditionPickerView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight)).then {
        $0.pickerCallback = { [weak self] time in
            guard let self = self else { return }
            if let timerCondition = self.scene.scene_conditions.first(where: { $0.condition_type == 1}) {
                timerCondition.condition_type = 1
                timerCondition.timing = time
                self.tableView.reloadData()
            }
            
            
        }
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.dataSource = self
        $0.delegate = self
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.sectionFooterHeight = 0
        $0.register(SceneConditionCell.self, forCellReuseIdentifier: SceneConditionCell.reusableIdentifier)
        $0.register(SceneTaskCell.self, forCellReuseIdentifier: SceneTaskCell.reusableIdentifier)
    }
    
    
    lazy var saveButton = CustomButton(buttonType:
                                                    .leftLoadingRightTitle(
                                                        normalModel:
                                                            .init(
                                                                title: "完成".localizedString,
                                                                titleColor: UIColor.custom(.white_ffffff).withAlphaComponent(1),
                                                                font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                                bagroundColor: UIColor.custom(.blue_2da3f6).withAlphaComponent(1)
                                                            ),
                                                        lodingModel:
                                                            .init(
                                                                title: "保存中...".localizedString,
                                                                titleColor: UIColor.custom(.white_ffffff).withAlphaComponent(0.7),
                                                                font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                                bagroundColor: UIColor.custom(.blue_2da3f6).withAlphaComponent(0.7)
                                                            )
                                                    )
    ).then {
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.addTarget(self, action: #selector(onClickDone), for: .touchUpInside)
    }

    private lazy var deleteButton = Button().then {
        $0.setTitle("删除".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .regular)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
    }
    
    private lazy var timeEffectCell = EditSceneEffectiveCell()

    var tipsAlert: TipsAlertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if type == .edit {
            checkAuth()
            requestSceneDetail()
        } else {
            compareScene = scene.toJSONString() ?? ""
        }
    }
    
    override func navPop() {
        var ifAfterEdit = false
        scene.name = inputHeader.textField.text ?? ""
        if let json1 = scene.toJSONString()?.sorted() {
            let json2 = compareScene.sorted()
            if json1.count != json2.count || json1 != json2 {
                ifAfterEdit = true
            }
        }


        if ifAfterEdit {
            TipsAlertView.show(message: "退出后修改将丢失,是否退出".localizedString) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = (type == .edit) ? "修改场景".localizedString : "创建场景".localizedString
        if type == .edit {
            navigationItem.rightBarButtonItem = .init(customView: deleteButton)
        }
        
        requestNetwork()
        IQKeyboardManager.shared.enableAutoToolbar = true

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
        
    }
    
    @objc private func onClickDone() {
        if self.type == .create {
            self.createScene()
        } else {
            self.editScene()
        }
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(inputHeader)
        view.addSubview(tableView)
        view.addSubview(saveButton)
        if type == .edit {
            
            deleteButton.clickCallBack = { [weak self] _ in
                self?.tipsAlert = TipsAlertView.show(message: "是否确定删除场景?", sureCallback: { [weak self] in
                    self?.deleteScene()
                }, cancelCallback: nil, removeWithSure: false)
            }
        }
        
        conditionHeader.plusButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            if self.scene.scene_conditions.count == 1 {
                self.updateRelationshipAlertState()
                SceneDelegate.shared.window?.addSubview(self.conditionRelationshipAlert)
            } else {
                self.updateConditionAlertState()
                SceneDelegate.shared.window?.addSubview(self.addConditionAlert)
            }
            
        }
        
        conditionHeader.detailTapCallback = { [weak self] in
            guard let self = self else { return }
            self.updateRelationshipAlertState()
            SceneDelegate.shared.window?.addSubview(self.conditionRelationshipAlert)
        }
        
        actionHeader.plusButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            SceneDelegate.shared.window?.addSubview(self.addActionAlert)
        }
        
        

        
        addConditionAlert.selectCallback = { [weak self] index in
            guard let self = self else { return }
            switch index {
            case 0:
                /// 手动执行
                let manualCondition = SceneCondition()
                manualCondition.condition_type = 0
                self.scene.scene_conditions.append(manualCondition)
                self.scene.condition_logic = nil
                self.tableView.reloadData()
            case 1:
                /// 定时
                SceneDelegate.shared.window?.addSubview(self.datePicker)
                
            case 2:
                /// 设备状态变化时
                let vc = AddDeviceViewController(type: .deviceStateChanged)
                vc.addDeviceConditionChangedCallback = { condition in
                    self.scene.scene_conditions.append(condition)
                    self.tableView.reloadData()
                    
                }

                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
            
        }

        addActionAlert.selectCallback = { [weak self] index in
            guard let self = self else { return }
            if index == 0 {
                //添加智能设备
                let addDeviceVC = AddDeviceViewController(type: .controlDevice)
                addDeviceVC.addControlDeviceCallback = { [weak self] task in
                    guard let self = self else { return }
                    self.scene.scene_tasks.append(task)
                    self.tableView.reloadData()
                }
                self.navigationController?.pushViewController(addDeviceVC, animated: true)
                
            } else {
                self.controlSceneAlert.selectedIndex = -1
                self.controlSceneAlert.tableView.reloadData()
                SceneDelegate.shared.window?.addSubview(self.controlSceneAlert)
            }
            
        }
        
        controlSceneAlert.selectCallback = { [weak self] index in
            guard let self = self else { return }
            
            if self.currentSceneList != nil {
                let vc: ControlSceneViewController
                if index == 0 {
                    //执行某条场景
                    vc = ControlSceneViewController(type: .excute)
                    vc.currentSceneData = self.currentSceneList?.manual.filter({ $0.control_permission == true}) ?? []
                    
                }else if index == 1{
                    //开启自动执行
                    vc = ControlSceneViewController(type: .openAuto)
                    vc.currentSceneData = self.currentSceneList?.auto_run.filter({ $0.control_permission == true}) ?? []
                    
                } else {
                    //关闭自动执行
                    vc = ControlSceneViewController(type: .closeAuto)
                    vc.currentSceneData = self.currentSceneList?.auto_run.filter({ $0.control_permission == true}) ?? []
                    
                }
                
                vc.tasksCallback = { [weak self] tasks in
                    guard let self = self else { return }
                    self.scene.scene_tasks.append(contentsOf: tasks)
                    self.tableView.reloadData()
                }

                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        /// 条件满足选择
        conditionRelationshipAlert.selectCallback = { [weak self] index in
            guard let self = self else { return }
            if index == 0 {
                self.conditionHeader.conditionRelationshipType = .all
                self.scene.condition_logic = 1
                if self.scene.scene_conditions.count == 1 {
                    self.updateConditionAlertState()
                    SceneDelegate.shared.window?.addSubview(self.addConditionAlert)
                }
               
               
            } else {
                self.conditionHeader.conditionRelationshipType = .any
                self.scene.condition_logic = 2
                if self.scene.scene_conditions.count == 1 {
                    self.updateConditionAlertState()
                    SceneDelegate.shared.window?.addSubview(self.addConditionAlert)
                }
                
            }
        }
        
    }

    override func setupConstraints() {
        inputHeader.snp.makeConstraints {
            $0.right.left.equalToSuperview()
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
        }
        
        saveButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
        }
    
        tableView.snp.makeConstraints {
            $0.top.equalTo(inputHeader.snp.bottom)
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.bottom.equalTo(saveButton.snp.top).offset(ZTScaleValue(-10))
        }
        

        
    }
    
    
    private func reloadSceneDetail() {
        inputHeader.textField.text = scene.name

        if let startTime = scene.effect_start_time, let endTime = scene.effect_end_time {
            let format = DateFormatter()
            format.dateStyle = .medium
            format.timeStyle = .medium
            format.dateFormat = "HH:mm:ss"
            let date1 = Date(timeIntervalSince1970: TimeInterval(startTime))
            let date2 = Date(timeIntervalSince1970: TimeInterval(endTime))
            let str1 = format.string(from: date1)
            let str2 = format.string(from: date2)
            timeEffectCell.valueLabel.text = str1 + " - " + str2
        }
        
        if scene.time_period == 1 {
            timeEffectCell.valueLabel.text = "全天".localizedString
        }
        
        if scene.condition_logic == 1 { // 满足所有
            conditionHeader.conditionRelationshipType = .all
            conditionRelationshipAlert.selectedIndex = 0
        } else if scene.condition_logic == 2 { // 满足任一
            conditionHeader.conditionRelationshipType = .any
            conditionRelationshipAlert.selectedIndex = 1
        }

        if scene.repeat_type == 1 {
            timeEffectCell.detailLabel.text = "每天".localizedString
        } else if scene.repeat_type == 2 {
            timeEffectCell.detailLabel.text = "周一至周五".localizedString
        } else if scene.repeat_type == 3 {
            var strs = [String]()
            scene.repeat_date.forEach { char in
                switch char {
                case "1":
                    strs.append("周一".localizedString)
                case "2":
                    strs.append("周二".localizedString)
                case "3":
                    strs.append("周三".localizedString)
                case "4":
                    strs.append("周四".localizedString)
                case "5":
                    strs.append("周五".localizedString)
                case "6":
                    strs.append("周六".localizedString)
                case "7":
                    strs.append("周日".localizedString)
                default:
                    break
                }
            }
            
            timeEffectCell.detailLabel.text = strs.joined(separator: "、")
        }
        
        
        tableView.reloadData()
    }
    
    private func checkAuth() {
        deleteButton.isHidden = !(authManager.currentRolePermissions.delete_scene)
        if !authManager.currentRolePermissions.update_scene {
            saveButton.isHidden = true
            tableView.snp.remakeConstraints {
                $0.top.equalTo(inputHeader.snp.bottom)
                $0.bottom.equalToSuperview()
                $0.left.equalToSuperview().offset(ZTScaleValue(15))
                $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.view.alpha = 0.5
                self.view.isUserInteractionEnabled = false
            }
        }
        
        
        
        
    }
    
    private func updateConditionAlertState() {
        addConditionAlert.items.first?.isEnable = !(scene.scene_conditions.filter({ $0.condition_type != 0 }).count > 0)
        if addConditionAlert.items.count > 2 {
            if scene.scene_conditions.contains(where: { $0.condition_type == 1 }) && scene.condition_logic == 1 {
                addConditionAlert.items[1].isEnable = false
            } else {
                addConditionAlert.items[1].isEnable = true
            }
        }
        
        if type == .edit && scene.auto_run == true {
            addConditionAlert.items.first?.isEnable = false
        }
        
        addConditionAlert.reloadData()
    }
    
    
    private func updateRelationshipAlertState() {
        
        if scene.scene_conditions.filter({ $0.condition_type == 1}).count > 1 {
            conditionRelationshipAlert.disableIndexs = [0]
        } else {
            conditionRelationshipAlert.disableIndexs = []
        }
    }
}

extension EditSceneViewController {
    private func requestNetwork() {
        
        self.currentSceneList = nil
        
        ApiServiceManager.shared.sceneList(type: 0) {[weak self]  (respond) in
            guard let self = self else { return }
            self.tableView.isHidden = false
            let list = SceneListModel()
            list.auto_run = respond.auto_run
            list.manual = respond.manual

            list.manual.forEach {
                $0.isSelected = false
            }
            list.auto_run.forEach {
                $0.isSelected = false
            }
            self.currentSceneList = list

        } failureCallback: {(code, err) in
            print("\(err)")
        }
    }

}

// MARK: - UITableView Delegate & Datasource
extension EditSceneViewController: UITableViewDelegate, UITableViewDataSource {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return conditionHeader
        } else if section == 1 {
            return actionHeader
        } else {
            let view = UIView()
            view.backgroundColor = .custom(.gray_f6f8fd)
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if scene.scene_conditions.count == 0 {
                return 0
            } else {
                return ZTScaleValue(60)
            }
        } else if section == 1 {
            if scene.scene_tasks.count == 0 {
                return 0
            } else {
                return ZTScaleValue(60)
            }
        } else {
            return ZTScaleValue(20)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if scene.scene_conditions.count != 0 {
                return ZTScaleValue(70)
            }
            return ZTScaleValue(170)
            
        } else if indexPath.section == 1 {
            if scene.scene_tasks.count != 0 {
                return ZTScaleValue(70)
            }
            return ZTScaleValue(170)
        } else {
            return UITableView.automaticDimension
        }
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            conditionHeader.plusButton.isHidden = (scene.scene_conditions.filter({ $0.condition_type == 0 }).count > 0)

            
            if scene.scene_conditions.count > 1 {
                conditionHeader.detailLabel.isHidden = false
                conditionHeader.arrowDown.isHidden = false
                conditionHeader.titleLabel.snp.updateConstraints {
                    $0.top.equalToSuperview()
                }
                conditionHeader.detailLabel.snp.updateConstraints {
                    $0.height.equalTo(ZTScaleValue(12))
                }
                
            
            } else {
                conditionHeader.detailLabel.isHidden = true
                conditionHeader.arrowDown.isHidden = true
                conditionHeader.titleLabel.snp.updateConstraints {
                    $0.top.equalToSuperview().offset(ZTScaleValue(7.5))
                }
                conditionHeader.detailLabel.snp.updateConstraints {
                    $0.height.equalTo(ZTScaleValue(1))
                }
            }
            
            if scene.scene_conditions.count == 0 {
                return 1
            } else {
                return scene.scene_conditions.count
            }
        } else if section == 1 {
            if scene.scene_tasks.count == 0 {
                return 1
            } else {
                return scene.scene_tasks.count
            }
        } else {
            if scene.scene_tasks.count > 0 && scene.scene_conditions.first?.condition_type != 0 {
                return 1
            }
            return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if scene.scene_conditions.count == 0 {
                return addConditionCell

            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: SceneConditionCell.reusableIdentifier, for: indexPath) as! SceneConditionCell
                cell.condition = scene.scene_conditions[indexPath.row]
                cell.setRoundedDel(indexPath.row == scene.scene_conditions.count - 1)
                cell.deletionCallback = { [weak self] in
                    guard let self = self else { return }
                    if indexPath.section == 0 {
                        if self.type == .edit ,let id = self.scene.scene_conditions[indexPath.row].id {
                            self.scene.del_condition_ids?.append(id)
                        }
                        if self.scene.scene_conditions.count > indexPath.row {
                            self.scene.scene_conditions.remove(at: indexPath.row)
                        }
                        
                        if self.scene.scene_conditions.count <= 1 {
                            self.scene.condition_logic = nil
                        }
                        
                    } else if indexPath.section == 1 {
                        if self.type == .edit ,let id = self.scene.scene_tasks[indexPath.row].id {
                            self.scene.del_task_ids?.append(id)
                        }
                        if self.scene.scene_tasks.count > indexPath.row {
                            self.scene.scene_tasks.remove(at: indexPath.row)
                        }
                        
                    }
                    
                    if indexPath.section == 0 && self.scene.scene_conditions.count == 0 {
                        self.tableView.reloadData()
                    } else if indexPath.section == 1 && self.scene.scene_tasks.count == 0 {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
                
                if indexPath.row == scene.scene_conditions.count - 1 {
                    cell.containerView.frame.size = CGSize(width: Screen.screenWidth - ZTScaleValue(30), height: ZTScaleValue(70))
                    cell.containerView.addRounded(corners: [.bottomLeft, .bottomRight], radii: CGSize(width: ZTScaleValue(5), height: ZTScaleValue(5)), borderWidth: 0, borderColor: .clear)
                }
                
                if type == .edit && scene.scene_conditions.first?.condition_type == 0 && indexPath.section == 0 {
                    cell.isEnableSwipe = false
                } else {
                    cell.isEnableSwipe = true
                }

                return cell
            }

        } else if indexPath.section == 1 {
            if scene.scene_tasks.count == 0 {
                addActionCell.isEnabled = (scene.scene_conditions.count > 0)
                return addActionCell

            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: SceneTaskCell.reusableIdentifier, for: indexPath) as! SceneTaskCell
                cell.task = scene.scene_tasks[indexPath.row]
                cell.setRoundedDel(indexPath.row == scene.scene_tasks.count - 1)
                
                if indexPath.row == scene.scene_tasks.count - 1 {
                    cell.containerView.frame.size = CGSize(width: Screen.screenWidth - ZTScaleValue(30), height: ZTScaleValue(70))
                    cell.containerView.addRounded(corners: [.bottomLeft, .bottomRight], radii: CGSize(width: ZTScaleValue(5), height: ZTScaleValue(5)), borderWidth: 0, borderColor: .clear)
                }
                
                cell.deletionCallback = { [weak self] in
                    guard let self = self else { return }
                    if indexPath.section == 0 {
                        if self.type == .edit ,let id = self.scene.scene_conditions[indexPath.row].id {
                            self.scene.del_condition_ids?.append(id)
                        }
                        self.scene.scene_conditions.remove(at: indexPath.row)
                        if self.scene.scene_conditions.count <= 1 {
                            self.scene.condition_logic = nil
                        }
                        
                    } else if indexPath.section == 1 {
                        if self.type == .edit ,let id = self.scene.scene_tasks[indexPath.row].id {
                            self.scene.del_task_ids?.append(id)
                        }
                        self.scene.scene_tasks.remove(at: indexPath.row)
                    }
                    
                    if indexPath.section == 0 && self.scene.scene_conditions.count == 0 {
                        self.tableView.reloadData()
                    } else if indexPath.section == 1 && self.scene.scene_tasks.count == 0 {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
                
                return cell
            }
        } else {
            return timeEffectCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && scene.scene_conditions.count == 0 { /// 添加条件
            updateConditionAlertState()
            SceneDelegate.shared.window?.addSubview(addConditionAlert)
        } else if indexPath.section == 1 && scene.scene_tasks.count == 0 { /// 添加任务
            SceneDelegate.shared.window?.addSubview(addActionAlert)
        } else if indexPath.section == 2 { /// 跳转设置生效时间
            // 跳转选择时间
            let timerVC = SetTimerViewController()
            
            let effectModel = SetEffectTimeModel()
            effectModel.effect_start_time = scene.effect_start_time
            effectModel.effect_end_time = scene.effect_end_time
            effectModel.repeat_date = scene.repeat_date
            effectModel.repeat_type = scene.repeat_type
            effectModel.time_period = scene.time_period

            timerVC.defaultEffectTimeModel = effectModel
            
            timerVC.callback = { [weak self] effectTimeModel in
                guard let self = self else { return }
                self.scene.time_period = effectTimeModel.time_period
                self.scene.effect_end_time = effectTimeModel.effect_end_time
                self.scene.effect_start_time = effectTimeModel.effect_start_time
                self.scene.repeat_type = effectTimeModel.repeat_type
                self.scene.repeat_date = effectTimeModel.repeat_date
                self.reloadSceneDetail()
            }
            
            navigationController?.pushViewController(timerVC, animated: true)
        }
        
        
        if indexPath.section == 0 && scene.scene_conditions.count > 0 { /// 点击条件
            let condition = scene.scene_conditions[indexPath.row]
            if condition.condition_type == 1 { /// 定时
                editDatePicker.setCurrentTime(timestamp: condition.timing ?? 0)
                SceneDelegate.shared.window?.addSubview(editDatePicker)
                return
            } else if condition.condition_type == 2 { /// 设备变化时
                let vc = SceneSetDeviceViewController(type: .deviceStateChanged)
                vc.title = condition.device_info?.name
                vc.isEdit = true
                vc.device_id = condition.device_id ?? 0
                
                if let item = condition.condition_attr {

                    vc.editDefaultActions = [item]
                }
                
                vc.editDefaultOperator = condition.operator ?? ""
                
                vc.addDeviceConditionChangedCallback = { [weak self] condition in
                    guard let self = self else { return }
                    if var delConditionIds = self.scene.del_condition_ids {
                        if let id = self.scene.scene_conditions[indexPath.row].id {
                            delConditionIds.append(id)
                            self.scene.del_condition_ids = delConditionIds
                        }
                       
                    } else {
                        if let id = self.scene.scene_conditions[indexPath.row].id {
                            self.scene.del_condition_ids = [id]
                        }
                    }
                    
                    self.scene.scene_conditions[indexPath.row] = condition
                    self.tableView.reloadData()
                }
                navigationController?.pushViewController(vc, animated: true)
                return
            } else { /// 手动
                
                return
            }

        }
        
        if indexPath.section == 1 && scene.scene_tasks.count > 0 { /// 点击执行任务
            let task = scene.scene_tasks[indexPath.row]
            if task.type == 1 { /// 控制设备
                let vc = SceneSetDeviceViewController(type: .controlDevice)
                vc.title = task.device_info?.name
                vc.isEdit = true
                vc.device_id = task.device_id ?? 0
                if let items = task.attributes {
//                    let defaultActions = items.map { item -> SceneDeviceControlAction in
//                        let controlAction = SceneDeviceControlAction()
//                        controlAction.val = item.val
//                        return controlAction
//                    }
                    vc.editDefaultActions = items
                }
                
                vc.defaultDelay = task.delay_seconds
                vc.addControlDeviceCallback = { [weak self] task in
                    guard let self = self else { return }
                    if var delTaskIds = self.scene.del_task_ids {
                        if let id = self.scene.scene_tasks[indexPath.row].id {
                            delTaskIds.append(id)
                            self.scene.del_task_ids = delTaskIds
                        }
                       
                    } else {
                        if let id = self.scene.scene_tasks[indexPath.row].id {
                            self.scene.del_task_ids = [id]
                        }
                    }
                    
                    self.scene.scene_tasks[indexPath.row] = task
                    self.tableView.reloadData()
                }
                navigationController?.pushViewController(vc, animated: true)
            } else { /// 控制场景
                return
            }

        }
        
        
    }
    
}

// MARK: - CreateScene
extension EditSceneViewController {
    private func createScene() {
        guard let name = inputHeader.textField.text else { return }
        
        if name == "" {
            showToast(string: "场景名称不能为空".localizedString)
            return
        }

        if scene.scene_conditions.count == 0 {
            showToast(string: "请先添加条件".localizedString)
            return
        }

        if scene.scene_tasks.count == 0 {
            showToast(string: "请先添加执行任务".localizedString)
            return
        }
        

        scene.name = name

        /// 执行条件
        if scene.scene_conditions.first?.condition_type == 0 { // 手动

            scene.auto_run = false
        } else { // 自动
            scene.auto_run = true

            if self.conditionHeader.conditionRelationshipType == .all { // 满足所有条件

                scene.condition_logic = 1
            } else { // 满足任一条件

                scene.condition_logic = 2
            }
            
            if scene.time_period == nil {
                scene.time_period = 1
                let format = DateFormatter()
                format.dateStyle = .medium
                format.timeStyle = .medium
                format.dateFormat = "yyyy:MM:dd HH:mm:ss"
                if let startTime = format.date(from: "2000:01:01 00:00:00")?.timeIntervalSince1970 {
                    scene.effect_start_time = Int(startTime)
                }
                
                if let endTime = format.date(from: "2000:01:02 00:00:00")?.timeIntervalSince1970 {
                    scene.effect_end_time = Int(endTime)
                }
                scene.repeat_type = 1
                scene.repeat_date = "1234567"
            }
            
        }
        
        /// 请求接口
        saveButton.selectedChangeView(isLoading: true)
        ApiServiceManager.shared.createScene(scene: scene.transferedEditModel) { [weak self] response in
            self?.showToast(string: "创建成功".localizedString)
            self?.navigationController?.popViewController(animated: true)
            
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.saveButton.selectedChangeView(isLoading: false)
        }

    }
    
}

/// MARK: - SceneDetail
extension EditSceneViewController {
    private func requestSceneDetail() {
        guard let id = scene_id else { return }
        showLoadingView()
        ApiServiceManager.shared.sceneDetail(id: id) { [weak self] response in
            guard let self = self else { return }
            self.hideLoadingView()
            response.del_task_ids = [Int]()
            response.del_condition_ids = [Int]()
            response.id = id
            if response.auto_run == false { // 手动时模拟一个手动执行条件
                let manualCondition = SceneCondition()
                manualCondition.condition_type = 0
                response.scene_conditions.append(manualCondition)
            }
            self.scene = response

        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
        }

    }
    
    
    private func deleteScene() {
        guard let id = scene_id else { return }
        tipsAlert?.isSureBtnLoading = true
        ApiServiceManager.shared.deleteScene(id: id) { [weak self] response in
            self?.tipsAlert?.removeFromSuperview()
            self?.showToast(string: "删除成功".localizedString)
            self?.navigationController?.popViewController(animated: true)

        } failureCallback: { [weak self] (code, err) in
            self?.tipsAlert?.isSureBtnLoading = false
            self?.showToast(string: err)
        }

    }
    
    private func editScene() {
        guard let id = scene_id else { return }
        
        guard let name = inputHeader.textField.text else { return }
        
        if name == "" {
            showToast(string: "场景名称不能为空".localizedString)
            return
        }

        if scene.scene_conditions.count == 0 {
            showToast(string: "请先添加条件".localizedString)
            return
        }

        if scene.scene_tasks.count == 0 {
            showToast(string: "请先添加执行任务".localizedString)
            return
        }
        
        scene.name = name
        
        saveButton.selectedChangeView(isLoading: true)
        ApiServiceManager.shared.editScene(id: id, scene: scene.transferedEditModel) { [weak self] _ in
            self?.showToast(string: "修改成功".localizedString)
            self?.navigationController?.popViewController(animated: true)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.saveButton.selectedChangeView(isLoading: false)
        }

    }
}


extension SceneDetailModel {
    var transferedEditModel: SceneDetailModel {
        let model = SceneDetailModel()
        model.id = id
        model.name = name
        model.auto_run = auto_run
        model.condition_logic = condition_logic
        model.create_at = create_at
        model.creator_id = creator_id
        model.del_condition_ids = del_condition_ids
        model.del_task_ids = del_task_ids
        model.effect_end_time = effect_end_time
        model.effect_start_time = effect_start_time
        model.repeat_date = repeat_date
        model.repeat_type = repeat_type
        model.scene_conditions = scene_conditions
        model.scene_tasks = scene_tasks
        model.time_period = time_period
        
        if !auto_run {
            model.scene_conditions.removeAll()
            model.effect_start_time = nil
            model.effect_end_time = nil
            model.repeat_type = nil
            model.repeat_date = ""
            model.time_period = nil
        } else {
            if scene_conditions.count == 1 {
                model.condition_logic = 1
            }

        }

        return model
    }
}


