//
//  VarietyAlertView.swift
//  ZhiTing
//
//  Created by mac on 2021/4/23.
//

import UIKit
import FlexColorPicker

enum AlertType {
    /// 选项
    case tableViewType(data: [String])
    /// 亮度
    case lightDegreeType(value: Int, maxValue: Int, minValue: Int, segmentTag: Int)
    /// 色温
    case colorTemperatureType(value: Int, maxValue: Int, minValue: Int, segmentTag: Int)
    /// 窗帘位置
    case curtainState(value: Int, maxValue: Int, minValue: Int, segmentTag: Int)
    /// 色谱
    case colorPalette(color: HSBColor)
    /// 湿度
    case sensorHumidity(value: Int, maxValue: Int, minValue: Int, segmentTag: Int)
    /// 温度
    case sensorTemperature(value: Int, maxValue: Int, minValue: Int, segmentTag: Int)

}

class VarietyAlertView: UIView, DeviceAttrAlert {
    
    
    // MARK: - 公有组件
    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    lazy var titleLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(16), type: .bold)
        $0.textColor = .custom(.black_3f4663)
    }
    
    lazy var detailLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.gray_94a5be)
        $0.textAlignment = .center
    }
    
    private lazy var closeButton = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    private var currentType = AlertType.tableViewType(data: [""])
    
    
    // MARK: - 选项相关组件
    var selectCallback: ((_ index: Int) -> ())?
    var selectedIndex = 0
    var disableIndexs = [Int]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var tableView = UITableView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = UITableView.automaticDimension
        $0.isScrollEnabled = false
        $0.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reusableIdentifier)
        
    }
    
    lazy var tableViewData = [String]()

    
    
    // MARK: - 亮度、色温、窗帘进度 相关组件
    var valueCallback: ((_ value: Int, _ seletedTag: Int) -> ())?
    
    
    var slider = CustomSlider()
    
    lazy var currentValue : Int = 0
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    private lazy var sureButton = Button().then {
        $0.setTitle("确定".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.layer.masksToBounds = true
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else {return}
            let value = self.currentValue
            self.valueCallback?(value, self.buttonSeletedTag)
            self.removeFromSuperview()
        }
    }
    
    var buttonSeletedTag = 2
    
    
    private lazy var segmentCoverView = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.layer.cornerRadius = ZTScaleValue(25)
        $0.layer.masksToBounds = true
    }
    
    private lazy var miniButton = Button().then {
        $0.setTitle("小于", for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.tag = 1
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .selected)
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.layer.cornerRadius = ZTScaleValue(20)
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(buttonDidSeleted(sender:)), for: .touchUpInside)
        
    }
    
    private lazy var equalButton = Button().then {
        $0.setTitle("等于", for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.tag = 2
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .selected)
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.layer.cornerRadius = ZTScaleValue(20)
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(buttonDidSeleted(sender:)), for: .touchUpInside)
    }
    
    private lazy var maxButton = Button().then {
        $0.setTitle("大于", for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.tag = 3
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .selected)
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.layer.cornerRadius = ZTScaleValue(20)
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(buttonDidSeleted(sender:)), for: .touchUpInside)
    }
    
    
    private lazy var valueLabel = UILabel().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(50), type: .D_bold)
        $0.textAlignment = .center
    }
    
    
    // MARK: - 色谱样式相关组件
    lazy var colorPalette = RadialPaletteControl().then {
        $0.thumbView.expandOnTap = false
    }

    var colorPaletteCallback: ((_ color: HSBColor) -> ())?
    
    // MARK: - Life Cycle
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    convenience init(title: String, type:AlertType){
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        titleLabel.text = title
        currentType = type
        switch type {
        case .tableViewType(let datas):
            setupTableView(data: datas)
        case .lightDegreeType(let value, let maxValue, let minValue, let segmentTag):
            setupLightDegreeSlider(value: value, maxValue: maxValue, minValue: minValue, segmentTag: segmentTag)
        case .colorTemperatureType(let value, let maxValue, let minValue, let segmentTag):
            setupColorTemperatureSlider(value: value, maxValue: maxValue, minValue: minValue, segmentTag: segmentTag)
        case .curtainState(let value, let maxValue, let minValue, let segmentTag):
            setupCurtainStateSlider(value: value, maxValue: maxValue, minValue: minValue, segmentTag: segmentTag)
        case .colorPalette(let color):
            setupColorPalette(color: color)
        case .sensorHumidity(let value, let maxValue, let minValue, let segmentSegmentTag):
            setupSensorHumiditySlider(value: value, maxValue: maxValue, minValue: minValue, segmentTag: segmentSegmentTag)
        case .sensorTemperature(let value, let maxValue, let minValue, let segmentSegmentTag):
            setupSensorHumiditySlider(value: value, maxValue: maxValue, minValue: minValue, segmentTag: segmentSegmentTag)
        }
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        closeButton.isEnhanceClick = true
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
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(ZTScaleValue(20.5))
            $0.top.equalToSuperview().offset(ZTScaleValue(16.5))
            $0.right.equalTo(closeButton.snp.left).offset(ZTScaleValue(-10))
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(17.5))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.width.equalTo(ZTScaleValue(9))
        }
        
    }
    
    
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
    
    deinit {
        
        switch self.currentType {
        case .tableViewType:
            tableView.removeObserver(self, forKeyPath: "contentSize", context: nil)
        case .lightDegreeType:
            break
        case .colorTemperatureType:
            break
        case .curtainState:
            break
        case .colorPalette:
            break
        case .sensorHumidity:
            break
        case .sensorTemperature:
            break
        }
    }
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
    
    private func dismissWithCallback(value: CGFloat) {
        self.endEditing(true)
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }, completion: { isFinished in
            if isFinished {
                switch self.currentType {
                case .tableViewType:
                    weakSelf?.selectCallback?(Int(value))
                    
                case .lightDegreeType:
                    break
                case .colorTemperatureType:
                    break
                case .curtainState:
                    break
                case .colorPalette:
                    break
                case .sensorHumidity:
                    break
                case .sensorTemperature:
                    break
                }
                super.removeFromSuperview()
            }
        })
    }
    
}

