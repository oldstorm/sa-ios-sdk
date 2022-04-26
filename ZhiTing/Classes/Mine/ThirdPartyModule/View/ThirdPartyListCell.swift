//
//  ThirdPartyListCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/10.
//


import UIKit

class ThirdPartyListCell: UITableViewCell, ReusableView {
    var item: ThirdPartyCloudModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            titleLabel.text = item.name
            authorizedIcon.isHidden = !item.is_bind
            icon.setImage(urlString: item.img, placeHolder: nil)
        }
    }

    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
    }

    private lazy var authorizedIcon = ImageView().then {
        $0.image = .assets(.icon_authorized)
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private lazy var arrow = ImageView().then {
        $0.image = .assets(.arrow_right)
        $0.contentMode = .scaleAspectFit
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
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorizedIcon)
        contentView.addSubview(arrow)
        contentView.addSubview(line)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(50)
            $0.top.equalToSuperview().offset(19)
            $0.right.equalToSuperview().offset(-90)
        }
        
        icon.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.left.equalToSuperview().offset(16)
            $0.height.width.equalTo(18)
        }
        
        arrow.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(12.5)
            $0.width.equalTo(7)
            $0.centerY.equalTo(titleLabel.snp.centerY)
        }
        
        authorizedIcon.snp.makeConstraints {
            $0.right.equalTo(arrow.snp.left).offset(-16)
            $0.height.equalTo(20)
            $0.width.equalTo(40)
            $0.centerY.equalTo(titleLabel.snp.centerY)
        }
        
        line.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.top.equalTo(titleLabel.snp.bottom).offset(19)
            $0.bottom.equalToSuperview()
        }

    }

}
