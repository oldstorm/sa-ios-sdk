//
//  EditSceneViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/12.
//

import UIKit

class EditSceneViewController: BaseViewController {
    enum SceneType {
        case edit
        case create
    }
    
    var type: SceneType = .create

    private var conditions = [String]()
    private var actions = [String]()

    private lazy var inputHeader = SceneInputHeader(placeHolder: "场景名".localizedString)
    private lazy var addConditionCell = CreateSceneAddCell().then {
        $0.titleLabel.text = "添加触发条件".localizedString
    }
    private lazy var addActionCell = CreateSceneAddCell().then {
        $0.titleLabel.text = "添加执行任务".localizedString
    }
    
    private lazy var addConditionAlert = CreateSceneAddAlertView(
        title: "添加触发条件".localizedString,
        items: [
            .init(image: .assets(.icon_condition_manual), title: "手动执行".localizedString, detail: "点击即可执行".localizedString),
            .init(image: .assets(.icon_condition_timer), title: "定时".localizedString, detail: "如每天8点".localizedString),
            .init(image: .assets(.icon_condition_state), title: "设备状态变化时".localizedString, detail: "如打开灯时，感应到人时".localizedString)
        ],
        callback: { [weak self] index in
            guard let self = self else { return }
            self.conditions.append("condition")
            self.tableView.reloadData()
        })
    
    private lazy var addActionAlert = CreateSceneAddAlertView(
        title: "添加执行任务".localizedString,
        items: [
            .init(image: .assets(.icon_smart_device), title: "智能设备".localizedString, detail: "如开灯、播放音乐".localizedString),
            .init(image: .assets(.icon_control_scene), title: "控制场景".localizedString, detail: "如开启夏季晚会场景".localizedString),
            
        ],
        callback: { [weak self] index in
            guard let self = self else { return }
            print("selected \(index)")
            self.actions.append("action")
            self.tableView.reloadData()
        })
    
    private lazy var conditionHeader = CreateSceneSectionHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: ZTScaleValue(50)),type: .condition)
    
    private lazy var actionHeader = CreateSceneSectionHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: ZTScaleValue(50)),type: .action)
    
    private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.dataSource = self
        $0.delegate = self
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.register(SceneConditionCell.self, forCellReuseIdentifier: SceneConditionCell.reusableIdentifier)
        $0.register(SceneActionCell.self, forCellReuseIdentifier: SceneActionCell.reusableIdentifier)
    }
    
    private lazy var saveButton = Button().then {
        $0.setTitle("保存".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "创建场景".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }

    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(inputHeader)
        view.addSubview(tableView)
        
        conditionHeader.plusButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            SceneDelegate.shared.window?.addSubview(self.addConditionAlert)
        }
        
        conditionHeader.plusButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            SceneDelegate.shared.window?.addSubview(self.addConditionAlert)
        }
        
        actionHeader.plusButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            SceneDelegate.shared.window?.addSubview(self.addActionAlert)
        }
    }

    override func setupConstraints() {
        inputHeader.snp.makeConstraints {
            $0.top.right.left.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(inputHeader.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
    }
    
    

}

// MARK: - UITableView Delegate & Datasource
extension EditSceneViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return conditionHeader
        } else if section == 1 {
            return actionHeader
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if conditions.count == 0 {
                return 0
            } else {
                return ZTScaleValue(60)
            }
        } else if section == 1 {
            if actions.count == 0 {
                return 0
            } else {
                return ZTScaleValue(60)
            }
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if conditions.count == 0 {
                return 1
            } else {
                return conditions.count
            }
        } else if section == 1 {
            if actions.count == 0 {
                return 1
            } else {
                return actions.count
            }
        } else {
            return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if conditions.count == 0 {
                return addConditionCell

            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: SceneConditionCell.reusableIdentifier, for: indexPath) as! SceneConditionCell
                cell.condition = conditions[indexPath.row]
                cell.isRoundedBottom = (indexPath.row == conditions.count - 1)
                

                return cell
            }

        } else if indexPath.section == 1 {
            if actions.count == 0 {
                addActionCell.isEnabled = (conditions.count > 0)
                return addActionCell

            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: SceneActionCell.reusableIdentifier, for: indexPath) as! SceneActionCell
                cell.action = actions[indexPath.row]
                cell.isRoundedBottom = (indexPath.row == actions.count - 1)
                cell.actionType = Bool.random() ? .device : .scene
                return cell
            }
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && conditions.count == 0 {
            SceneDelegate.shared.window?.addSubview(addConditionAlert)
        } else if indexPath.section == 1 && actions.count == 0 {
            SceneDelegate.shared.window?.addSubview(addActionAlert)
        } else {
            
        }
    }
    
    
    
}
