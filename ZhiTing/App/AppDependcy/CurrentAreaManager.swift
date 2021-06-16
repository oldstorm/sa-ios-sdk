//
//  CurrentAreaManager.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/21.
//

import UIKit
import Combine

class CurrentAreaManager {
    let currentAreaPublisher = PassthroughSubject<Area, Never>()
    
    var currentArea = Area() {
        didSet {
            currentAreaPublisher.send(currentArea)
        }
    }

}
