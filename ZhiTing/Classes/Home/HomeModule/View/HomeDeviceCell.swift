//
//  HomeDeviceCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/1.
//

import UIKit

class HomeDeviceCell: UICollectionViewCell, ReusableView {
    /// 布局方式
    var layoutStyle: DeviceListStyle? {
        set {
            guard let newValue = newValue else { return }
            if _layoutStyle != newValue {
                switch newValue {
                case .flow:
                    setFlowConstrains()
                case .list:
                    setListConstraints()
                }
                _layoutStyle = newValue
            }

        }
        
        get {
            _layoutStyle
        }
    }
    /// 私有布局方式变量
    private var _layoutStyle: DeviceListStyle?

    /// 设备
    var device: Device? {
        didSet {
            guard let device = device else { return }
            icon.setImage(urlString: device.logo_url, placeHolder: .assets(.default_device))
            nameLabel.text = device.name
            
            statusLabel.text = ""
            statusLabel.textColor = .custom(.gray_94a5be)
            if device.device_status != nil || device.is_sa {
                offlineView.isHidden = true
                
                if let deviceStatus = device.device_status {
                    updateDeviceStatus(deviceStatus)
                } else {
                    switchButton.isHidden = true
                }
                
                switch _layoutStyle {
                case .flow:
                    statusLabel.textAlignment = .right
                    nameLabel.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(20)
                        $0.left.equalToSuperview().offset(15)
                        $0.right.equalToSuperview().offset(-15)
                    }
                case .list:
                    statusLabel.textAlignment = .left
                    if statusLabel.isHidden {
                        nameLabel.snp.remakeConstraints {
                            $0.centerY.equalToSuperview()
                            $0.left.equalTo(icon.snp.right).offset(15).priority(.high)
                            $0.right.lessThanOrEqualTo(switchButton.snp.left).offset(-15)
                        }
                    } else {
                        nameLabel.snp.remakeConstraints {
                            $0.top.equalTo(icon.snp.top).offset(4.5)
                            $0.left.equalTo(icon.snp.right).offset(15).priority(.high)
                            $0.right.lessThanOrEqualTo(switchButton.snp.left).offset(-15)
                        }
                    }
                   
                    
                case .none:
                    statusLabel.textAlignment = .right
                    nameLabel.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(20)
                        $0.left.equalToSuperview().offset(15)
                        $0.right.equalToSuperview().offset(-15)
                    }
                }
                
            } else {
                switch _layoutStyle {
                case .flow:
                    nameLabel.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(20)
                        $0.left.equalToSuperview().offset(15).priority(.high)
                        $0.width.lessThanOrEqualTo((Screen.screenWidth - 45) / 2 - 60)
                    }
                    offlineView.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(20)
                        $0.left.equalTo(nameLabel.snp.right).offset(ZTScaleValue(5))
                        $0.width.equalTo(ZTScaleValue(30))
                        $0.height.equalTo(ZTScaleValue(18))
                    }
                case .list:
                    nameLabel.snp.remakeConstraints {
                        $0.centerY.equalToSuperview()
                        $0.left.equalTo(icon.snp.right).offset(15)
                        $0.right.lessThanOrEqualTo(switchButton.snp.left).offset(-15)
                    }
                    offlineView.snp.remakeConstraints {
                        $0.centerY.equalTo(nameLabel.snp.centerY)
                        $0.left.equalTo(nameLabel.snp.right).offset(ZTScaleValue(5))
                        $0.width.equalTo(ZTScaleValue(30))
                        $0.height.equalTo(ZTScaleValue(18))
                    }
                    
