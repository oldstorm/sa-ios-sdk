//
//  AuthAreaItemCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/1.
//

import UIKit

class AuthAreaItemCell: UITableViewCell, ReusableView {
    enum AuthState {
        case done
        case waiting
        case fail
    }

    var area: Area? {
        didSet {
            guard let area = area else { return }
            label.text = area.name
        }
    }
    
    var authState: AuthState = .waiting {
        didSet {
            switch authState {
            case .done:
                stateIcon.image = .assets(.icon_auth_done)
                retryBtn.isHidden = true
            case .waiting:
                stateIcon.image = .assets(.icon_auth_waiting)
                retryBtn.isHidden = true
            case .fail:
                stateIcon.image = .assets(.icon_auth_error)
                retryBtn.isHidden = false
            }
        }
    }

    
    private lazy var stateIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_auth_waiting)
    }

    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_family_brand)
    }
    
    private lazy var label = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .regular)
        $0.textColor = .custom(.black_333333)
        $0.text = " "
    }
    
    lazy var retryBtn = Button().then {
        $0.setTitle("重试".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_427aed), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .regular)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(stateIcon)
        contentView.addSubview(icon)
        contentView.addSubview(label)
        contentView.addSubview(retryBtn)
        
        stateIcon.snp.makeConstraints {
            $0.centerY.equalTo(label.snp.centerY)
            $0.left.equalToSuperview().priority(.high)
            $0.height.width.equalTo(ZTScaleValue(16)).priority(.high)
            
        }
        
        icon.snp.makeConstraints {
            $0.left.equalTo(stateIcon.snp.right).offset(12)
            $0.height.width.equalTo(ZTScaleValue(16)).priority(.high)
            $0.centerY.equalTo(stateIcon.snp.centerY)
        }

        label.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalTo(icon.snp.right).offset(10.5)
            $0.right.lessThanOrEqualToSuperview().offset(-40).priority(.high)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        retryBtn.snp.makeConstraints {
            $0.centerY.equalTo(label.snp.centerY)
            $0.left.equalTo(label.snp.right).offset(20)
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
