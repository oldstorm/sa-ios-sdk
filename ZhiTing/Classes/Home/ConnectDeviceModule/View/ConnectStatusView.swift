//
//  ConnectStatusView.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/2.
//

import UIKit

class ConnectStatusView: UIView {
    enum Status {
        case fail(type: FailType)
        case success
        case connecting
        
        
        enum FailType {
            case normalDevice(msg: String)
            case sa
        }
    }
    

    var status: Status? {
        didSet {
            guard let status = status else { return }
            icon.isHidden = true
            timer?.invalidate()
            switch status {
            case .fail(let failType):
                switch failType {
                case .normalDevice(let msg):
                    statusLabel.text = msg
                    errorDetailLabel.text = "请检查并确保:\n1、设备正常供电;\n2、设备与智慧中心处于同一局域网;\n3、设备未被其他中心枢纽连接;\n"
                    
                case .sa:
                    statusLabel.text = "设备连接失败!".localizedString
                    errorDetailLabel.text = "请检查并确保:\n1、设备正常供电;\n2、设备网络连接正常\n"
                    
                }
                
               
                statusLabel.textColor = .custom(.red_fe0000)
            case .connecting:
                errorDetailLabel.text = ""
                statusLabel.textColor = .custom(.gray_94a5be)
                startConnecting()
            case .success:
                errorDetailLabel.text = ""
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
    
    private lazy var errorDetailLabel = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
        $0.textAlignment = .left
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
        addSubview(errorDetailLabel)
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
        
        errorDetailLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.left.equalToSuperview().offset(16)
            $0.top.equalTo(statusLabel.snp.bottom).offset(25)
            $0.bottom.equalToSuperview().offset(-25)
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
