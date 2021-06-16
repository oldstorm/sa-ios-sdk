//
//  CaptchaButton.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/22.
//

import Foundation

class CaptchaButton: Button {
    var endCountingCallback: (() -> ())?
    lazy var counting = false
    private var timer: Timer?
    
    private lazy var btnLabel = Label().then {
        $0.textColor = .custom(.blue_2da3f6)
        $0.font = .font(size: 14, type: .regular)
        $0.textAlignment = .right
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        btnLabel.text = "获取验证码".localizedString
        addSubview(btnLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setIsEnable(_ bool: Bool) {
        if bool && !counting {
            self.isEnabled = true
            btnLabel.textColor = .custom(.blue_2da3f6)
        } else {
            self.isEnabled = false
            btnLabel.textColor = .custom(.gray_94a5be)
        }
        
        
    }
    
    override func layoutSubviews() {
        btnLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview()
        }
    }
    
    func beginCountDown() {
        var count = 120
        timer?.invalidate()
        setIsEnable(false)
        counting = true
        
        timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] _ in
            count -= 1
            let text = getCurrentLanguage() == .chinese ? "已发送(\(count)s)" : "Send(\(count)s)"
            self?.btnLabel.text = text
            
            if count == 0 {
                self?.timer?.invalidate()
                self?.counting = false
                self?.btnLabel.text = "获取验证码".localizedString
                self?.setIsEnable(true)
                self?.endCountingCallback?()
            }
        })
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }

}