                case .none:
                    nameLabel.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(20)
                        $0.left.equalToSuperview().offset(15).priority(.high)
                        $0.width.lessThanOrEqualTo((Screen.screenWidth - 45) / 2 - 60)
                    }
                    offlineView.snp.remakeConstraints {
                        $0.top.equalToSuperview().offset(20)
                        $0.left.equalTo(nameLabel.snp.right).offset(ZTScaleValue(5))
                        $0.width.equalTo(ZTScaleValue(30))
                        $0.height.equalTo(ZTScaleValue(18))
                    }
                }
                
                
                statusLabel.text = ""
                switchButton.isHidden = true
                offlineView.isHidden = false
                
                
                
            }
            
            
        }
    }
    
    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.default_device)
    }

    private lazy var nameLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .left
        $0.text = "Unknown"
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private lazy var offlineView = OfflineView().then {
        $0.isHidden = true
    }

    private lazy var switchButton = SwitchButton()
    
    private lazy var statusLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.textAlignment = .right
        $0.text = ""
        $0.lineBreakMode = .byTruncatingTail
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        clipsToBounds = true
        contentView.backgroundColor = .custom(.white_ffffff)
        layer.cornerRadius = 10
        contentView.addSubview(icon)
        contentView.addSubview(nameLabel)
        contentView.addSubview(switchButton)
        contentView.addSubview(offlineView)
        contentView.addSubview(statusLabel)
    }
    
    private func setFlowConstrains() {
        icon.snp.remakeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.top.equalTo(nameLabel.snp.bottom).offset(10)
            $0.width.height.equalTo(snp.height).multipliedBy(0.5)
        }
        
        nameLabel.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        switchButton.snp.remakeConstraints {
            $0.right.equalToSuperview().offset(-17.5)
            $0.bottom.equalToSuperview().offset(-17)
            $0.width.height.equalTo(snp.height).multipliedBy(0.25)
            
        }
        
        statusLabel.snp.remakeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalTo(icon.snp.bottom)
            $0.left.equalTo(icon.snp.right).offset(-4.5)
        }

    }
    
    private func setListConstraints() {
        icon.snp.remakeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(snp.height).multipliedBy(0.65)
        }
        
        nameLabel.snp.remakeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(icon.snp.right).offset(15)
            $0.right.lessThanOrEqualTo(switchButton.snp.left).offset(-15)
        }
        
        switchButton.snp.remakeConstraints {
            $0.right.equalToSuperview().offset(-17.5)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(snp.height).multipliedBy(0.6)
            
        }
        
        statusLabel.snp.remakeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.left.equalTo(nameLabel.snp.left)
            $0.right.equalTo(nameLabel.snp.right)
            
        }
    }
    
}

