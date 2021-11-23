//
//  AuthItemCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/1.
//

import UIKit

class AuthItemCell: UITableViewCell, ReusableView {
    var authItem: AuthItemModel? {
        didSet {
            guard let item = authItem else { return }
            label.text = item.description
        }
    }
    
    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.selected_tick)
        $0.alpha = 0.5
    }
    
    private lazy var label = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .regular)
        $0.textColor = .custom(.black_333333)
        $0.text = " "
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(icon)
        contentView.addSubview(label)
        
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().priority(.high)
            $0.height.width.equalTo(ZTScaleValue(16)).priority(.high)
            $0.bottom.equalToSuperview().offset(-10)
        }

        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(icon.snp.right).offset(10.5)
            $0.right.equalToSuperview().priority(.high)
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
