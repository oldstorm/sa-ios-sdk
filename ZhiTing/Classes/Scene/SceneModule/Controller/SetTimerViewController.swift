//
//  SetTimerViewController.swift
//  ZhiTing
//
//  Created by mac on 2021/4/15.
//

import UIKit

class SetTimerViewController: BaseViewController {
    var callback: ((SetEffectTimeModel) -> ())?

    var defaultEffectTimeModel: SetEffectTimeModel? {
        didSet {
            guard let model = defaultEffectTimeModel else { return }
            if model.repeat_type == 1 {
                self.currentTimeModel.repetitionResult = "每天".localizedString
                timeScopeAlert.selectedIndex = 0
            } else if model.repeat_type == 2 {
                self.currentTimeModel.repetitionResult = "周一至周五".localizedString
                timeScopeAlert.selectedIndex = 1
            } else if model.repeat_type == 3 {
                self.currentTimeModel.repetitionResult = "自定义".localizedString
                timeScopeAlert.selectedIndex = 2
                model.repeat_date.forEach {
                    if let day = Int(String($0)) {
                        customTimeScopeAlert.days[day - 1].is_selected = true
                    }
                }
            }
            
            if model.time_period == 2 {
                self.currentTimeModel.isChooseTimer = true
                self.currentTimeModel.isChooseAllDay = false
                let format = DateFormatter()
                format.dateStyle = .medium
                format.timeStyle = .medium
                format.dateFormat = "HH:mm:ss"
                
                self.currentTimeModel.starTime = format.string(from: Date(timeIntervalSince1970: TimeInterval(model.effect_start_time ?? 0)))
                self.currentTimeModel.endTime = format.string(from: Date(timeIntervalSince1970: TimeInterval(model.effect_end_time ?? 0)))
            } else {
                self.currentTimeModel.isChooseAllDay = true
                self.currentTimeModel.isChooseTimer = false
            }
            tableView.reloadData()
            
        }
    }

    private lazy var timeScopeAlert = EditSceneSelectionAlert(title: " ", titles: ["每天".localizedString, "周一至周五".localizedString, "自定义".localizedString])
    
    private lazy var customTimeScopeAlert = CustomTimeScopeAlert(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private lazy var saveButton = DoneButton(frame: CGRect(x: 0, y: 0, width: 50, height: 25)).then {
        $0.setTitle("完成".localizedString, for: .normal)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let effectTimeModel = SetEffectTimeModel()
            if self.currentTimeModel.repetitionResult == "每天".localizedString {
                effectTimeModel.repeat_type = 1
            } else if self.currentTimeModel.repetitionResult == "周一至周五".localizedString {
                effectTimeModel.repeat_type = 2
            } else {
                effectTimeModel.repeat_type = 3
                effectTimeModel.repeat_date = ""
                for (index, day) in self.customTimeScopeAlert.days.enumerated() {
                    if day.is_selected {
                        effectTimeModel.repeat_date += "\(index + 1)"
                    }
                }
            }
            
            
            
            if self.currentTimeModel.isChooseTimer {
                let format = DateFormatter()
                format.dateStyle = .medium
                format.timeStyle = .medium
                format.dateFormat = "HH:mm:ss"
                effectTimeModel.time_period = 2
                
                if let startTime = format.date(from: self.currentTimeModel.starTime)?.timeIntervalSince1970 {
                    effectTimeModel.effect_start_time = Int(startTime)
                }
                
                if let endTime = format.date(from: self.currentTimeModel.endTime)?.timeIntervalSince1970 {
                    effectTimeModel.effect_end_time = Int(endTime)
                }
                
                if effectTimeModel.effect_start_time ?? 0 > effectTimeModel.effect_end_time ?? 0 {
                    self.showToast(string: "结束时间需大于开始时间".localizedString)
                    return
                }

            } else {
                effectTimeModel.time_period = 1
                let format = DateFormatter()
                format.dateStyle = .medium
                format.timeStyle = .medium
                format.dateFormat = "yyyy:MM:dd HH:mm:ss"
                if let startTime = format.date(from: "2000:01:01 00:00:00")?.timeIntervalSince1970 {
                    effectTimeModel.effect_start_time = Int(startTime)
                }
                
                if let endTime = format.date(from: "2000:01:02 00:00:00")?.timeIntervalSince1970 {
                    effectTimeModel.effect_end_time = Int(endTime)
                }
            }
            

            self.callback?(effectTimeModel)

            self.navigationController?.popViewController(animated: true)
        }
    }
    
