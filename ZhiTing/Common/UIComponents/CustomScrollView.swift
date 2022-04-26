//
//  CustomScrollView.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/29.
//

import Foundation

class CustomScrollView: UIScrollView, UIGestureRecognizerDelegate {
    enum Direction {
        case horizontal
        case vertical
    }

    var direction: Direction = .horizontal

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == panGestureRecognizer {
            let translation = panGestureRecognizer.velocity(in: self)
            if abs(translation.x) > abs(translation.y) {
                return direction == .horizontal
            } else {
                return direction == .vertical
            }
        }

        return true
    }
    
}
