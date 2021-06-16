//
//  Button.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit

class Button: UIButton {
    /// if enhance the click scope
    lazy var isEnhanceClick = false
    /// enhance offset
    lazy var enhanceOffset: CGFloat = -20
    
    /// click callback
    var clickCallBack: ((Button) -> ())? {
        didSet {
            addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func btnClick(_ btn: Button) {
        clickCallBack?(btn)
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

