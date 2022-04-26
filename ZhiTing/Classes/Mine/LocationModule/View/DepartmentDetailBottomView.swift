//
//  DepartmentDetailBottomView.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/16.
//

import Foundation
import UIKit

class DepartmentDetailBottomView: UIView {
    var callback: ((BtnType) -> ())?
    
    var types = [BtnType]()

    convenience init() {
        self.init(frame: .zero)
    }
    
    func setBtns(types: [BtnType]) {
        subviews.forEach { $0.removeFromSuperview() }
        self.types = types
        let width = (Screen.screenWidth - CGFloat((types.count + 1) * 15)) / CGFloat(types.count)
        var offset: CGFloat = 15
        types.forEach { type in
            let btn = ImageTitleButton(frame: .zero, icon: nil, title: "\(type)", titleColor: UIColor.custom(.blue_2da3f6), backgroundColor: UIColor.custom(.white_ffffff))
            btn.clickCallBack = { [weak self] in
                guard let self = self else { return }
                self.callback?(type)
            }
            
            addSubview(btn)
            btn.snp.makeConstraints {
                $0.width.equalTo(width)
                $0.top.bottom.equalToSuperview()
                $0.left.equalTo(offset)
            }
            offset += width + 15.0
        }
    }
    

}

extension DepartmentDetailBottomView {
    enum BtnType: CustomStringConvertible {
        case addMember
        case departmentSetting
        
        var description: String {
            switch self {
            case .addMember:
                return "添加成员".localizedString
            case .departmentSetting:
                return "部门设置".localizedString
            }
        }
    }
}
