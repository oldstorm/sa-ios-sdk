//
//  HomeEmptyDeviceView.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit

class HomeEmptyDeviceView: UIView {
    var addCallback: (() -> ())?
    
    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }

    private lazy var emptyImage = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.empty_device)
    }

    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
        $0.textAlignment = .center
        $0.text = "你还没有设备".localizedString
    }
    
    lazy var addButton = Button().then {
        $0.setTitle("添加智能设备".localizedString, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.layer.cornerRadius = 4
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
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
        container.backgroundColor = UIColor.custom(.white_ffffff).withAlphaComponent(0.8)
        container.layer.cornerRadius = 10
        addSubview(container)
        container.addSubview(emptyImage)
        container.addSubview(titleLabel)
        container.addSubview(addButton)
        
        addButton.clickCallBack = { [weak self] _ in
            self?.addCallback?()
        }
    }
    
    private func setConstrains() {
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.equalTo(150)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(addButton.snp.top).offset(-36.5)
        }
        
        emptyImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(titleLabel.snp.top).offset(-11)
            $0.width.equalTo(40)
            $0.height.equalTo(31)
        }
    }
    
}
