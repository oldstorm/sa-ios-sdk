//
//  NasAuthSelectAreaView.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/1.
//

import UIKit

class NasAuthAreaView: UIView {
    var clickCallback: (() -> ())?

    lazy var label = Label().then {
        $0.text = "请选择家庭".localizedString
        $0.textColor = .custom(.black_333333)
        $0.font = .font(size: 18, type: .bold)
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_dddddd)
    }

    private lazy var icon = ImageView().then {
        $0.image = .assets(.arrow_down_bold)
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(label)
        addSubview(icon)
        addSubview(line)
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))

    }
    
    private func setupConstraints() {
        label.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalTo(line.snp.top).offset(-8)
            $0.left.equalToSuperview()
            $0.right.equalTo(line.snp.right).offset(-20)
        }
        
        icon.snp.makeConstraints {
            $0.centerY.equalTo(label.snp.centerY)
            $0.right.equalTo(line.snp.right).offset(-5)
            $0.height.equalTo(4.5)
            $0.width.equalTo(7)
        }
        
        line.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }

    }

    @objc private func onTap() {
        clickCallback?()
    }
}
