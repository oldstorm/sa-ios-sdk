//
//  UIColor+Extension.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/10.
//

import Foundation

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        var hex = hex
        
        if hex.count == 7 {
            hex.append("ff")
        }

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
    
}


extension UIColor {
    static func custom(_ customColor: CustomColors) -> UIColor {
        return UIColor(named: customColor.colorName) ?? .white
    }
}
