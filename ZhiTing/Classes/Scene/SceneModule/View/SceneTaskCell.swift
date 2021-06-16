//
//  SceneTaskCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/13.
//

import Foundation

class SceneTaskCell: UITableViewCell, ReusableView {
    enum TaskType {
        case scene
        case device
    }

    var task: SceneTask? {
        didSet {
            guard let task = task else { return }
            actionType = (task.type == 1) ? .device : .scene
            icon.layer.borderColor = UIColor.white.cgColor

            if let actions = task.scene_task_devices {
                let strs = actions.map(\.displayAction)
                titleLabel.text = strs.joined(separator: "、")
            }
            
            if task.delay_seconds ?? 0 > 0 {
                titleLabel.snp.remakeConstraints {
                    $0.left.equalToSuperview().offset(ZTScaleValue(15))
                    $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(15.5))
                    $0.right.lessThanOrEqualTo(icon.snp.left).offset(ZTScaleValue(-15))
                }
                delayView.isHidden = false
                var delay = task.delay_seconds ?? 0
                var str = ""
                if delay / 3600 > 0 {
                    str += "\(delay / 3600)时"
                }
                
                delay = delay % 3600
                if delay / 60 > 0 {
                    str += "\(delay / 60)分"
                }
                
                delay = delay % 60
                str += "\(delay)秒后"

                delayView.titleLabel.text = str
            } else {
                titleLabel.snp.remakeConstraints {
                    $0.left.equalToSuperview().offset(ZTScaleValue(15))
                    $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(27.5))
                    $0.right.lessThanOrEqualTo(icon.snp.left).offset(ZTScaleValue(-15))
                }
                delayView.isHidden = true
            }

            
            if task.type != 1 {
                icon.image = .assets(.icon_control_scene)
                if task.type == 2 {
                    titleLabel.text = "执行"
                } else if task.type == 3 {
                    titleLabel.text = "开启执行"
                } else if task.type == 4 {
                    titleLabel.text = "关闭执行"
                }
    
                detailLabel.text = task.control_scene_info?.name ?? " "
                
                if task.control_scene_info?.status == 2 {
                    descriptionLabel.text = "场景已被删除".localizedString
                    descriptionLabel.textColor = .custom(.oringe_f6ae1e)
                    descriptionLabel.isHidden = false
                    detailLabel.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(ZTScaleValue(19.5))
                        $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                        $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
                    }
                    
                    descriptionLabel.snp.remakeConstraints {
                        $0.top.equalTo(detailLabel.snp.bottom)
                        $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                        $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
                    }
                }

            } else {
                detailLabel.text = task.device_info?.name ?? " "
                descriptionLabel.text = task.device_info?.location_name ?? " "
                descriptionLabel.textColor = .custom(.gray_94a5be)
                icon.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
                
                if let urlStr = task.device_info?.logo_url {
                    icon.setImage(urlString: urlStr, placeHolder: .assets(.default_device))
                }
                
                if task.device_info?.status == 2 {
                    descriptionLabel.text = "设备已被删除".localizedString
                    descriptionLabel.textColor = .custom(.oringe_f6ae1e)
                }
                
                if descriptionLabel.text == " " || descriptionLabel.text == "" {
                    descriptionLabel.isHidden = true
                    detailLabel.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(ZTScaleValue(27.5))
                        $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                        $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(50))
                    }
                } else {
                    descriptionLabel.isHidden = false
                    detailLabel.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(ZTScaleValue(19.5))
                        $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                        $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(50))
                    }
                    
                    descriptionLabel.snp.remakeConstraints {
                        $0.top.equalTo(detailLabel.snp.bottom)
                        $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                        $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
                    }
                }
                
            }
            
        }
    }

    
    var actionType: TaskType = .device {
        didSet {
            switch actionType {
            case .device:
                descriptionLabel.isHidden = false
                detailLabel.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(ZTScaleValue(19.5))
                    $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                    $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(50))
                }

                descriptionLabel.snp.remakeConstraints {
                    $0.top.equalTo(detailLabel.snp.bottom)
                    $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                    $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(10))
                }
            case .scene:
                descriptionLabel.isHidden = true
                detailLabel.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(ZTScaleValue(27.5))
                    $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                    $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(50))
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
        $0.image = .assets(.icon_smart_device)
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
        clipsToBounds = true
        selectionStyle = .none
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



class DelayView: UIView {
    private lazy var icon = ImageView().then {
        $0.image = .assets(.icon_delay)
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var titleLabel = Label().then {
        $0.font = .font(size: 10, type: .medium)
        $0.textColor = .custom(.blue_2da3f6)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.custom(.blue_2da3f6).withAlphaComponent(0.1)
        addSubview(icon)
        addSubview(titleLabel)
        layer.cornerRadius = ZTScaleValue(8)
        
        icon.snp.makeConstraints {
            $0.left.equalToSuperview().offset(ZTScaleValue(8.5))
            $0.height.width.equalTo(ZTScaleValue(8))
            $0.top.equalToSuperview().offset(ZTScaleValue(3.5))
            $0.bottom.equalToSuperview().offset(ZTScaleValue(-4.5))
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.left.equalTo(icon.snp.right).offset(ZTScaleValue(3.5))
            $0.right.equalToSuperview().offset(ZTScaleValue(-9.5))
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

