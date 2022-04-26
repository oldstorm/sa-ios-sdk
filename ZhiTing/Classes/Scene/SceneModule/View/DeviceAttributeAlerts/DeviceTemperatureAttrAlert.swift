//
//  DeviceTemperatureAttrAlert.swift
//  ZhiTing
//
//  Created by iMac on 2021/12/8.
//


import UIKit

class DeviceTemperatureAttrAlert: UIView, DeviceAttrAlert {
    var valueCallback: ((_ value: Float, _ seletedTag: Int) -> ())?
    
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

    
   
    
    var slider = CustomSlider()
    
    lazy var currentValue : Float = 0
    
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
    
    
    // MARK: - Life Cycle
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    convenience init(value: Float, maxValue: Float, minValue: Float, segmentTag: Int) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        titleLabel.text = "温度".localizedString
        currentValue = value
        setupLightDegreeSlider(value: value, maxValue: maxValue, minValue: minValue, segmentTag: segmentTag)
        
        
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
    
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
    
    private func dismissWithCallback(value: CGFloat) {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }, completion: { isFinished in
            if isFinished {
                super.removeFromSuperview()
            }
        })
    }
    
}






extension DeviceTemperatureAttrAlert {
    
    /// 温度
    private func setupLightDegreeSlider(value: Float, maxValue: Float, minValue: Float, segmentTag: Int) {
        buttonSeletedTag = segmentTag
        setUpSliderUI()
        setSeletedButton(tag: segmentTag)
        
        
        slider.maximumValue = maxValue
        slider.minimumValue = minValue
        slider.setValue(value, animated: true)
        
        
        valueLabel.attributedText = String.attributedStringWith("\(value)", .font(size: ZTScaleValue(50), type: .D_bold), "°C", .font(size: ZTScaleValue(24), type: .D_bold))
        
        let colors = [UIColor.custom(.blue_2da3f6),UIColor.custom(.blue_2da3f6)]
        
        let img = self.getGradientImageWithColors(colors: colors, imgSize: CGSize(width: slider.frame.size.width, height: ZTScaleValue(40)))
        
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
        let value = (sender.value * 10).rounded() / 10.0
        currentValue = value
        
        valueLabel.attributedText = String.attributedStringWith("\(currentValue)", .font(size: ZTScaleValue(50), type: .D_bold), "°C", .font(size: ZTScaleValue(18), type: .D_bold))
        
        
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

extension DeviceTemperatureAttrAlert: UIGestureRecognizerDelegate{
    
    @objc private func actionTapGesture(sender: UITapGestureRecognizer){
        let touchPonit = sender.location(in: slider)
        let value = ((slider.maximumValue - slider.minimumValue) * Float(touchPonit.x / slider.frame.size.width))  + slider.minimumValue
        let str = String(format: "%.1f", value)
        currentValue = Float(str) ?? value
        slider.setValue(currentValue, animated: true)
        
        let valueString = "\(currentValue)"
        
        valueLabel.attributedText = String.attributedStringWith(valueString, .font(size: ZTScaleValue(50), type: .D_bold), "°C", .font(size: ZTScaleValue(18), type: .D_bold))
        
    }
}



