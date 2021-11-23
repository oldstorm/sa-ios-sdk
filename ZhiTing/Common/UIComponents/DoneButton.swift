//
//  DoneButton.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/16.
//

import Foundation

class DoneButton: UIButton {
    /// if enhance the click scope
    lazy var isEnhanceClick = false
    /// enhance offset
    lazy var enhanceOffset: CGFloat = -20
    
    lazy var bgView = UIView().then {
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.layer.cornerRadius = bounds.height / 2
        $0.isUserInteractionEnabled = false
    }
    
    /// click callback
    var clickCallBack: ((Button) -> ())? {
        didSet {
            addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                bgView.backgroundColor = .custom(.blue_2da3f6)
            } else {
                bgView.backgroundColor = .custom(.gray_f6f8fd)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bgView)
        bringSubviewToFront(self.titleLabel!)
        setTitle("完成".localizedString, for: .normal)
        titleLabel?.font = .font(size: 14, type: .bold)
        setTitleColor(.white, for: .normal)
        setTitleColor(.custom(.gray_dddddd), for: .disabled)
        clipsToBounds = false
        bgView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(bounds.height)
            $0.width.equalTo(bounds.width)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func btnClick(_ btn: Button) {
        clickCallBack?(btn)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isEnhanceClick {
            let biggerFrame = self.bounds.inset(by: UIEdgeInsets.init(top: enhanceOffset, left: enhanceOffset, bottom: enhanceOffset, right: enhanceOffset))
            return biggerFrame.contains(point)
        } else {
            return super.point(inside: point, with: event)
        }
        
    }
    
    
    
}
