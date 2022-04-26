//
//  DeviceRGBAlert.swift
//  ZhiTing
//
//  Created by iMac on 2021/12/7.
//


import UIKit
import FlexColorPicker


class DeviceRGBAlert: UIView, DeviceAttrAlert {
    
    
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
            self.removeFromSuperview()
        }
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
    
    convenience init(color: HSBColor){
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        titleLabel.text = "彩色".localizedString
        setupColorPalette(color: color)
       
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



// MARK: - 色谱相关方法
extension DeviceRGBAlert {
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
