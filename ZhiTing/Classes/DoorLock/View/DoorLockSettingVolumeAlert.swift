//
//  DoorLockSettingVolumeAlert.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/12.
//

import Foundation
import UIKit


class DoorLockSettingVolumeAlert: UIView {
    enum Value: Float {
        case mute = 0
        case low = 0.33
        case mid = 0.66
        case high = 1
        
        var title: String {
            switch self {
            case .mute:
                return "静音".localizedString
            case .low:
                return "低".localizedString
            case .mid:
                return "中".localizedString
            case .high:
                return "高".localizedString
            }
        }
    }
    
    var value: Value? {
        didSet {
            label1.textColor = .custom(.gray_94a5be)
            label2.textColor = .custom(.gray_94a5be)
            label3.textColor = .custom(.gray_94a5be)
            label4.textColor = .custom(.gray_94a5be)
            switch value {
            case .mute:
                label1.textColor = .custom(.blue_2da3f6)
            case .low:
                label2.textColor = .custom(.blue_2da3f6)
            case .mid:
                label3.textColor = .custom(.blue_2da3f6)
            case .high:
                label4.textColor = .custom(.blue_2da3f6)
            default:
                break
            }
        }
    }
    
    var valueCallback: ((Value) -> ())?

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

 
    private lazy var slider = CustomSlider().then { slider in
        slider.frame = CGRect(x: 15, y: 0, width: self.frame.width - 30, height: 40)
        slider.maximumValue = 1
        slider.minimumValue = 0
        slider.addTarget(self, action: #selector(sliderValueChange(sender:)), for: .valueChanged)
        slider.isContinuous = false
        slider.height = 40
        slider.setThumbImage(.assets(.sliderThumb), for: .normal)
        
        let colors = [UIColor.custom(.blue_2da3f6), UIColor.custom(.blue_2da3f6)]
        
        let img = self.getGradientImageWithColors(colors: colors, imgSize: CGSize(width: slider.frame.size.width, height: 40))
        
        slider.setMinimumTrackImage(img.roundCorner(), for: .normal)
        let img2 = self.getGradientImageWithColors(colors: [UIColor.init(red: 241/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1),UIColor.init(red: 241/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1)], imgSize: CGSize(width: slider.frame.size.width, height: 40))
        slider.setMaximumTrackImage(img2.roundCorner(), for: .normal)
        
        //添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapGesture(sender:)))
        tapGesture.delegate = self
        slider.addGestureRecognizer(tapGesture)
        slider.tintColor = .custom(.blue_2da3f6)
        
    }
    
    private lazy var label1 = Label().then {
        $0.text = "静音".localizedString
        $0.font = .font(size: 12, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
    }
    
    private lazy var label2 = Label().then {
        $0.text = "低".localizedString
        $0.font = .font(size: 12, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
    }
    
    private lazy var label3 = Label().then {
        $0.text = "中".localizedString
        $0.font = .font(size: 12, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
    }
    
    private lazy var label4 = Label().then {
        $0.text = "高".localizedString
        $0.font = .font(size: 12, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
    }
    
    private lazy var line1 = UIView().then {
        $0.backgroundColor = .custom(.gray_94a5be)
    }
    
    private lazy var line2 = UIView().then {
        $0.backgroundColor = .custom(.gray_94a5be)
    }
    
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    convenience init(value: Int) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        titleLabel.text = "门锁音量".localizedString
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(line)
        containerView.addSubview(slider)
        slider.addSubview(line1)
        slider.addSubview(line2)
        
        containerView.addSubview(label1)
        containerView.addSubview(label2)
        containerView.addSubview(label3)
        containerView.addSubview(label4)
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
            $0.left.equalToSuperview().offset(20.5)
            $0.top.equalToSuperview().offset(16)
            $0.right.equalTo(closeButton.snp.left).offset(-10)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17.5)
            $0.right.equalToSuperview().offset(-15)
            $0.height.width.equalTo(ZTScaleValue(9))
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(16.5))
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(0.5))
        }
        
        slider.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.height.equalTo(40)
            $0.right.equalToSuperview().offset(-15)
            $0.top.equalTo(line.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().offset(-20 - Screen.k_nav_height)
        }
        
        line1.snp.makeConstraints {
            $0.width.equalTo(0.5)
            $0.top.bottom.equalToSuperview()
            $0.left.equalTo(slider.snp.left).offset(slider.frame.width / 3)
        }
        
        line2.snp.makeConstraints {
            $0.width.equalTo(0.5)
            $0.top.bottom.equalToSuperview()
            $0.right.equalTo(slider.snp.right).offset(-slider.frame.width / 3)
        }
        
        label1.snp.makeConstraints {
            $0.left.equalTo(slider.snp.left)
            $0.top.equalTo(slider.snp.bottom).offset(15)
        }
        
        label2.snp.makeConstraints {
            $0.left.equalTo(slider.snp.left).offset(slider.frame.width / 3)
            $0.top.equalTo(slider.snp.bottom).offset(15)
        }
        
        label3.snp.makeConstraints {
            $0.right.equalTo(slider.snp.right).offset(-slider.frame.width / 3)
            $0.top.equalTo(slider.snp.bottom).offset(15)
        }
        
        label4.snp.makeConstraints {
            $0.right.equalTo(slider.snp.right)
            $0.top.equalTo(slider.snp.bottom).offset(15)
        }
        
        
        
    }
    
    
    func getGradientImageWithColors(colors: [UIColor], imgSize: CGSize) -> UIImage {
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
    
    @objc func sliderValueChange(sender: UISlider) {
        switch slider.value {
        case 0...0.15:
            slider.setValue(0, animated: true)
            value = .mute
            valueCallback?(.mute)
        case 0.16...0.47:
            slider.setValue(0.33, animated: true)
            value = .low
            valueCallback?(.low)
        case 0.48...0.8:
            slider.setValue(0.66, animated: true)
            value = .mid
            valueCallback?(.mid)
        case 0.81...1:
            slider.setValue(1, animated: true)
            value = .high
            valueCallback?(.high)
        default:
            break
        }
        
        
    }
}

extension DoorLockSettingVolumeAlert: UIGestureRecognizerDelegate {
    
    @objc private func actionTapGesture(sender: UITapGestureRecognizer){
        let touchPonit = sender.location(in: slider)
        let fvalue = Float(slider.maximumValue - slider.minimumValue) * Float(touchPonit.x / slider.frame.size.width) + slider.minimumValue
      
        switch Float(fvalue) {
        case 0...0.15:
            slider.setValue(0, animated: true)
            value = .mute
            valueCallback?(.mute)
        case 0.16...0.47:
            slider.setValue(0.33, animated: true)
            value = .low
            valueCallback?(.low)
        case 0.48...0.8:
            slider.setValue(0.66, animated: true)
            value = .mid
            valueCallback?(.mid)
        case 0.81...1:
            slider.setValue(1, animated: true)
            value = .high
            valueCallback?(.high)
        default:
            break
        }
        
    }
}

