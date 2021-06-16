//
//  ControlSceneViewController.swift
//  ZhiTing
//
//  Created by zy on 2021/4/22.
//

import UIKit

class ControlSceneViewController: BaseViewController {
    var tasksCallback: ((_ tasks: [SceneTask]) -> ())?

    enum ControlSceneType {
        /// 开启自动执行
        case openAuto
        /// 关闭自动执行
        case closeAuto
        /// 执行某条场景
        case excute
    }

    let type: ControlSceneType
    
    init(type: ControlSceneType) {
        self.type = type
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch type {
        case .closeAuto:
            title = "关闭自动执行"
        case .openAuto:
            title = "开启自动执行"
        case .excute:
            title = "执行某条场景"
        }
        
    }
    
    var currentSceneData = [SceneTypeModel]()
    
    private lazy var delayCell = ControlSceneCell().then {
        $0.backgroundColor = .clear
        $0.setUpViewCellWith(type: .delay, title: "延时".localizedString)
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
            self.delayCell.valueLabel.text = "延后" + str
            self.tableView.reloadData()
        }
    }
    
    private lazy var resetButton = Button().then {
        $0.setTitle("重置".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.clickCallBack = { [weak self] _ in
            self?.currentSceneData.forEach { $0.isSelected = false }
            self?.tableView.reloadData()
            self?.delayCell.valueLabel.text = ""
        }
    }
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.estimatedSectionHeaderHeight = 10
        $0.estimatedSectionFooterHeight = 0
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        //创建Cell
        $0.register(ControlSceneCell.self, forCellReuseIdentifier: ControlSceneCell.reusableIdentifier)
        $0.alwaysBounceVertical = false
    }
    
    private lazy var nextButton = ImageTitleButton(frame: .zero, icon: nil, title: "下一步".localizedString, titleColor: .custom(.white_ffffff), backgroundColor: .custom(.blue_2da3f6))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: resetButton)
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(nextButton)
        
        nextButton.clickCallBack = { [weak self] in
            self?.nextBtnClick()
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

}

extension ControlSceneViewController {
    private func nextBtnClick() {
        guard currentSceneData.filter({ ($0.isSelected ?? false) }).count > 0 else {
            showToast(string: "请先选择场景".localizedString)
            return
        }
        
        
        
        

        let currentTime = datePicker.currentTime
        var secs = 0
        if currentTime != "00:00:00" {
            
            let cons = currentTime.components(separatedBy: ":").map { Int($0) ?? 0}
            if cons.count == 3 {
                secs += cons[0] * 3600
                secs += cons[1] * 60
                secs += cons[2]
            }
        }
        
        let task = SceneTask()
        task.type = 1

        var tasks = [SceneTask]()
        
        currentSceneData.filter({ $0.isSelected == true }).forEach {
            let task = SceneTask()
            task.control_scene_id = $0.id
            let controlSceneInfo = SceneTaskControlSceneInfo()
            controlSceneInfo.name = $0.name
            task.control_scene_info = controlSceneInfo
            task.delay_seconds = secs
            
            if type == .excute {
                task.type = 2
            } else if type == .openAuto {
                task.type = 3
            } else {
                task.type = 4
            }

            tasks.append(task)
        }
        
        tasksCallback?(tasks)
        navigationController?.popViewController(animated: true)

    }
}


extension ControlSceneViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if currentSceneData.count == 0 {
            return 0//无场景数据
        }else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentSceneData.count != 0 {
            if section == 0 {
                return currentSceneData.count
            }else{
                return 1
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if currentSceneData.count != 0 {
            if indexPath.section == 0 {
                return ZTScaleValue(80)
            }else{
                return ZTScaleValue(60)
            }
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ControlSceneCell.reusableIdentifier, for: indexPath) as! ControlSceneCell
            cell.backgroundColor = .clear
            let model = currentSceneData[indexPath.row]
            cell.setUpViewCellWith(type: .selected, title: model.name)
            cell.selectButton.isSelected = model.isSelected!
            return cell
        } else {
            //延时
            return delayCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if currentSceneData.count == 0 {
            return 0
        } else {
            if section == 0 {
                return 0
            } else {
                return ZTScaleValue(20)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentSceneData.count != 0 {
            if indexPath.section == 0 {
                currentSceneData[indexPath.row].isSelected = !currentSceneData[indexPath.row].isSelected!
                DispatchQueue.main.async {[weak self] in
                    guard let self = self else { return}
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else {
                SceneDelegate.shared.window?.addSubview(self.datePicker)
            }
        }
    }
}
