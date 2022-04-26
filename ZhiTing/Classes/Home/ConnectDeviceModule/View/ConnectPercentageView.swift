//
//  ConnectDeviceView.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/1.
//

import Foundation

class ConnectPercentageView: UIView {
    lazy var progressBackgroundColor = UIColor(red: 207/255, green: 210/255, blue: 230/255, alpha: 1)
    lazy var progressColor = UIColor.custom(.blue_2da3f6)
    lazy var progressWidth: CGFloat = 10
    lazy var progress: CGFloat = 0
    let attributes1 = [NSAttributedString.Key.foregroundColor : UIColor.custom(.black_3f4663), NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 72)]
    let attributes2 = [NSAttributedString.Key.foregroundColor : UIColor.custom(.black_3f4663), NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 48)]

    private lazy var percentageLabel = Label().then {
        let attrStr = NSMutableAttributedString(string: "0", attributes: attributes1 as [NSAttributedString.Key : Any])
        let attrStr2 = NSAttributedString(string: "%", attributes: attributes2 as [NSAttributedString.Key : Any])
        attrStr.append(attrStr2)
        $0.attributedText = attrStr
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = UIColor.clear
        addSubview(percentageLabel)
        
        percentageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(10)
        }
    }
    
    func setProgress(progress: CGFloat) {
        self.progress = progress
        let attrStr = NSMutableAttributedString(string: "\(Int(progress * 100))", attributes: attributes1 as [NSAttributedString.Key : Any])
        let attrStr2 = NSAttributedString(string: "%", attributes: attributes2 as [NSAttributedString.Key : Any])
        attrStr.append(attrStr2)
        percentageLabel.attributedText = attrStr
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        progressBackgroundColor.set()
        let progressBackgroundPath = UIBezierPath()
        progressBackgroundPath.lineWidth = 1
        progressBackgroundPath.lineCapStyle = .round
        progressBackgroundPath.lineJoinStyle = .round
        
        let innerRadius: CGFloat = (min(rect.size.width, rect.size.height) - progressWidth) / 2 * 0.85
        let outerRadius: CGFloat = (min(rect.size.width, rect.size.height) - progressWidth) / 2 * 0.95
        let numTicks = 96

        for i in 0..<numTicks {
            let angle = CGFloat(i) * 2 * CGFloat.pi / CGFloat(numTicks)
            let inner = CGPoint(x: innerRadius * cos(angle) + rect.size.width / 2, y: innerRadius * sin(angle) + rect.size.height / 2)
            let outer = CGPoint(x: outerRadius * cos(angle) + rect.size.width / 2, y: outerRadius * sin(angle) + rect.size.height / 2)
            progressBackgroundPath.move(to: inner)
            progressBackgroundPath.addLine(to: outer)
        }
        progressBackgroundPath.stroke()
        
        progressBackgroundColor.withAlphaComponent(0.5).set()
        let progressBackgroundPath2 = UIBezierPath()
        progressBackgroundPath2.lineWidth = 1
        progressBackgroundPath2.lineCapStyle = .round
        progressBackgroundPath2.lineJoinStyle = .round
        
        let innerRadius2: CGFloat = (min(rect.size.width, rect.size.height) - progressWidth) / 2 * 0.75
        let outerRadius2: CGFloat = (min(rect.size.width, rect.size.height) - progressWidth) / 2 * 0.8
        let numTicks2 = 96

        for i in 0..<numTicks2 {
            let angle = CGFloat(i) * 2 * CGFloat.pi / CGFloat(numTicks)
            let inner = CGPoint(x: innerRadius2 * cos(angle) + rect.size.width / 2, y: innerRadius2 * sin(angle) + rect.size.height / 2)
            let outer = CGPoint(x: outerRadius2 * cos(angle) + rect.size.width / 2, y: outerRadius2 * sin(angle) + rect.size.height / 2)
            progressBackgroundPath2.move(to: inner)
            progressBackgroundPath2.addLine(to: outer)
        }
        progressBackgroundPath2.stroke()
        
        
        progressColor.set()
        let progressPath = UIBezierPath()
        progressPath.lineWidth = 1
        progressPath.lineCapStyle = .round
        progressPath.lineJoinStyle = .round
        
        let innerRadius3: CGFloat = (min(rect.size.width, rect.size.height) - progressWidth) / 2 * 0.85
        let outerRadius3: CGFloat = (min(rect.size.width, rect.size.height) - progressWidth) / 2 * 0.95
        let numTicks3 = 96

        for i in 0..<Int(CGFloat(numTicks3) * progress) {
            let angle = CGFloat(i) * 2 * CGFloat.pi / CGFloat(numTicks)
            let inner = CGPoint(x: innerRadius3 * cos(angle - 0.5 * CGFloat.pi) + rect.size.width / 2, y: innerRadius3 * sin(angle - 0.5 * CGFloat.pi) + rect.size.height / 2)
            let outer = CGPoint(x: outerRadius3 * cos(angle - 0.5 * CGFloat.pi) + rect.size.width / 2, y: outerRadius3 * sin(angle - 0.5 * CGFloat.pi) + rect.size.height / 2)
            progressPath.move(to: inner)
            progressPath.addLine(to: outer)
        }
        progressPath.stroke()
        

    }

}
