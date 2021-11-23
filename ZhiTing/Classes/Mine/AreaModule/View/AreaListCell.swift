//
//  AreaListCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/12.
//

import UIKit

class AreaListCell: UITableViewCell, ReusableView {
    
    lazy var title = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }

    private lazy var arrow = ImageView().then {
        $0.image = .assets(.arrow_right)
        $0.contentMode = .scaleAspectFit
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(title)
        contentView.addSubview(arrow)
        contentView.addSubview(line)
    }
    
    private func setupConstraints() {
        line.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        arrow.snp.makeConstraints {
            $0.width.equalTo(7.5)
            $0.height.equalTo(13.5)
            $0.top.equalToSuperview().offset(23)
            $0.right.equalToSuperview().offset(-15)
        }
        
        title.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(19)
            $0.left.equalToSuperview().offset(14.5)
            $0.right.equalTo(arrow.snp.left).offset(-5)
            $0.bottom.equalToSuperview().offset(-18)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
