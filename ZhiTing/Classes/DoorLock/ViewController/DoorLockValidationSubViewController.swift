//
//  DoorLockValidationSubViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/19.
//

import Foundation
import JXSegmentedView

class DoorLockValidationSubViewController: BaseViewController {
    let userType: DoorLockUserType
    
    init(userType: DoorLockUserType) {
        self.userType = userType
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension DoorLockValidationSubViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
