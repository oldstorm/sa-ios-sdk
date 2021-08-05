//
//  SceneConditionPickerView.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/21.
//



import UIKit

class SceneConditionPickerView: UIView,UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var currentDataArry = [[Int]]()
    
    public var timerSelectTag = 1
    
    var pickerCallback: ((_ time: Int) -> ())?
    
    var currentTime = "00:00:00"
    
    lazy var pickerView = UIPickerView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }

    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var closeButton = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }

    private lazy var sureButton = Button().then {
        $0.setTitle("确定".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.layer.masksToBounds = true
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let format = DateFormatter()
            format.dateStyle = .medium
            format.timeStyle = .medium
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let date = Date()
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy-MM-dd"
            let str = yearFormatter.string(from: date)
            
            let value = str + " " + self.currentTime

            if let date = format.date(from: value) {
                self.pickerCallback?(Int(date.timeIntervalSince1970))
            }
            
            self.removeFromSuperview()
        }
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var titleLabel = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.text = "定时".localizedString
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
    }
    
    
    lazy var hourLabel = Label().then{
        $0.backgroundColor = .clear
        $0.text = "时".localizedString
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .center
    }

    lazy var minLabel = Label().then{
        $0.backgroundColor = .clear
        $0.text = "分".localizedString
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .center
    }

    lazy var secondLabel = Label().then{
        $0.backgroundColor = .clear
        $0.text = "秒".localizedString
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .center
    }
    
    func setCurrentTime(timestamp: Int) {
        let format = DateFormatter()
        format.dateFormat = "HH:mm:ss"
        currentTime =  format.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
        let rows = currentTime.components(separatedBy: ":").map { Int($0) ?? 0 }
        for (idx, row) in rows.enumerated() {
            pickerView.selectRow(row, inComponent: idx, animated: false)
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        initData()
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(line)
        containerView.addSubview(closeButton)
        containerView.addSubview(sureButton)
        containerView.addSubview(pickerView)
        containerView.addSubview(hourLabel)
        containerView.addSubview(minLabel)
        containerView.addSubview(secondLabel)
        closeButton.isEnhanceClick = true
    }
    
    private func initData(){
        var hours = [Int]()
        var mins = [Int]()
        var seconds = [Int]()
        
        for hour in 00...23 {
                hours.append(hour)
        }
        
        for index in 00...59 {
                mins.append(index)
                seconds.append(index)
        }
        
        currentDataArry = [hours,mins,seconds]
    }

    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(17.5))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.width.equalTo(ZTScaleValue(9))
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(ZTScaleValue(18))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))

        }
    

        line.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(20))
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(1))
        }
        
        
        sureButton.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(265))
            $0.bottom.equalTo(-ZTScaleValue(15)-10)
            $0.width.equalTo(ZTScaleValue(345))
            $0.centerX.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(50))
        }
        
        pickerView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.bottom.equalTo(sureButton.snp.top)
            $0.left.right.equalToSuperview()
        }
        
        hourLabel.snp.makeConstraints {
            $0.left.equalTo(ZTScaleValue(110))
            $0.centerY.equalTo(pickerView)
            $0.width.greaterThanOrEqualTo(20)
            $0.height.equalTo(20)
        }
        
        minLabel.snp.makeConstraints {
            $0.left.equalTo(hourLabel.snp.right).offset(ZTScaleValue(78.5))
            $0.centerY.equalTo(pickerView)
            $0.width.greaterThanOrEqualTo(20)
            $0.height.equalTo(20)
        }
        
        secondLabel.snp.makeConstraints {
            $0.left.equalTo(minLabel.snp.right).offset(ZTScaleValue(78.5))
            $0.centerY.equalTo(pickerView)
            $0.width.greaterThanOrEqualTo(20)
            $0.height.equalTo(20)
        }
        
        
    }
    
    
}

extension SceneConditionPickerView {
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
        
        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
    }
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
    
    

    
    private func scrollTo(currentDate: String){
        
        let array = currentDate.components(separatedBy: ":")
        
        let hour = array[0]
        let min = array[1]
        let second = array[2]
        
        var hourIndex = 0
        var minIndex = 0
        var secondIndex = 0
        
        //获取当前小时下标
        for index in 0...currentDataArry[0].count - 1 {
            let hourStr = String(format: "%02d", currentDataArry[0][index])
            if hourStr == hour  {
                hourIndex = index
            }
        }
        //获取当前分钟下标
        for index in 0...currentDataArry[1].count - 1 {
            let minStr = String(format: "%02d", currentDataArry[1][index])
            if minStr == min  {
                minIndex = index
            }
        }

        //获取当前秒下标
        for index in 0...currentDataArry[2].count - 1 {
            let sencondStr = String(format: "%02d", currentDataArry[2][index])
            if sencondStr == second  {
                secondIndex = index
            }
        }
        
        pickerView.selectRow(hourIndex, inComponent: 0, animated: false)
        pickerView.selectRow(minIndex, inComponent: 1, animated: false)
        pickerView.selectRow(secondIndex, inComponent: 2, animated: false)
    }

}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension SceneConditionPickerView{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return currentDataArry.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentDataArry[component].count
    }
        
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let lable = UILabel()
        lable.sizeToFit()
        lable.font = .font(size: ZTScaleValue(30), type: .D_bold)
        lable.textColor = .custom(.black_3f4663)
        lable.text = String(format: "%02d", currentDataArry[component][row])
        lable.textAlignment = .center
        return lable
    }
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return ZTScaleValue(90)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return ZTScaleValue(60)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let pickerStr = String(format: "%02d", pickerView.selectedRow(inComponent: 0)) + ":" + String(format: "%02d", pickerView.selectedRow(inComponent: 1)) + ":" +
            String(format: "%02d", pickerView.selectedRow(inComponent: 2))
        
        currentTime = pickerStr
    }
    
}
