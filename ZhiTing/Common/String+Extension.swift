//
//  String+Extension.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/24.
//

import UIKit

extension String {
    
    func boundingRect(with size: CGSize, attributes: [NSAttributedString.Key: Any]) -> CGRect {
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let rect = self.boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return snap(rect)
    }
    
    func size(thatFits size: CGSize, font: UIFont, maximumNumberOfLines: Int = 0) -> CGSize {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        var size = self.boundingRect(with: size, attributes: attributes).size
        if maximumNumberOfLines > 0 {
            size.height = min(size.height, CGFloat(maximumNumberOfLines) * font.lineHeight)
        }
        return size
    }
    
    func width(with font: UIFont, maximumNumberOfLines: Int = 0) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        return self.size(thatFits: size, font: font, maximumNumberOfLines: maximumNumberOfLines).width
    }
    
    func height(thatFitsWidth width: CGFloat, font: UIFont, maximumNumberOfLines: Int = 0) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return self.size(thatFits: size, font: font, maximumNumberOfLines: maximumNumberOfLines).height
    }
    
    static func attributedStringWith(_ prefix:String,_ prefixFont:UIFont,_ suffix:String, _ suffixFont:UIFont) -> NSAttributedString {
        let start = NSMutableAttributedString(string: prefix)
              start.addAttribute(.font, value: prefixFont, range: NSRange(location: 0, length: prefix.count))
        let end = NSMutableAttributedString(string: suffix)
        end.addAttribute(.font, value: suffixFont, range: NSRange(location: 0, length: suffix.count))
        start.append(end)
        
        return start
    }
    
}

fileprivate func snap(_ x: CGFloat) -> CGFloat {
    let scale = UIScreen.main.scale
    return ceil(x * scale) / scale
}

fileprivate func snap(_ point: CGPoint) -> CGPoint {
    return CGPoint(x: snap(point.x), y: snap(point.y))
}

fileprivate func snap(_ size: CGSize) -> CGSize {
    return CGSize(width: snap(size.width), height: snap(size.height))
}

fileprivate func snap(_ rect: CGRect) -> CGRect {
    return CGRect(origin: snap(rect.origin), size: snap(rect.size))
}



extension String {
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
                                                                .urlQueryAllowed)
        return encodeUrlString ?? self
    }
     
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? self
    }
}

extension String {
    var localizedString:String{
        get{
            return NSLocalizedString(self, comment: self)
        }
    }
}

enum Language {
    case chinese
    case english
}

/// Get current system language
/// - Returns: language
func getCurrentLanguage() -> Language {
    let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
    
    switch String(describing: preferredLang) {
    case "en-US", "en-CN", "en":
        return .english
    case "zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans":
        return .chinese
    default:
        return .chinese
    }
}
