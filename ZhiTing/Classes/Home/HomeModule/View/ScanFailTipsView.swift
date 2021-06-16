//
//  ScanFailTipsView.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/30.
//

import UIKit

class ScanFailTipsView: UIView {
    var callback: (() -> ())?

    private lazy var img = ImageView().then {
        $0.image = .assets(.icon_fail)
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var label = Label().then {
        $0.text = "扫描失败".localizedString
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .custom(.white_ffffff)
        layer.cornerRadius = 4
        addSubview(img)
        addSubview(label)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))

        img.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.width.height.equalTo(24)
            $0.centerX.equalToSuperview()
        }
        
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(img.snp.bottom).offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        transform = .init(scaleX: 0.3, y: 0.3)
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        } completion: { (finished) in
            if finished {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.removeFromSuperview()
                }
            }
        }

    }
    
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3) {
            self.transform = .init(scaleX: 0, y: 0)
        } completion: { (finished) in
            if finished {
                self.callback?()
                super.removeFromSuperview()
                
            }
        }
 
    }
    
    @objc private func tap() {
        removeFromSuperview()
    }
    
    static func show(to view: UIView, callback: (() -> Void)?) {
        let alert = ScanFailTipsView(frame: CGRect(x: 0, y: 0, width: 120, height: 70))
        alert.callback = callback
        alert.center = view.center
        view.addSubview(alert)
    }
}
