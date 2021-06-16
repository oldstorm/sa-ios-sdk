//
//  SwitchButton.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/1.
//

import UIKit

class SwitchButton: UIButton {
    /// if enhance the click scope
    lazy var isEnhanceClick = true
    /// enhance offset
    lazy var enhanceOffset: CGFloat = -20
    
    var statusCallback: ((_ isOn: Bool) -> ())?
    
    var isOn = false {
        didSet {
            self.isSelected = isOn
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(.assets(.switch_on), for: .selected)
        setImage(.assets(.switch_off), for: .normal)
        addTarget(self, action: #selector(statusChanged), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func statusChanged() {
        self.isOn = !self.isOn
        statusCallback?(self.isOn)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isEnhanceClick {
            let biggerFrame = self.bounds.inset(by: UIEdgeInsets.init(top: enhanceOffset, left: enhanceOffset, bottom: enhanceOffset, right: enhanceOffset))
            return biggerFrame.contains(point)
        } else {
            return super.point(inside: point, with: event)
        }
        
    }
}
