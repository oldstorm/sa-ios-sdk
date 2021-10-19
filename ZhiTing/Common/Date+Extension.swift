//
//  Date+Extension.swift
//  ZhiTing
//
//  Created by iMac on 2021/9/30.
//

import Foundation

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

}
