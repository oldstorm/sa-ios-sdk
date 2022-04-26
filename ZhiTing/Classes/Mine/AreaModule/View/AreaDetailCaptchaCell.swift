//
//  AreaDetailCaptchaCell.swift
//  ZhiTing
//
//  Created by macbook on 2021/10/14.
//

import UIKit

class AreaDetailCaptchaCell: UITableViewCell, ReusableView {
    
    var clickCallback: (() -> ())?

    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }

    lazy var title = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.text = " "
    }
    
    lazy var valueBtn = CustomButton(buttonType: .centerTitleAndLoading(normalModel:
                                        .init(
                                            title: "生成".localizedString,
                                            titleColor: .custom(.blue_2da3f6),
                                            font: .font(size: 14, type: .bold),
                                            backgroundColor: .custom(.blue_eaf6fe),
                                            borderColor: .custom(.blue_2da3f6)
                                        ))).then {
                                            $0.addTarget(self, action: #selector(valueBtnOnclick), for: .touchUpInside)
                                        }
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(line)
        contentView.addSubview(title)
        contentView.addSubview(valueBtn)
    }
    
    private func setupConstraints() {
        line.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(0.5)
        }

        title.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(19)
            $0.left.equalToSuperview().offset(14.5)
            $0.width.greaterThanOrEqualTo(120)
            $0.bottom.equalToSuperview().offset(-18)
        }
        
        valueBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-14.5)
            $0.width.greaterThanOrEqualTo(60)
            $0.height.equalTo(30)
        }

    }
    
    @objc private func valueBtnOnclick(sender: CustomButton){
        //请求生成验证码
        clickCallback?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
