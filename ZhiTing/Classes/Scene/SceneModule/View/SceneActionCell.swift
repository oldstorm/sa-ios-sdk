//
//  SceneTaskCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/13.
//

import Foundation

class SceneTaskCell: UITableViewCell, ReusableView {
    enum ActionType {
        case scene
        case device
    }

    var action: String? {
        didSet {
            titleLabel.text = action
            detailLabel.text = "台灯"
            descriptionLabel.text = "房间"
        }
    }

    
    var actionType: ActionType = .device {
        didSet {
            switch actionType {
            case .device:
                descriptionLabel.isHidden = false
                detailLabel.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(ZTScaleValue(19.5))
                    $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                    $0.left.lessThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
                }
                
                descriptionLabel.snp.remakeConstraints {
                    $0.top.equalTo(detailLabel.snp.bottom)
                    $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                    $0.left.lessThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
                }
            case .scene:
                descriptionLabel.isHidden = true
                detailLabel.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(ZTScaleValue(27.5))
                    $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                    $0.left.lessThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
                }
            }
        }
    }


    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    private lazy var titleLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
    }
    
    private lazy var detailLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .right
    }
    
    private lazy var descriptionLabel = Label().then {
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(11), type: .regular)
        $0.textAlignment = .right
    }

    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_smart_device)
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
        clipsToBounds = true
        selectionStyle = .none
        contentView.addSubview(line)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(icon)
        
    }
    
    private func setupConstraints() {
        
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
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(19.5))
            $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
            $0.left.lessThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom)
            $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
            $0.left.lessThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
        }

        
    }

}
