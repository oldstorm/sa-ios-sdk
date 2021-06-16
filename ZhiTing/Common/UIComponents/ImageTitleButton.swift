//
//  ImageTitleButton.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/12.
//

import UIKit


class ImageTitleButton: UIButton {
    /// click callback
    var clickCallBack: (() -> ())? {
        didSet {
            addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        }
    }
    
    lazy var iconImage = ImageView().then { $0.contentMode = .scaleAspectFit }
    
    @objc private func btnClick(_ btn: Button) {
        clickCallBack?()
    }
    
    convenience init(frame: CGRect, icon: UIImage?, title: String, titleColor: UIColor?, backgroundColor: UIColor) {
        self.init(frame: frame)
        self.backgroundColor = backgroundColor
        setTitle(title, for: .normal)
        
        titleLabel?.font = .font(size: 14, type: .bold)
        titleLabel?.textAlignment = .center
        setTitleColor(titleColor, for: .normal)
        layer.cornerRadius = 10
        addSubview(iconImage)
        iconImage.image = icon
        if icon != nil {
            titleEdgeInsets.left = 20
        }
        
    }
    
    override func layoutSubviews() {
        titleLabel?.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(iconImage.image == nil ? 0 : 20).priority(.high)
            $0.centerY.equalToSuperview()
        }
        
        iconImage.snp.makeConstraints {
            $0.height.width.equalTo(14)
            $0.centerY.equalTo(titleLabel!.snp.centerY)
            $0.right.equalTo(titleLabel!.snp.left).offset(-12)
        }
    }
}

class RefreshButton: ImageTitleButton {
    enum RefreshStyle {
        case refresh
        case reconnect
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    private var timer: Timer?
    
    private var refreshingIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }

    convenience init(style: RefreshStyle) {
        self.init(frame: CGRect.zero)
        addSubview(iconImage)
        addSubview(refreshingIcon)
        
        titleLabel?.font = .font(size: 12, type: .regular)
        titleLabel?.textAlignment = .center
        titleEdgeInsets.left = 10

        
        switch style {
        case .refresh:
            setTitle("刷新".localizedString, for: .normal)
            backgroundColor = .clear
            iconImage.image = .assets(.icon_update_orange)
            setTitleColor(.custom(.oringe_f6ae1e), for: .normal)
            refreshingIcon.image = .assets(.refreshing_orange)
        case .reconnect:
            setTitle("重新连接".localizedString, for: .normal)
            backgroundColor = .custom(.blue_2da3f6)
            layer.cornerRadius = ZTScaleValue(4)
            iconImage.image = .assets(.icon_update)
            setTitleColor(.custom(.white_ffffff), for: .normal)
            refreshingIcon.image = .assets(.refreshing_white)
        }
        
        refreshingIcon.snp.makeConstraints {
            $0.edges.equalTo(iconImage)
        }
        
    }
    
    func startAnimate() {
        refreshingIcon.isHidden = false
        iconImage.isHidden = true

        timer?.invalidate()
        var angle: CGFloat = 0.0
        timer = Timer(timeInterval: 0.05, repeats: true, block: { [weak self] _ in
            angle -= 0.5
            self?.refreshingIcon.transform = CGAffineTransform(rotationAngle: angle)
        })
        timer?.fire()
        
        RunLoop.main.add(timer!, forMode: .common)
        
    }
    
    func stopAnimate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.refreshingIcon.isHidden = true
            self?.iconImage.isHidden = false
            self?.timer?.invalidate()
            self?.refreshingIcon.transform = CGAffineTransform.identity
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