// MARK: - 选项相关方法
extension VarietyAlertView {
    class ItemCell: UITableViewCell, ReusableView {
        
        private lazy var line = UIView().then {
            $0.backgroundColor = .custom(.gray_eeeeee)
        }
        
        
        lazy var selection = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.unselected_tick)
        }
        
        lazy var titleLabel = Label().then {
            $0.font = .font(size: ZTScaleValue(14), type: .regular)
            $0.textColor = .custom(.black_3f4663)
            $0.numberOfLines = 0
        }
        
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            setupViews()
            setupConstraints()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            contentView.addSubview(titleLabel)
            contentView.addSubview(line)
            contentView.addSubview(selection)
        }
        
        private func setupConstraints() {
            line.snp.makeConstraints {
                $0.height.equalTo(0.5)
                $0.top.left.right.equalToSuperview()
            }
            
            selection.snp.makeConstraints {
                $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(20.5))
                $0.right.equalToSuperview().offset(ZTScaleValue(-15))
                $0.width.equalTo(ZTScaleValue(18.5))
                $0.height.equalTo(ZTScaleValue(18.5))
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(22.5))
                $0.left.equalToSuperview().offset(ZTScaleValue(15))
                $0.right.equalTo(selection.snp.left).offset(ZTScaleValue(-10))
                $0.bottom.equalToSuperview().offset(ZTScaleValue(-23.5))
            }
            
            
        }
        
    }
    
    private func setupTableView(data: [String]) {
        containerView.addSubview(tableView)
        self.tableViewData = data
        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(18))
            $0.bottom.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(210))
        }
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let height = (change![.newKey] as? CGSize)?.height  else {
                return
            }
            
            let tableViewHeight = height + 10
            tableView.snp.remakeConstraints {
                $0.left.right.equalToSuperview()
                $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(18))
                $0.bottom.equalToSuperview()
                $0.height.equalTo(ZTScaleValue(tableViewHeight))
            }
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
}

extension VarietyAlertView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reusableIdentifier, for: indexPath) as! ItemCell
        cell.titleLabel.text = tableViewData[indexPath.row]
        cell.titleLabel.textColor = selectedIndex == indexPath.row ? .custom(.blue_2da3f6) : .custom(.black_3f4663)
        cell.selection.image = selectedIndex == indexPath.row ? .assets(.selected_tick) : .assets(.unselected_tick)
        
        cell.isUserInteractionEnabled = !disableIndexs.contains(where: { $0 == indexPath.row })
        cell.contentView.alpha = disableIndexs.contains(where: { $0 == indexPath.row }) ? 0.5 : 1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        tableView.reloadData()
        dismissWithCallback(value: CGFloat(indexPath.row))
    }
    
}

