//
//  CustomSlider.swift
//  ZhiTing
//
//  Created by zy on 2021/4/23.
//

import UIKit

class CustomSlider: UISlider {

    var height: CGFloat = 0.0
 
    override func minimumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }
    
    override func maximumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }
    // 控制slider的宽和高，这个方法才是真正的改变slider滑道的高的
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.trackRect(forBounds: bounds)
        return CGRect.init(x: rect.origin.x, y: (bounds.size.height-height)/2, width: bounds.size.width, height: height)
    }
    // 改变滑块的触摸范围
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var trect = rect
        trect.origin.x -= 10
        trect.size.width += 20
        
        var tbounds = bounds
        tbounds.origin.x -= 20
        tbounds.size.width += 20
        tbounds.size.height += 20
        
        return super.thumbRect(forBounds: tbounds, trackRect: trect, value: value)
    }
}
