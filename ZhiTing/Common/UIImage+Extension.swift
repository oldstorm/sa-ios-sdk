//
//  UIImage+Extension.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/29.
//

import Foundation

extension UIImage {
    /**
     设置是否是圆角
     */
    func roundCorner() -> UIImage{
        return self.roundCorner(radius: 10, size: self.size)
    }
    /**
     设置是否是圆角
     - parameter radius: 圆角大小
     - parameter size:   size
     - returns: 圆角图片
     */
    func roundCorner(radius: CGFloat, size: CGSize) -> UIImage {
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
