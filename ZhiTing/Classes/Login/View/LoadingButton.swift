//
//  LoadingButton.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/22.
//

import Foundation
import UIKit

class LoadingButton: Button {
    enum ButtonState {
        case normal
        case waiting
    }
    
    var titleColor: UIColor? = .custom(.white_ffffff)
    
    var buttonState: ButtonState = .normal {
        didSet {
            switch buttonState {
            case .normal:
                waitingView.stopRotating()
                setTitleColor(titleColor, for: .normal)
                waitingView.isHidden = true
            case .waiting:
                setTitleColor(.clear, for: .normal)
                waitingView.isHidden = false
                waitingView.startRotating()
            }
        }
    }
    

    private lazy var waitingView = CircularProgress(frame: CGRect(x: 0, y: 0, width: 30, height: 30)).then { $0.isHidden = true }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(.custom(.white_ffffff), for: .normal)
        titleLabel?.font = .font(size: 14, type: .bold)
        titleLabel?.textAlignment = .center
        backgroundColor = .custom(.blue_2da3f6)
        layer.cornerRadius = 4
        addSubview(waitingView)
    }
    
    func setIsEnable(_ bool: Bool) {
        self.isEnabled = bool
        backgroundColor = bool ? .custom(.blue_2da3f6) : .custom(.gray_dddddd)
    }
    
    convenience init(frame: CGRect = .zero, title: String) {
        self.init(frame: frame)
        setTitle(title, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        titleLabel?.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        waitingView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(30)
        }
    }
}
