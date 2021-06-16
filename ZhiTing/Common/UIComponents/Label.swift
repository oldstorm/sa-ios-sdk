//
//  Label.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit


class Label: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        lineBreakMode = .byCharWrapping
        textColor = .custom(.black_3f4663)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        lineBreakMode = .byCharWrapping
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
