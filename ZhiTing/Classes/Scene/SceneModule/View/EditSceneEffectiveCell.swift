//
//  EditSceneEffectiveCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/13.
//

import UIKit


class EditSceneEffectiveCell: UITableViewCell, ReusableView {
    private lazy var titleLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.text = "生效时间段".localizedString
    }
    
    lazy var detailLabel = Label().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(11), type: .regular)
        $0.textAlignment = .right
        $0.text = "每天".localizedString
    }
    
    lazy var valueLabel = Label().then {
        $0.textColor = .custom(.gray_94a5be)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .right
        $0.text = "全天".localizedString
    }
    
    private lazy var arrow = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.right_arrow_gray)
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
        selectionStyle = .none
        backgroundColor = .custom(.white_ffffff)
        layer.cornerRadius = ZTScaleValue(10)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(arrow)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(14))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(3.5))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
        }
        
        arrow.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(23.5))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.width.equalTo(ZTScaleValue(7.5))
            $0.height.equalTo(ZTScaleValue(13.5))
        }
        
        valueLabel.snp.makeConstraints {
            $0.centerY.equalTo(arrow.snp.centerY)
            $0.right.equalTo(arrow.snp.left).offset(ZTScaleValue(-14))
            $0.bottom.equalToSuperview().offset(ZTScaleValue(-23.5))
        }
        
        

    }
}
