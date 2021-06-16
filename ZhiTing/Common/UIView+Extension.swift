//
//  UIView+Extension.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/13.
//

import UIKit

extension UIView {
    /// 添加圆角
    ///
    /// - Parameters:
    ///   - corners: 圆角的边
    ///   - radii: 半径
    ///   - borderWidth: 圆边线宽度
    ///   - borderColor: 圆边线的颜色
    func addRounded(corners: UIRectCorner, radii: CGSize, borderWidth: CGFloat, borderColor: UIColor) {
        UIGraphicsBeginImageContext(self.bounds.size)
        let rounded = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: radii)
        rounded.lineWidth = borderWidth
        rounded.lineJoinStyle = .round
        UIGraphicsBeginImageContext(self.bounds.size);
        borderColor.setStroke()
        rounded.stroke()
        UIGraphicsEndImageContext();
        let shape = CAShapeLayer.init()
        shape.path = rounded.cgPath
        self.layer.mask = shape
        UIGraphicsEndImageContext()
    }
}
