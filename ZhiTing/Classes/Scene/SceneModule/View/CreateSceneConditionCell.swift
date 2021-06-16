//
//  SceneConditionActionCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/13.
//

import UIKit

class SceneConditionActionCell: UITableViewCell, ReusableView {
    var condition: String? {
        didSet {
            titleLabel.text = condition
        }
    }

    var isRoundedBottom = false {
        didSet {
            if isRoundedBottom {
                roundedBottom.isHidden = false
                roundedBottom.snp.updateConstraints {
                    $0.height.equalTo(10)
                }
                
                titleLabel.snp.updateConstraints {
                    $0.bottom.equalToSuperview().offset(-19.5)
                }
            } else {
                roundedBottom.isHidden = true
                roundedBottom.snp.updateConstraints {
                    $0.height.equalTo(0)
                }
                
                titleLabel.snp.updateConstraints {
                    $0.bottom.equalToSuperview().offset(-29.5)
                }
            }
        }
    }

    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }
    
    private lazy var titleLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
    }
    
    private lazy var descriptionLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .right
    }

    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_condition_manual)
    }

    private lazy var roundedBottom = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
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
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(line)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(icon)
        contentView.addSubview(roundedBottom)
        
        roundedBottom.frame.size = CGSize(width: Screen.screenWidth - ZTScaleValue(30), height: ZTScaleValue(10))
        roundedBottom.addRounded(corners: [.bottomLeft, .bottomRight], radii: CGSize(width: ZTScaleValue(5), height: ZTScaleValue(5)), borderWidth: 0, borderColor: .clear)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(roundedBottom.snp.top)
        }
        
        line.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(0.5))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.width.height.equalTo(ZTScaleValue(40))
        }

        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(27.5))
            $0.right.lessThanOrEqualTo(icon.snp.left).offset(ZTScaleValue(-200))
            $0.bottom.equalToSuperview().offset(-29.5)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(27.5))
            $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
            $0.left.lessThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
        }

        roundedBottom.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(10))
        }
        
    }

}
