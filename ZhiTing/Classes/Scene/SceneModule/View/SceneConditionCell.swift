//
//  SceneConditionCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/13.
//

import UIKit

class SceneConditionCell: UITableViewCell, ReusableView {
    let hideDeletionNoti = NSNotification.Name.init("SwipeCellNoti")
    
    enum SceneConditionType {
        case normal
        case device
    }

    var deletionCallback: (() -> ())?
    var panGes: UIPanGestureRecognizer?
    var swipeLeftGes: UISwipeGestureRecognizer?
    var swipeRightGes: UISwipeGestureRecognizer?
    
    var isEnableSwipe = true {
        didSet {
            panGes?.isEnabled = isEnableSwipe
            swipeLeftGes?.isEnabled = isEnableSwipe
            swipeRightGes?.isEnabled = isEnableSwipe
        }
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
                titleLabel.text = condition.displayAction
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
                        $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(5))
                    }
                } else {
                    descriptionLabel.isHidden = false
                    detailLabel.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(ZTScaleValue(19.5))
                        $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                        $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(5))
                    }
                    
                    descriptionLabel.snp.remakeConstraints {
                        $0.top.equalTo(detailLabel.snp.bottom)
                        $0.right.equalTo(icon.snp.left).offset(ZTScaleValue(-15.5))
                        $0.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(ZTScaleValue(5))
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

    lazy var containerView = UIView().then {
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
        $0.image = .assets(.icon_condition_manual)
        $0.layer.borderWidth = 0.5
        $0.layer.cornerRadius = 4
        
    }

    private lazy var delayView = DelayView().then {
        $0.isHidden = true
    }
    
    lazy var deleteView = UIView().then {
        $0.backgroundColor = .systemRed
        let label = UILabel()
        label.text = "删除"
        label.textColor = .custom(.white_ffffff)
        label.font = .font(size: 14, type: .regular)
        $0.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDelete)))
        $0.isUserInteractionEnabled = true
    }
    
    deinit {
        if self.observationInfo != nil {
            NotificationCenter.default.removeObserver(self)
        }
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        
        panGes = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        swipeLeftGes = UISwipeGestureRecognizer(target: self, action: #selector(popDeletion))
        swipeLeftGes?.direction = .left
        swipeRightGes = UISwipeGestureRecognizer(target: self, action: #selector(hideDeletion))
        swipeRightGes?.direction = .right
        self.addGestureRecognizer(swipeLeftGes!)
        self.addGestureRecognizer(swipeRightGes!)
        self.addGestureRecognizer(panGes!)
        panGes!.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideDeletion), name: hideDeletionNoti, object: nil)
    }
    
    func setRoundedDel(_ isRounded: Bool) {
        let roundedSize = CGSize(width: isRounded ? ZTScaleValue(5) : 0, height: isRounded ? ZTScaleValue(5) : 0)

        let path = UIBezierPath.init(roundedRect: CGRect(x: 0, y: 0, width: 60, height: ZTScaleValue(70)), byRoundingCorners: .bottomRight, cornerRadii: roundedSize).cgPath
        let layer = CAShapeLayer()
        layer.path = path
        layer.fillColor = UIColor.custom(.red_fe0000).cgColor
        deleteView.layer.mask = layer
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
        containerView.addSubview(detailLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(icon)
        containerView.addSubview(delayView)
        contentView.addSubview(deleteView)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
            $0.right.lessThanOrEqualTo(icon.snp.left).offset(ZTScaleValue(-65))
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
        
        deleteView.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.top.bottom.equalToSuperview()
            $0.left.equalTo(snp.right)
        }

    }
    
    @objc private func onDelete() {
        deletionCallback?()
    }

}





extension SceneConditionCell {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let resFrame = CGRect(x: 0, y: 0, width: self.frame.width + 60, height: self.frame.height)
        if resFrame.contains(point) {
            if point.x  > self.frame.width {
                return deleteView
            }
            return self
        }
        
        return nil
    }
}


extension SceneConditionCell {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let ges = gestureRecognizer as? UIPanGestureRecognizer {
            if fabsf(Float(ges.velocity(in: self).y)) > 60 {
                return false
            }
            return true
        }
        return false
    }
    
    @objc private func popDeletion() {
        NotificationCenter.default.post(name: hideDeletionNoti, object: nil)
        UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseInOut) {
            self.frame.origin.x = -60
        }
    }
    
    @objc private func hideDeletion() {
        UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseInOut) {
            self.frame.origin.x = 0
        }
    }
    

    
    @objc private func onPan(_ sender: UIPanGestureRecognizer) {
        let state = sender.state
        let point = sender.translation(in: contentView)
        
        /// y变动过大时不判定为滑动cell
        if point.y < -60.0 || point.y > 60.0 {
            return
        }
        
        switch state {
            case .ended:
                if point.x < -30 && self.frame.origin.x >= 0 {
                    popDeletion()
                }
                
                if point.x > 30 && self.frame.origin.x < 0 {
                    hideDeletion()
                }
            default:
                break
            
        }

    }
}
