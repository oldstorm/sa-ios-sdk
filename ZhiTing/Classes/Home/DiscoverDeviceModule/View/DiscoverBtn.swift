//
//  DiscoverBtn.swift
//  ZhiTing
//
//  Created by iMac on 2021/7/12.
//

import UIKit

class DiscoverScanButton: UIButton {
    enum State {
        case searching
        case normal
    }
    
    var callback: (() -> ())?
    
    var timer: Timer?

    var status: State? {
        didSet {
            guard let state = status else { return }
            if state == .searching {
                btnLabel.text = "正在扫描".localizedString + "..."
                btnLabel.textColor = .custom(.gray_94a5be)
                isUserInteractionEnabled = false
                startAnimation()
            } else {
                btnLabel.text = "重新扫描".localizedString
                btnLabel.textColor = .custom(.blue_2da3f6)
                isUserInteractionEnabled = true
                stopAnimation()
            }
            

        }
    }

    private lazy var rotateImage = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.discoverBG3)
    }
    
    private lazy var btnLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.text = "正在扫描".localizedString + "..."
        $0.textAlignment = .center
        $0.textColor = .custom(.gray_94a5be)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        addTarget(self, action: #selector(tap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        backgroundColor = .custom(.white_ffffff)
        addSubview(btnLabel)
        addSubview(rotateImage)
    }
    
    private func setupConstraints() {
        rotateImage.snp.makeConstraints {
            $0.width.height.equalTo(ZTScaleValue(18))
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview()
        }
        
        btnLabel.snp.makeConstraints {
            $0.centerY.equalTo(rotateImage.snp.centerY)
            $0.left.equalTo(rotateImage.snp.right).offset(8)
            $0.right.equalToSuperview()
        }

    }


    private func startAnimation() {
        stopAnimation()
        var count: CGFloat = 0
        timer = Timer(timeInterval: 0.01, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            count += 0.03
            self.rotateImage.transform = CGAffineTransform.init(rotationAngle: CGFloat(count))
        })

        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        rotateImage.transform = .identity
    }
    
    @objc
    private func tap() {
        if status == .normal {
            callback?()
            status = .searching
        }
    }

}