// MARK: - 色谱相关方法
extension VarietyAlertView {
    private func setupColorPalette(color: HSBColor = .init(hue: 0, saturation: 1, brightness: 1)) {
        colorPalette.setSelectedHSBColor(color, isInteractive: true)
        containerView.addSubview(line)
        containerView.addSubview(colorPalette)
        containerView.addSubview(sureButton)
        
        sureButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.colorPaletteCallback?(self.colorPalette.selectedHSBColor)
            self.removeFromSuperview()
        }

        line.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(16.5))
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(0.5))
        }
        
        colorPalette.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(200))
        }
        
        sureButton.snp.makeConstraints {
            $0.top.equalTo(colorPalette.snp.bottom).offset(40)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalTo(-15 - Screen.bottomSafeAreaHeight)
            
        }
    }
}


// MARK: - 色温、亮度、窗帘进度、湿度相关方法
extension VarietyAlertView {
    
    /// 亮度
    private func setupLightDegreeSlider(value: Int, maxValue: Int, minValue: Int, segmentTag: Int) {
        buttonSeletedTag = segmentTag
        setUpSliderUI()
        setSeletedButton(tag: segmentTag)
        
        
        slider.maximumValue = Float(maxValue)
        slider.minimumValue = Float(minValue)
        slider.setValue(Float(value), animated: true)
        
        var percent = "0%"
        if maxValue - minValue != 0 {
            percent = String(format: "%d", lroundf(Float(value - minValue) / Float(maxValue - minValue) * 100))
        }
        valueLabel.attributedText = String.attributedStringWith(percent, .font(size: ZTScaleValue(50), type: .D_bold), "%", .font(size: ZTScaleValue(24), type: .D_bold))
        
        let colors = [UIColor.custom(.yellow_febf32),UIColor.custom(.red_ffb06b)]
        
        let img = self.getGradientImageWithColors(colors: colors, imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        
        slider.setMinimumTrackImage(img.roundCorner(), for: .normal)
        let img2 = self.getGradientImageWithColors(colors: [UIColor.init(red: 241/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1),UIColor.init(red: 241/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1)], imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        slider.setMaximumTrackImage(img2.roundCorner(), for: .normal)
    }
    
    /// 色温
    private func setupColorTemperatureSlider(value: Int, maxValue: Int, minValue: Int, segmentTag: Int) {
        buttonSeletedTag = segmentTag
        setUpSliderUI()
        setSeletedButton(tag: segmentTag)
       
        
        slider.maximumValue = Float(maxValue)
        slider.minimumValue = Float(minValue)
        slider.setValue(Float(value), animated: true)
        var percent = "0%"
        if maxValue - minValue != 0 {
            percent = String(format: "%d", lroundf(Float(value - minValue) / Float(maxValue - minValue) * 100))
        }
        
        valueLabel.attributedText = String.attributedStringWith(percent, .font(size: ZTScaleValue(50), type: .D_bold), "%", .font(size: ZTScaleValue(24), type: .D_bold))
        
        let colors = [UIColor.custom(.red_ffb06b), UIColor.custom(.yellow_ffd26e), UIColor.custom(.blue_7ecffc)]
        let img = self.getGradientImageWithColors(colors: colors, imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        slider.setMinimumTrackImage(img.roundCorner(), for: .normal)
        let img2 = self.getGradientImageWithColors(colors: colors, imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        slider.setMaximumTrackImage(img2.roundCorner(), for: .normal)
    }
    
    /// 窗帘打开百分比
    private func setupCurtainStateSlider(value: Int, maxValue: Int, minValue: Int, segmentTag: Int) {
        buttonSeletedTag = segmentTag
        setUpSliderUI()
        setSeletedButton(tag: segmentTag)
        detailLabel.text = "开启状态".localizedString
        slider.maximumValue = Float(maxValue)
        slider.minimumValue = Float(minValue)
        slider.setValue(Float(value), animated: true)
        
        var percent = "0%"
        if maxValue - minValue != 0 {
            percent = String(format: "%d", lroundf(Float(value - minValue) / Float(maxValue - minValue) * 100))
        }
        
        valueLabel.attributedText = String.attributedStringWith(percent, .font(size: ZTScaleValue(50), type: .D_bold), "%", .font(size: ZTScaleValue(24), type: .D_bold))
        
        let img = self.getGradientImageWithColors(colors: [UIColor.custom(.blue_2da3f6), UIColor.custom(.blue_2da3f6)], imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        
        slider.setMinimumTrackImage(img.roundCorner(), for: .normal)
        let img2 = self.getGradientImageWithColors(colors: [UIColor.init(red: 241/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1),UIColor.init(red: 241/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1)], imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        slider.setMaximumTrackImage(img2.roundCorner(), for: .normal)
    }
    
    private func setupSensorHumiditySlider(value: Int, maxValue: Int, minValue: Int, segmentTag: Int) {
        buttonSeletedTag = segmentTag
        setUpSliderUI()
        setSeletedButton(tag: segmentTag)
        detailLabel.text = "湿度".localizedString
        slider.maximumValue = Float(maxValue)
        slider.minimumValue = Float(minValue)
        slider.setValue(Float(value), animated: true)
        
        var percent = "0%"
        if maxValue - minValue != 0 {
            percent = String(format: "%d", lroundf(Float(value - minValue) / Float(maxValue - minValue) * 100))
        }

        valueLabel.attributedText = String.attributedStringWith(percent, .font(size: ZTScaleValue(50), type: .D_bold), "%", .font(size: ZTScaleValue(24), type: .D_bold))
        
        let img = self.getGradientImageWithColors(colors: [UIColor.custom(.blue_2da3f6), UIColor.custom(.blue_2da3f6)], imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        
        slider.setMinimumTrackImage(img.roundCorner(), for: .normal)
        let img2 = self.getGradientImageWithColors(colors: [UIColor.init(red: 241/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1),UIColor.init(red: 241/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1)], imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        slider.setMaximumTrackImage(img2.roundCorner(), for: .normal)
    }
    
    private func setupSensorTemperatureSlider(value: Int, maxValue: Int, minValue: Int, segmentTag: Int) {
        buttonSeletedTag = segmentTag
        setUpSliderUI()
        setSeletedButton(tag: segmentTag)
        detailLabel.text = "温度".localizedString
        slider.maximumValue = Float(maxValue)
        slider.minimumValue = Float(minValue)
        slider.setValue(Float(value), animated: true)
        
        let percent = "\(value)°C"

        valueLabel.attributedText = String.attributedStringWith(percent, .font(size: ZTScaleValue(50), type: .D_bold), "°C", .font(size: ZTScaleValue(24), type: .D_bold))
        
        let img = self.getGradientImageWithColors(colors: [UIColor.custom(.blue_2da3f6), UIColor.custom(.blue_2da3f6)], imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        
        slider.setMinimumTrackImage(img.roundCorner(), for: .normal)
        let img2 = self.getGradientImageWithColors(colors: [UIColor.init(red: 241/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1),UIColor.init(red: 241/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1)], imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        slider.setMaximumTrackImage(img2.roundCorner(), for: .normal)
    }
    
    private func setUpSliderUI(){
        containerView.addSubview(line)
        containerView.addSubview(slider)
        containerView.addSubview(valueLabel)
        containerView.addSubview(sureButton)
        containerView.addSubview(detailLabel)
        
        containerView.addSubview(segmentCoverView)
        segmentCoverView.addSubview(miniButton)
        segmentCoverView.addSubview(equalButton)
        segmentCoverView.addSubview(maxButton)
        
        line.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(16.5))
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(0.5))
        }
        
        if buttonSeletedTag != 0 {
            segmentCoverView.snp.makeConstraints {
                $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(24.5))
                $0.centerX.equalToSuperview()
                $0.left.equalTo(ZTScaleValue(15))
                $0.right.equalTo(-ZTScaleValue(15))
                $0.height.equalTo(ZTScaleValue(50))
            }
            
            equalButton.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview()
                $0.width.equalTo(ZTScaleValue(115))
                $0.height.equalTo(ZTScaleValue(40))
            }
            
            miniButton.snp.makeConstraints {
                $0.right.equalTo(equalButton.snp.left).offset(ZTScaleValue(10))
                $0.centerY.width.height.equalTo(equalButton)
            }
            
            maxButton.snp.makeConstraints {
                $0.left.equalTo(equalButton.snp.right).offset(-ZTScaleValue(10))
                $0.centerY.width.height.equalTo(equalButton)
            }
        }else{
            segmentCoverView.snp.makeConstraints {
                $0.edges.equalTo(line)
            }
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(segmentCoverView.snp.bottom).offset(ZTScaleValue(14.5))
            $0.centerX.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(ZTScaleValue(12))
            $0.centerX.equalToSuperview()
        }
        
        sureButton.snp.makeConstraints {
            $0.bottom.equalTo(-ZTScaleValue(25))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(345))
            $0.height.equalTo(ZTScaleValue(50))
        }
        
        slider.snp.makeConstraints {
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(-ZTScaleValue(15))
            $0.top.equalTo(valueLabel.snp.bottom)
            $0.bottom.equalTo(sureButton.snp.top).offset(-ZTScaleValue(20))
        }
        
        slider.frame = CGRect(x: 15, y: 100, width: self.frame.width - 30, height: 100)
        slider.addTarget(self, action: #selector(sliderValueChange(sender:)), for: .valueChanged)
        
        
        //添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapGesture(sender:)))
        tapGesture.delegate = self
        slider.addGestureRecognizer(tapGesture)
        
        slider.height = ZTScaleValue(40)
        slider.setThumbImage(.assets(.sliderThumb), for: .normal)
    }
    
    
    
    
    func getGradientImageWithColors(colors:[UIColor],imgSize: CGSize) -> UIImage {
        
        var arRef = [CGColor]()
        colors.forEach { (ref) in
            arRef.append(ref.cgColor)
        }
        UIGraphicsBeginImageContextWithOptions(imgSize, true, 1)
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: arRef as CFArray, locations: nil)!
        context!.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: imgSize.width, y: 0), options: CGGradientDrawingOptions(rawValue: 0))
        
        let outputImage = UIImage.init(cgImage: (UIGraphicsGetImageFromCurrentImageContext()?.cgImage)!)
        UIGraphicsEndImageContext()
        
        return outputImage
    }
    
    
    @objc func sliderValueChange(sender: UISlider)
    {
        let value = sender.value
        currentValue = lroundf(value)
        
        let valueString = String(format: "%d", lroundf((Float(currentValue) - sender.minimumValue) / (sender.maximumValue - sender.minimumValue) * 100))
        
        
        valueLabel.attributedText = String.attributedStringWith(valueString, .font(size: ZTScaleValue(50), type: .D_bold), "%", .font(size: ZTScaleValue(18), type: .D_bold))
        
        print("当前进度为：\(valueString)"+"%")
        
    }
    
    
    
    @objc func buttonDidSeleted(sender:UIButton){
        buttonSeletedTag = sender.tag
        setSeletedButton(tag: sender.tag)
    }
    
    private func setSeletedButton(tag: Int){
        switch tag {
        case 1:
            miniButton.isSelected = true
            miniButton.backgroundColor = .custom(.blue_2da3f6)
            segmentCoverView.bringSubviewToFront(miniButton)
            
            equalButton.isSelected = false
            equalButton.backgroundColor = .custom(.gray_f6f8fd)
            maxButton.isSelected = false
            maxButton.backgroundColor = .custom(.gray_f6f8fd)
        case 2:
            equalButton.isSelected = true
            equalButton.backgroundColor = .custom(.blue_2da3f6)
            segmentCoverView.bringSubviewToFront(equalButton)
            
            miniButton.isSelected = false
            miniButton.backgroundColor = .custom(.gray_f6f8fd)
            maxButton.isSelected = false
            maxButton.backgroundColor = .custom(.gray_f6f8fd)
        case 3:
            maxButton.isSelected = true
            maxButton.backgroundColor = .custom(.blue_2da3f6)
            segmentCoverView.bringSubviewToFront(maxButton)
            
            equalButton.isSelected = false
            equalButton.backgroundColor = .custom(.gray_f6f8fd)
            miniButton.isSelected = false
            miniButton.backgroundColor = .custom(.gray_f6f8fd)
        default:
            print("")
        }
    }
}

extension VarietyAlertView: UIGestureRecognizerDelegate{
    
    @objc private func actionTapGesture(sender: UITapGestureRecognizer){
        let touchPonit = sender.location(in: slider)
        let value = Float(slider.maximumValue - slider.minimumValue) * Float(touchPonit.x / slider.frame.size.width) + slider.minimumValue
        slider.setValue(Float(value), animated: true)
        currentValue = lroundf(value)
        let valueString = String(format: "%d", lroundf((Float(currentValue) - slider.minimumValue) / (slider.maximumValue - slider.minimumValue) * 100))
        
        valueLabel.attributedText = String.attributedStringWith(valueString, .font(size: ZTScaleValue(50), type: .D_bold), "%", .font(size: ZTScaleValue(18), type: .D_bold))
        
    }
}


