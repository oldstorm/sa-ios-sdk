//
//  Fonts.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//
import UIKit

extension UIFont {
    
    enum AppFontType: String {
        case bold = "PingFangSC-SemiBold"
        case regular = "PingFangSC-Regular"
        case medium = "PingFangSC-Medium"
        case light = "PingFangSC-Light"
        case D_bold = "DINAlternate-Bold"
        case D_Medium = "DINAlternate-Medium"
    }
    /// Generate App font
    /// - Parameters:
    ///   - size: font size
    ///   - type: appFontType
    /// - Returns: App font
    static func font(size: CGFloat, type: AppFontType = .regular) -> UIFont {
        let name = type.rawValue
        guard let font = UIFont(name: name, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}
