//
//  UITableView+Extension.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/24.
//

import UIKit


protocol ReusableView {
    static var reusableIdentifier: String { get }
}


extension ReusableView where Self: UIView {
    static var reusableIdentifier: String {
        return NSStringFromClass(self)
    }
}
