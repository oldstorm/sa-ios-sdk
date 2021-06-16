//
//  DatePickerVIew.swift
//  ZhiTing
//
//  Created by zy on 2021/4/19.
//

import UIKit

class DatePickerView: UIView,UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var currentDataArry = [[Int]]()
    
    public var timerSelectTag = 1
    var currentStarTime = "00:00:00"
    var currentEndTime = "00:00:00"
    
    var pickerCallback: ((_ starTime: String, _ endTime: String) -> ())?
    
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
            self?.pickerCallback!(self!.currentStarTime,self!.currentEndTime)
            self?.removeFromSuperview()
        }
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var starLabel = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.text = "开始"
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(11), type: .bold)
        $0.textAlignment = .center
    }
    
    lazy var starTimeLabel = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.text = "00:00:00"
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(18), type: .D_bold)
        $0.textAlignment = .center
    }
    
    lazy var endLabel = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.text = "结束"
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(11), type: .bold)
        $0.textAlignment = .center
    }
    
    lazy var endTimeLabel = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.text = "00:00:00"
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(18), type: .D_bold)
        $0.textAlignment = .center
    }
    
    lazy var hourLabel = Label().then{
        $0.backgroundColor = .clear
        $0.text = "时"
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .center
    }

    lazy var minLabel = Label().then{
        $0.backgroundColor = .clear
        $0.text = "分"
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .center
    }

    lazy var secondLabel = Label().then{
        $0.backgroundColor = .clear
        $0.text = "秒"
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .center
    }
    
    private lazy var starButton = Button().then {
        $0.backgroundColor = .clear
        $0.tag = 1
        $0.addTarget(self, action: #selector(buttonChangeWithSender(sender:)), for: .touchUpInside)
    }

    private lazy var endButton = Button().then {
        $0.backgroundColor = .clear
        $0.tag = 2
        $0.addTarget(self, action: #selector(buttonChangeWithSender(sender:)), for: .touchUpInside)
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
        containerView.addSubview(starLabel)
        containerView.addSubview(starTimeLabel)
        containerView.addSubview(endLabel)
        containerView.addSubview(endTimeLabel)
        containerView.addSubview(starButton)
        containerView.addSubview(endButton)
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

        starLabel.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(ZTScaleValue(18))
            $0.centerX.equalTo(containerView.snp.centerX).multipliedBy(0.5)
            $0.height.equalTo(ZTScaleValue(11))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(22))
        }
        
        endLabel.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(ZTScaleValue(18))
            $0.centerX.equalTo(containerView.snp.centerX).multipliedBy(1.5)
            $0.height.equalTo(ZTScaleValue(11))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(22))
        }
        
        starTimeLabel.snp.makeConstraints {
            $0.top.equalTo(starLabel.snp.bottom).offset(ZTScaleValue(7.5))
            $0.centerX.equalTo(containerView.snp.centerX).multipliedBy(0.5)
            $0.height.equalTo(ZTScaleValue(20))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(68.0))
        }
        
        endTimeLabel.snp.makeConstraints {
            $0.top.equalTo(endLabel.snp.bottom).offset(ZTScaleValue(7.5))
            $0.centerX.equalTo(containerView.snp.centerX).multipliedBy(1.5)
            $0.height.equalTo(ZTScaleValue(20))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(68.0))
        }
        
        starButton.snp.makeConstraints {
            $0.top.equalTo(starLabel).offset(-ZTScaleValue(10))
            $0.left.equalTo(starTimeLabel).offset(-ZTScaleValue(10))
            $0.right.equalTo(starTimeLabel).offset(ZTScaleValue(10))
            $0.bottom.equalTo(starTimeLabel).offset(ZTScaleValue(10))
        }
        
        endButton.snp.makeConstraints {
            $0.top.equalTo(endLabel).offset(-ZTScaleValue(10))
            $0.left.equalTo(endTimeLabel).offset(-ZTScaleValue(10))
            $0.right.equalTo(endTimeLabel).offset(ZTScaleValue(10))
            $0.bottom.equalTo(endTimeLabel).offset(ZTScaleValue(10))
        }

        line.snp.makeConstraints {
            $0.top.equalTo(endTimeLabel.snp.bottom).offset(ZTScaleValue(20))
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

extension DatePickerView {
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
    
    @objc private func buttonChangeWithSender(sender:Button) {
        print("\(sender.tag)")
        timerSelectTag = sender.tag
        changeCurrentPickerView()
    }
    
    public func  changeCurrentPickerView(){
        starTimeLabel.text = currentStarTime
        endTimeLabel.text = currentEndTime
        if timerSelectTag == 1 {//开始
            starLabel.textColor = .custom(.black_3f4663)
            starTimeLabel.textColor = .custom(.blue_2da3f6)
            endLabel.textColor = .custom(.gray_94a5be)
            endTimeLabel.textColor = .custom(.gray_94a5be)
            scrollTo(currentDate: currentStarTime)
        }else{//结束
            endLabel.textColor = .custom(.black_3f4663)
            endTimeLabel.textColor = .custom(.blue_2da3f6)
            starLabel.textColor = .custom(.gray_94a5be)
            starTimeLabel.textColor = .custom(.gray_94a5be)
            scrollTo(currentDate: currentEndTime)
        }
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
extension DatePickerView{
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

        if timerSelectTag == 1 {
            currentStarTime = pickerStr
            starTimeLabel.text = pickerStr
        }else{
            currentEndTime = pickerStr
            endTimeLabel.text = pickerStr
        }
    }
    
}
