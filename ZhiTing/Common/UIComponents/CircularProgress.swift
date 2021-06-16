//
//  CircularProgress.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/1.
//

import UIKit

class CircularProgress: UIView {
    lazy var progressBackgroundColor = UIColor.custom(.gray_eeeeee)
    lazy var progressColor = UIColor.custom(.blue_2da3f6)
    lazy var progressWidth: CGFloat = 3
    lazy var progress: CGFloat = 0
    var timer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(progress: CGFloat) {
        self.progress = progress
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let backgroundPath = UIBezierPath()
        progressBackgroundColor.set()
        backgroundPath.lineWidth = progressWidth
        backgroundPath.lineCapStyle = .round
        backgroundPath.lineJoinStyle = .round
        
        let radius = (min(rect.size.width, rect.size.height) - progressWidth) * 0.5
        
        backgroundPath.addArc(withCenter: CGPoint(x: rect.size.width * 0.5, y: rect.size.height * 0.5), radius: radius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi * 1.5 + CGFloat.pi * 2, clockwise: true)
        backgroundPath.stroke()
        
        let progressPath = UIBezierPath()
        progressColor.set()
        progressPath.lineWidth = progressWidth
        progressPath.lineCapStyle = .round
        progressPath.lineJoinStyle = .round
        progressPath.addArc(withCenter: CGPoint(x: rect.size.width * 0.5, y: rect.size.height * 0.5), radius: radius, startAngle: CGFloat.pi * 1.5, endAngle: (CGFloat.pi * 1.5 + CGFloat.pi * 2) * progress, clockwise: true)
        progressPath.stroke()
    }

    
    func startRotating() {
        timer?.invalidate()
        var angle: CGFloat = 0
        timer = Timer(timeInterval: 0.01, repeats: true, block: { (timer) in
            angle += 0.1
            self.transform = CGAffineTransform.init(rotationAngle: angle)
        })
        timer?.fire()
        
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func stopRotating() {
        timer?.invalidate()
    }
}
