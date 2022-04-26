//
//  Colors.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit


enum CustomColors: String {
    case black_3f4663
    case black_333333
    case black_555b73
    case gray_cfd6e0
    case blue_2da3f6
    case blue_eaf6fe
    case white_ffffff
    case gray_f6f8fd
    case gray_f1f4fd
    case gray_f1f4fc
    case gray_94a5be
    case gray_dddddd
    case gray_f5f5f5
    case gray_eeeeee
    case gray_dde5eb
    case oringe_f6ae1e
    case oringe_fdf3df
    case red_fe0000
    case yellow_f3a934
    case blue_7ecffc
    case blue_427aed
    case yellow_ffd26e
    case red_ffb06b
    case yellow_febf32
    case green_07b5a3
    
    var colorName: String {
        return "color_\(self.rawValue.components(separatedBy: "_").last ?? "")"
    }
}


