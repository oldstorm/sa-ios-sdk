//
//  VarietyAlertView.swift
//  ZhiTing
//
//  Created by zy on 2021/4/23.
//

import UIKit


enum AlertType {
    case tableViewType(data: [String])
    case lightDegreeType(value: CGFloat, segmentSegmentTag: Int)//亮度
    case colorTemperatureType(value: CGFloat, segmentSegmentTag: Int)//色温

}

class VarietyAlertView: UIView {
    

    ///////////////////////////////////////////////////////////Public//////////////////////////////////////////////////////////// / / / /
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
    
    private lazy var closeButton = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    private var currentType = AlertType.tableViewType(data: [""])
    /////////////////////////////////////////////////////////// Public //////////////////////////////////////////////////////////// / / / /

    
    /////////////////////////////////////////////////////////// tableviewType //////////////////////////////////////////////////////////// / / / /
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
    /////////////////////////////////////////////////////////// tableviewType //////////////////////////////////////////////////////////// / / / /

    
    /////////////////////////////////////////////////////////// lightDegreeType &  colorTemperatureType //////////////////////////////////////////////////////////// / / / /
    var valueCallback: ((_ value: CGFloat, _ seletedTag: Int) -> ())?
    var slider = CustomSlider()
    
    lazy var currentValue : CGFloat = 0
    
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
            self.valueCallback!(self.currentValue , self.buttonSeletedTag)
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
    /////////////////////////////////////////////////////////// lightDegreeType &  colorTemperatureType //////////////////////////////////////////////////////////// / / / /

    
    ///////////////////////////////////////////////////////////  Lift Cycle  //////////////////////////////////////////////////////////// / / / /
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
        case .lightDegreeType(let value,let segmentTag):
            setupLightDegreeSlider(value: value, segmentTag: segmentTag)
        case .colorTemperatureType(let value,let segmentTag):
            setupColorTemperatureSlider(value: value, segmentTag: segmentTag)
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
                }
                super.removeFromSuperview()
            }
        })
    }

}

//tableViewType
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


//lightDegreeType & colorTemperatureType
extension VarietyAlertView {
    
    private func setupLightDegreeSlider(value: CGFloat, segmentTag: Int) {
        buttonSeletedTag = segmentTag
        setUpSliderUI()
        setSeletedButton(tag: segmentTag)
        valueLabel.attributedText = String.attributedStringWith(String(format: "%.0f", value * 100), .font(size: ZTScaleValue(50), type: .D_bold), "%", .font(size: ZTScaleValue(24), type: .D_bold))
        slider.setValue(Float(value), animated: true)
        
        let colors = [UIColor.custom(.yellow_febf32),UIColor.custom(.red_ffb06b)]
        
        let img = self.getGradientImageWithColors(colors: colors, imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))

        slider.setMinimumTrackImage(img.isRoundCorner(), for: .normal)
        let img2 = self.getGradientImageWithColors(colors: [UIColor.init(red: 241/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1),UIColor.init(red: 241/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1)], imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        slider.setMaximumTrackImage(img2.isRoundCorner(), for: .normal)
    }
    
    private func setUpSliderUI(){
        containerView.addSubview(line)
        containerView.addSubview(slider)
        containerView.addSubview(valueLabel)
        containerView.addSubview(sureButton)
        
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


        
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(segmentCoverView.snp.bottom).offset(ZTScaleValue(38.5))
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
    
    private func setupColorTemperatureSlider(value: CGFloat, segmentTag: Int) {
        buttonSeletedTag = segmentTag
        setUpSliderUI()
        setSeletedButton(tag: segmentTag)
        valueLabel.attributedText = String.attributedStringWith(String(format: "%.0f", value * 100), .font(size: ZTScaleValue(50), type: .D_bold), "%", .font(size: ZTScaleValue(24), type: .D_bold))
        slider.setValue(Float(value), animated: true)
        
        let colors = [UIColor.custom(.red_ffb06b), UIColor.custom(.yellow_ffd26e), UIColor.custom(.blue_7ecffc)]
        let img = self.getGradientImageWithColors(colors: colors, imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        slider.setMinimumTrackImage(img.isRoundCorner(), for: .normal)
        let img2 = self.getGradientImageWithColors(colors: colors, imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        slider.setMaximumTrackImage(img2.isRoundCorner(), for: .normal)
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
    
    
    @objc func sliderValueChange(sender:UISlider)
    {
            let value = sender.value
            let valueString = String(format: "%.0f", value * 100)
            currentValue = CGFloat(value)
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
    
    @objc private func actionTapGesture(sender:UITapGestureRecognizer){
        let touchPonit = sender.location(in: slider)
        let value = CGFloat(slider.maximumValue - slider.minimumValue) * (touchPonit.x / slider.frame.size.width)
        slider.setValue(Float(value), animated: true)
        let valueString = String(format: "%.0f", value * 100)
        currentValue = CGFloat(value)
        valueLabel.attributedText = String.attributedStringWith(valueString, .font(size: ZTScaleValue(50), type: .D_bold), "%", .font(size: ZTScaleValue(18), type: .D_bold))

    }
}

extension UIImage {
    /**
       设置是否是圆角(默认:3.0,图片大小)
       */
      func isRoundCorner() -> UIImage{
        return self.isRoundCorner(radius: 10, size: self.size)
      }
      /**
       设置是否是圆角
       - parameter radius: 圆角大小
       - parameter size:   size
       - returns: 圆角图片
       */
      func isRoundCorner(radius:CGFloat,size:CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        //开始图形上下文
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        //绘制路线
        UIGraphicsGetCurrentContext()!.addPath(UIBezierPath(roundedRect: rect,
                                                            byRoundingCorners: UIRectCorner.allCorners,
                                                            cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        //裁剪
        UIGraphicsGetCurrentContext()!.clip()
        //将原图片画到图形上下文
        self.draw(in: rect)
        UIGraphicsGetCurrentContext()!.drawPath(using: .fillStroke)
        let outputImage = UIImage.init(cgImage: (UIGraphicsGetImageFromCurrentImageContext()?.cgImage)!)

        //关闭上下文
        UIGraphicsEndImageContext();
        return outputImage
      }
}
