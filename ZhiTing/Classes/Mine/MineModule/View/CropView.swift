//
//  CropView.swift
//  ZhiTing
//
//  Created by iMac on 2022/2/24.
//

import Foundation
import UIKit

class CropView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath()
        
        /// top-left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: 14))

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: 14, y: rect.minY))
        /// top-right corner
        path.move(to: CGPoint(x: rect.maxX - 14, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: 14))
        /// bottom-left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - 14))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 14, y: rect.maxY))
        /// bottom-right corner
        path.move(to: CGPoint(x: rect.maxX - 14, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 14))

        
        UIColor.white.set()
        path.lineWidth = 4
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        path.stroke()
    }


}
