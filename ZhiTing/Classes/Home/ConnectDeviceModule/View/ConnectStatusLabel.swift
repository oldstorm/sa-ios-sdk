//
//  ConnectStatusLabel.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/2.
//

import UIKit

class ConnectStatusLabel: UIView {
    enum Status {
        case fail
        case success
        case connecting
    }
    
    var reconnectCallback: (() -> ())?

    var status: Status? {
        didSet {
            guard let status = status else { return }
            reconnectBtn.isHidden = true
            icon.isHidden = true
            timer?.invalidate()
            switch status {
            case.fail:
                statusLabel.text = "连接失败!".localizedString
                statusLabel.textColor = .custom(.red_fe0000)
                reconnectBtn.isHidden = false
            case .connecting:
                statusLabel.textColor = .custom(.gray_94a5be)
                startConnecting()
            case .success:
                statusLabel.text = "连接成功!".localizedString
                statusLabel.textColor = .custom(.black_3f4663)
                icon.isHidden = false
            }
        }
    }

    private var timer: Timer?

    private lazy var statusLabel = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textAlignment = .center
    }
    
    private lazy var icon = ImageView().then {
        $0.image = .assets(.tick_green)
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var reconnectBtn = Button().then {
        $0.setTitle("重新连接".localizedString, for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.layer.cornerRadius = 8
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.clickCallBack = { [weak self] _ in
            self?.reconnectCallback?()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(statusLabel)
        addSubview(icon)
        addSubview(reconnectBtn)
    }
    
    private func setConstrains() {
        statusLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        icon.snp.makeConstraints {
            $0.right.equalTo(statusLabel.snp.left).offset(-3)
            $0.centerY.equalTo(statusLabel.snp.centerY)
            $0.height.width.equalTo(20)
        }
        
        reconnectBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(statusLabel.snp.bottom).offset(43)
            $0.width.equalTo(150)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-5)
        }
    }
    
    private func startConnecting() {
        var count = 0
        timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            count += 1
            var str = "设备连接中".localizedString
            for _ in 0..<count % 4 {
                str += "."
            }
            self.statusLabel.text = str
        })
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
        

    }
}