extension HomeDeviceCell {
    /// 根据设备状态更新视图
    /// - Parameter status: 设备状态
    private func updateDeviceStatus(_ status: DeviceStatusModel) {
        statusLabel.isHidden = true
        let instances = status.instances

        instances.forEach { instance in
            instance.services.forEach { service in
                service.instance_iid = instance.iid
            }
        }
        

        /// 网关不显示状态
        if instances.count > 1 || instances.first?.services.first(where: { $0.type == "gateway" }) != nil {
            switchButton.isHidden = true
            return
        }

        let services = instances.flatMap { $0.services }

        /// 显示开关的service
        let switchServices = services.filter({ $0.type == "outlet" || $0.type == "wireless_switch" || $0.type == "three_key_switch" || $0.type == "bulb" || $0.type == "light_bulb" || $0.type == "wall_plug" || $0.type == "switch" })
        if switchServices.count > 0 {
            if switchServices.filter({ $0.type == "switch" || $0.type == "three_key_switch" }).count > 1 {
                switchButton.isHidden = true
                var switchStatus = [String]()
                statusLabel.textColor = .custom(.gray_94a5be)
                let services = switchServices.filter({ $0.type == "switch" || $0.type == "three_key_switch" })
                services.forEach { service in
                    if let attr = service.attributes.first(where: { $0.type == "on_off" }) { // 开关状态
                        if let power = attr.val as? String {
                            switchStatus.append((power == "1" || power == "on") ? "开".localizedString : "关".localizedString)
                        } else if let power = attr.val as? Int {
                            switchStatus.append(power == 1 ? "开".localizedString : "关".localizedString)
                        }
                    }
                    
                }
                statusLabel.text = switchStatus.joined(separator: " | ")
                statusLabel.isHidden = false
                return
            } else if let service = switchServices.first {
                if let attr = service.attributes.first(where: { $0.type == "on_off" }) { // 开关状态
                    switchButton.isHidden = false
                    if let power = attr.val as? String {
                        switchButton.isOn = (power == "on" || power == "1")
                    } else if let power = attr.val as? Int {
                        switchButton.isOn = (power == 1)
                    }
                    // 开关权限
                    switchButton.isEnabled = ((attr.permission ?? 0) > 0)
                    switchButton.alpha = (attr.permission ?? 0) > 0 ? 1 : 0.8
                    switchButton.statusCallback = { [weak self] isOn in
                        guard let self = self, let device = self.device else { return }
                        AppDelegate.shared.appDependency.websocket
                            .executeOperation(operation: .controlDevicePower(
                                domain: device.plugin_id,
                                iid: service.instance_iid,
                                aid: attr.aid,
                                power: !isOn))

                    }
                    return
                }
            }
            
        } else { // 其他情况不显示
            switchButton.isHidden = true
        }
        
        

        /// 显示温湿度的service
        if services.filter({ $0.type == "temperature_sensor" || $0.type == "humidity_sensor"}).count > 0 {
            // 温湿度状态
            let t_h_services = services.filter({ $0.type == "temperature_sensor" || $0.type == "humidity_sensor"})
            var str = ""

            if let tempAttr = t_h_services
                .first(where: { $0.type == "temperature_sensor" })?
                .attributes
                .first(where: { $0.type == "temperature" }) {
                if let val = tempAttr.val as? Int {
                    str += "\(val)°C"
                } else if let val = tempAttr.val as? Double {
                    str += "\(String(format: "%.1f", val))°C"
                }
            }
            
            if let humidityAttr = t_h_services
                .first(where: { $0.type == "humidity_sensor" })?
                .attributes
                .first(where: { $0.type == "humidity" }) {
                if let val = humidityAttr.val as? Int,
                   let max = humidityAttr.max as? Int,
                   let min = humidityAttr.min as? Int {
                    let percent = (Float(val - min) / Float(max - min)) * 100
                    str += " | \(Int(percent))%"
                }
            }
            statusLabel.text = str
            statusLabel.isHidden = false
            return
        }


        /// 显示人体传感状态的service
        if let service = services.first(where: { $0.type == "motion_sensor" }) { // 人体传感状态
            if let tempAttr = service.attributes.first(where: { $0.type == "motion_detected" }) {
                if let val = tempAttr.val as? Bool {
                    statusLabel.textColor = (val ? .custom(.red_fe0000) : .custom(.gray_94a5be))
                    statusLabel.text = (val ? "有人移动".localizedString : "")
                    statusLabel.isHidden = false
                    return
                }
            }
            
        }
        
        /// 显示门窗传感状态instance
        if let service = services.first(where: { $0.type == "contact_sensor" }) { // 门窗传感状态
            if let tempAttr = service.attributes.first(where: { $0.type == "contact_sensor_state" }) {
                if let val = tempAttr.val as? Int {
                    statusLabel.text = (val == 1 ? "已打开".localizedString : "已关闭".localizedString)
                    statusLabel.isHidden = false
                    return
                }
            }
            
        }
        
        /// 显示水浸传感状态instance
        if let service = services.first(where: { $0.type == "leak_sensor" }) { // 水浸传感状态
            if let tempAttr = service.attributes.first(where: { $0.type == "leak_detected" }) {
                if let val = tempAttr.val as? Int {
                    statusLabel.textColor = (val == 1 ? .custom(.red_fe0000) : .custom(.gray_94a5be))
                    statusLabel.text = (val == 1 ? "检测水浸".localizedString : "检测无水".localizedString)
                    statusLabel.isHidden = false
                    return
                }
            }
            
        }
        

    }
    
    
}

extension HomeDeviceCell {
    class OfflineView: UIView {
        private lazy var titleLabel = Label().then {
            $0.text = "离线".localizedString
            $0.textColor = .custom(.gray_94a5be)
            if getCurrentLanguage() == .chinese {
                $0.font = .font(size: 12, type: .regular)
            } else {
                $0.font = .font(size: 8, type: .regular)
            }
            
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(titleLabel)
            layer.cornerRadius = ZTScaleValue(4)
            layer.borderColor = UIColor.custom(.gray_94a5be).cgColor
            layer.borderWidth = 0.5
            titleLabel.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }
}
