//
//  HomeHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit


class HomeHeader: UIView {
    enum BtnTypes {
        case scan
        case add
        case history
    }

    var switchAreaCallButtonCallback: (() -> ())?
    
    
    lazy var titleLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(24.0), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "选择家庭"
        $0.lineBreakMode = .byTruncatingTail
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }

    lazy var arrow = ImageView().then {
        $0.image = .assets(.arrow_right)
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }
    
    lazy var rightView = UIView().then {
        $0.isUserInteractionEnabled = true
    }

    lazy var plusBtn = Button().then {
        $0.setImage(.assets(.plus_circle), for: .normal)
    }
    
    lazy var scanBtn = Button().then {
        $0.setImage(.assets(.icon_scan), for: .normal)
    }
    
    lazy var historyBtn = Button().then {
        $0.setImage(.assets(.history_button), for: .normal)
        
    }
    


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .custom(.white_ffffff)
        addSubview(titleLabel)
        addSubview(arrow)
        addSubview(rightView)

    }
    
    private func setConstrains() {
        titleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-5)
            $0.left.equalToSuperview().offset(15).priority(.high)
            $0.right.lessThanOrEqualTo(rightView.snp.left).offset(-44)
        }
        
        arrow.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY).offset(2)
            $0.height.equalTo(13.5)
            $0.width.equalTo(8)
            $0.left.equalTo(titleLabel.snp.right).offset(14)
        }
        
        rightView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-19.5).priority(.high)
            $0.bottom.equalToSuperview().offset(-10)
            $0.height.equalTo(24)
            $0.width.equalTo(0)
        }

    }
    
    @objc private func tap() {
        switchAreaCallButtonCallback?()
    }
    
    
    func setBtns(btns: [BtnTypes]) {
        rightView.subviews.forEach { $0.removeFromSuperview() }
        var marginX: CGFloat = 0

        btns.forEach { btnType in
            switch btnType {
            case .add:
                rightView.addSubview(plusBtn)
                plusBtn.snp.remakeConstraints {
                    $0.bottom.equalToSuperview()
                    $0.right.equalToSuperview().offset(-marginX)
                    $0.width.height.equalTo(24)
                    $0.top.equalToSuperview()
                }
            case .history:
                rightView.addSubview(historyBtn)
                historyBtn.snp.remakeConstraints {
                    $0.bottom.equalToSuperview()
                    $0.right.equalToSuperview().offset(-marginX)
                    $0.width.height.equalTo(24)
                    $0.top.equalToSuperview()
                }
            case .scan:
                rightView.addSubview(scanBtn)
                scanBtn.snp.remakeConstraints {
                    $0.bottom.equalToSuperview()
                    $0.right.equalToSuperview().offset(-marginX)
                    $0.width.height.equalTo(24)
                    $0.top.equalToSuperview()
                }
            }
            marginX += 49
            
        }
        
        rightView.snp.updateConstraints {
            $0.width.equalTo(marginX)
        }
    }


}
