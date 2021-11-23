//
//  BrandCreationCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/5.
//

import UIKit
import AttributedString

class BrandCreationCell: UITableViewCell, ReusableView {
    var deleteCallback: (() -> ())?

    var plugin: Plugin? {
        didSet {
            guard let plugin = plugin else { return }
            detailLabel.text = plugin.info
            if plugin.build_status == -1 { //失败
                nameLabel.attributed.text = "\("\(plugin.name)", .font(.font(size: 14, type: .bold))) \(.image((.assets(.add_fail) ?? UIImage())))"
                deleteBtn.isHidden = false
                progressView.stopRotating()
                progressView.isHidden = true
                
            } else if plugin.build_status == 0 { //building
                nameLabel.attributed.text = "\("\(plugin.name)", .font(.font(size: 14, type: .bold)))"
                deleteBtn.isHidden = true
                progressView.isHidden = false
                progressView.startRotating()

            } else if plugin.build_status == 1 { //成功
                nameLabel.attributed.text = "\("\(plugin.name)", .font(.font(size: 14, type: .bold)))"
                deleteBtn.isHidden = false
                progressView.stopRotating()
                progressView.isHidden = true
                
            } else {
                nameLabel.attributed.text = "\("\(plugin.name)", .font(.font(size: 14, type: .bold)))"
                deleteBtn.isHidden = false
                progressView.stopRotating()
                progressView.isHidden = true
            }

        }
    }

    private lazy var nameLabel = Label().then {
        $0.textColor = .custom(.black_333333)
        $0.numberOfLines = 0
        $0.font = .font(size: 14, type: .bold)
    }
    
    private lazy var detailLabel = Label().then {
        $0.text = "该插件包括台灯的所有控制，如开关、色温等，添加插件后可控制yeelight台灯系列的所有的产品，支持的产品型号包括：A 123、B123、C123"
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
    }
    
    private lazy var deleteBtn = Button().then {
        $0.setTitle("删除".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .regular)
    }
    
    lazy var progressView = CircularProgress(frame: CGRect(x: 0, y: 0, width: 30, height: 30)).then {
        $0.isHidden = true
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
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(deleteBtn)
        contentView.addSubview(progressView)
        contentView.addSubview(line)
        
        deleteBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.deleteCallback?()
        }
    }
    
    private func setupConstraints() {
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-90)
        }
        
        deleteBtn.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.width.equalTo(35)
            $0.height.equalTo(16)
        }
        
        progressView.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.width.height.equalTo(30)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-22)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(14.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(0.5)
            $0.bottom.equalToSuperview()
        }
        
    }

}
