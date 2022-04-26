//
//  SettingSwitchButton.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/11.
//


import UIKit

class SettingSwitchButton: UIControl {
    /// 背景view
    private var bgView: UIView!
    /// 开关圆点view
    private var pointView: UIView!
    /// 打开的颜色
    var onColor = UIColor.custom(.blue_2da3f6)
    /// 关闭的颜色
    var offColor = UIColor.custom(.gray_eeeeee)
    
    var margin: CGFloat = 2.5
    
    var isOn: Bool = false
    
    var stateChangeCallback: ((Bool) -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        /// 背景
        bgView = UIView()
        bgView.backgroundColor = offColor
        bgView.frame = frame
        bgView.layer.cornerRadius = frame.height / 2
        bgView.layer.masksToBounds = true
        bgView.isUserInteractionEnabled = true

        /// 圆点
        pointView = UIView()
        pointView.backgroundColor = UIColor.white
        pointView.layer.masksToBounds = true
        pointView.isUserInteractionEnabled = true
        pointView.frame = CGRect(x: margin, y: margin, width: frame.height - 2 * margin, height: frame.height - 2 * margin)
        pointView.layer.cornerRadius = (frame.height - 2 * margin) / 2

        addSubview(bgView)
        addSubview(pointView)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stateChanges)))
        self.isUserInteractionEnabled = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    

}

extension SettingSwitchButton {
    func setIsOn(_ on: Bool) {
        on ? onAnimation() : offAnimation()
        isOn = on
    }

    @objc
    private func stateChanges() {
        isOn ? offAnimation() : onAnimation()
        isOn = !isOn
        stateChangeCallback?(isOn)
    }
    
    private func onAnimation() {
        let endX: CGFloat = frame.width - (frame.height - 2 * margin) - margin
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.pointView.frame.origin.x = endX
            self.bgView.backgroundColor = self.onColor
        }
    }

    private func offAnimation() {
        let endX: CGFloat = margin
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.pointView.frame.origin.x = endX
            self.bgView.backgroundColor = self.offColor
        }
    }

}