    lazy var currentTimeModel = TimerModel().then {
        $0.isChooseTimer = false
        $0.isChooseAllDay = true
        $0.repetitionResult = "每天".localizedString
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
        $0.register(TimeAllDayCell.self, forCellReuseIdentifier: TimeAllDayCell.reusableIdentifier)
        $0.register(TimeSelectCell.self, forCellReuseIdentifier: TimeSelectCell.reusableIdentifier)
        $0.register(TimeRepetitionCell.self, forCellReuseIdentifier: TimeRepetitionCell.reusableIdentifier)
        $0.alwaysBounceVertical = false
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "生效时间段".localizedString
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.height.equalTo(ZTScaleValue(24))
            $0.width.equalTo(ZTScaleValue(50))
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-10)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveButton.removeFromSuperview()
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        
        /// 重复 - 弹窗 设置
        timeScopeAlert.selectCallback = { [weak self] idx in
            guard let self = self else { return }
            switch idx {
            case 0:
                self.currentTimeModel.repetitionResult = "每天".localizedString
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            case 1:
                self.currentTimeModel.repetitionResult = "周一至周五".localizedString
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            case 2:
                SceneDelegate.shared.window?.addSubview(self.customTimeScopeAlert)
            default:
                break
                
            }
        }
        
        
        customTimeScopeAlert.callback = { [weak self] days in
            guard let self = self else { return }
            self.currentTimeModel.repetitionResult = "自定义".localizedString
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        }

    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
    }

}

extension SetTimerViewController {
    private func showPickerView(seletedIndex: Int){
        //弹出时间选择框
        let datePicker = DatePickerView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        datePicker.currentStarTime = currentTimeModel.starTime
        datePicker.currentEndTime = currentTimeModel.endTime
        datePicker.timerSelectTag = seletedIndex
        datePicker.changeCurrentPickerView()
        SceneDelegate.shared.window?.addSubview(datePicker)
        datePicker.pickerCallback = {[weak self] starTime, endTime in
            self?.currentTimeModel.starTime = starTime
            self?.currentTimeModel.endTime = endTime
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension SetTimerViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                //全天
                let cell = tableView.dequeueReusableCell(withIdentifier: TimeAllDayCell.reusableIdentifier, for: indexPath) as! TimeAllDayCell
                cell.selectionStyle = .none
                cell.currentModel = currentTimeModel
                return cell
            }else{
                //时间段
                let cell = tableView.dequeueReusableCell(withIdentifier: TimeSelectCell.reusableIdentifier, for: indexPath) as! TimeSelectCell
                cell.selectionStyle = .none
                cell.currentModel = currentTimeModel
                cell.SelectCallback = {[weak self] in
                    self?.showPickerView(seletedIndex: $0)
                }
                return cell
            }
        }else{
            //重复
            let cell = tableView.dequeueReusableCell(withIdentifier: TimeRepetitionCell.reusableIdentifier, for: indexPath) as! TimeRepetitionCell
            cell.selectionStyle = .none
            cell.currentModel = currentTimeModel
            
            if timeScopeAlert.selectedIndex == 2 {
                var strs = [String]()
                customTimeScopeAlert.days.forEach { day in
                    if day.is_selected {
                        strs.append(day.name)
                    }
                }
                
                if strs.count > 0 {
                    cell.repetition.text = strs.joined(separator: "、")
                }
            }
            
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                //全天
                return ZTScaleValue(50.0)
            }else{
                //时间段
                if currentTimeModel.isChooseTimer {
                    return ZTScaleValue(100.0)
                }else{
                    return ZTScaleValue(50)
                }
            }
        }else{
            return ZTScaleValue(50.0)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else{
            return ZTScaleValue(10)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                //选择全天
                currentTimeModel.isChooseAllDay = true
                currentTimeModel.isChooseTimer = false
            }else{
                currentTimeModel.isChooseAllDay = false
                currentTimeModel.isChooseTimer = true
            }
            
            DispatchQueue.main.async {[weak self] in
                self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        } else {
            //弹出重复选项
            SceneDelegate.shared.window?.addSubview(timeScopeAlert)
        }
    }

    }

class SetEffectTimeModel {
    // 重复执行的类型；1：每天; 2:工作日 ；3：自定义;auto_run为false可不传
    var repeat_type: Int?
    // 只能传长度为7包含1-7的数字；"1122"视为不合法传参;repeat_type为1时:"1234567"; 2:12345; 3时：任意
    var repeat_date = "1234567"
    /// 生效开始时间,time_period为1时应传某天0点;auto_run为false可不传
    var effect_start_time: Int?
    /// 生效结束时间,time_period为1时应传某天24点;auto_run为false可不传
    var effect_end_time: Int?
    /// 生效时间类型，全天为1，时间段为2,auto_run为false可不传
    var time_period: Int?
}

class TimerModel: NSObject {
    
    /// 是否选中全天
    var isChooseAllDay = true
    /// 是否选中时间段
    var isChooseTimer = false
    /// 开始时间
    var starTime = "00:00:00"
    /// 结束时间
    var endTime = "00:00:00"
    ///重复
    var repetition = [String]()
    ///重复展示
    var repetitionResult = ""
    
}
