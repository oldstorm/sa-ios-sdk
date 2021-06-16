//
//  SceneConditionCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/13.
//

import UIKit

class SceneConditionCell: UITableViewCell, ReusableView {
    enum SceneConditionType {
        case normal
        case device
    }

    
    var condition: SceneCondition? {
        didSet {
            guard let condition = condition else { return }
            sceneConditionType = (condition.condition_type == 2) ? .device : .normal
            icon.layer.borderColor = UIColor.white.cgColor
            switch condition.condition_type {
            case 0: // 手动执行
                titleLabel.text = "手动点击执行".localizedString
                icon.image = .assets(.icon_condition_manual)
            case 1: // 定时
                icon.image = .assets(.icon_condition_timer)
                let format = DateFormatter()
                format.dateStyle = .medium
                format.timeStyle = .medium
                format.dateFormat = "HH:mm:ss"
                if let timing = condition.timing {
                    titleLabel.text = format.string(from: Date(timeIntervalSince1970: TimeInterval(timing)))
                }
                
            case 2: // 状态变化时
                titleLabel.text = condition.condition_item?.displayAction
                icon.setImage(urlString: condition.device_info?.logo_url ?? "", placeHolder: .assets(.default_device))
                icon.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
                detailLabel.text = condition.device_info?.name
                descriptionLabel.text = condition.device_info?.location_name
                descriptionLabel.textColor = .custom(.gray_94a5be)
                
                if condition.device_info?.status == 2 {
                    descriptionLabel.text = "设备已被删除".localizedString
                    descriptionLabel.textColor = .custom(.oringe_f6ae1e)
                }
                
                if descriptionLabel.text == " " || descriptionLabel.text == "" {
                    descriptionLabel.isHidden = true
                    detailLabel.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(ZTScaleValue(27.5))
                        $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                        $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(30))
                    }
                } else {
                    descriptionLabel.isHidden = false
                    detailLabel.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(ZTScaleValue(19.5))
                        $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                        $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(30))
                    }
                    
                    descriptionLabel.snp.remakeConstraints {
                        $0.top.equalTo(detailLabel.snp.bottom)
                        $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                        $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
                    }
                }

            default:
                break
            }
        }
    }

    var sceneConditionType: SceneConditionType = .device {
        didSet {
            switch sceneConditionType {
            case .device:
                descriptionLabel.isHidden = false
                detailLabel.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(ZTScaleValue(19.5))
                    $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                    $0.left.lessThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(30))
                }
                
                descriptionLabel.snp.remakeConstraints {
                    $0.top.equalTo(detailLabel.snp.bottom)
                    $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                    $0.left.lessThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
                }
            case .normal:
                descriptionLabel.isHidden = true
                detailLabel.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(ZTScaleValue(27.5))
                    $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                    $0.left.lessThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(30))
                }
            }
        }
    }

    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    private lazy var titleLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private lazy var detailLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .right
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private lazy var descriptionLabel = Label().then {
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(11), type: .regular)
        $0.textAlignment = .right
        $0.lineBreakMode = .byTruncatingTail
    }


    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_condition_manual)
        $0.layer.borderWidth = 0.5
        $0.layer.cornerRadius = 4
        
    }

    private lazy var delayView = DelayView().then {
        $0.isHidden = true
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
        selectionStyle = .none
        clipsToBounds = true
        contentView.addSubview(line)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(icon)
        contentView.addSubview(delayView)
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
            $0.right.lessThanOrEqualTo(icon.snp.left).offset(ZTScaleValue(-15))
        }
        
        delayView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(ZTScaleValue(10))
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(5))
            $0.right.lessThanOrEqualTo(icon.snp.left).offset(ZTScaleValue(-15))
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(5))
            $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom)
            $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
            $0.left.lessThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
        }

    }

}
