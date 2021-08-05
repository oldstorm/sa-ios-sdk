//
//  MineInfoCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/23.
//

import UIKit


class MineInfoCell: UITableViewCell, ReusableView {
    enum InfoType {
        case avatar
        case nickName
        case phone
    }
    
    var infoType: InfoType? {
        didSet {
            guard let infoType = infoType else { return }
            switch infoType {
            case .avatar:
                avatar.isHidden = false
                valueLabel.isHidden = true
                titleLabel.text = "头像".localizedString
                arrow.isHidden = true
            case .nickName:
                avatar.isHidden = true
                valueLabel.isHidden = false
                titleLabel.text = "昵称".localizedString
                valueLabel.snp.remakeConstraints {
                    $0.centerY.equalToSuperview()
                    $0.right.equalTo(arrow.snp.left).offset(-10)
                }
            case .phone:
                avatar.isHidden = true
                valueLabel.isHidden = false
                arrow.isHidden = true
                titleLabel.text = "手机号".localizedString
                valueLabel.snp.remakeConstraints {
                    $0.centerY.equalToSuperview()
                    $0.right.equalTo(arrow.snp.left).offset(-10)
                }
            }

        }
    }

    lazy var titleLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = " "
        $0.textAlignment = .left
    }
    
    lazy var valueLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.gray_94a5be)
        $0.text = " "
        $0.textAlignment = .right
    }
    
    lazy var avatar = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.isHidden = true
        $0.image = .assets(.default_avatar)
        $0.layer.cornerRadius = 20
    }
    
    private lazy var arrow = ImageView().then {
        $0.image = .assets(.right_arrow_gray)
    }

    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(avatar)
        contentView.addSubview(line)
        contentView.addSubview(arrow)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(15.5)
        }
        
        valueLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-15.5)
        }
        
        arrow.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15.5)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(7)
            $0.height.equalTo(14)
        }
        
        avatar.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-15.5)
            $0.height.width.equalTo(40)
        }
        
        line.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
}
