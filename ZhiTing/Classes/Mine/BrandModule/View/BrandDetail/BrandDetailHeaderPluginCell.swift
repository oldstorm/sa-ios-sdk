//
//  BrandDetailHeaderCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/26.
//

import UIKit

class PluginCell: UITableViewCell, ReusableView {
    enum Status {
        case added
        case normal
        case needUpdate
        case updating
    }
    
    var status: Status = .normal {
        didSet {
            updateStatus(by: status)
        }
    }

    private lazy var nameLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = Colors.black_3f4663
        $0.text = "Unknown Plugin"
        $0.numberOfLines = 0
    }
    
    private lazy var versionLabel = Label().then {
        $0.font = .font(size: 12, type: .bold)
        $0.textColor = Colors.gray_94a5be
        $0.text = "Version: v1.0.0"
    }
    
    private lazy var descriptionLabel = Label().then {
        $0.font = .font(size: 12, type: .regular)
        $0.textColor = Colors.black_3f4663
        $0.numberOfLines = 0
        $0.text = "Plugin Description."
    }
    
    private lazy var addButton = Button().then {
        $0.setTitle("添加".localizedString, for: .normal)
        switch getCurrentLanguage() {
        case .chinese:
            $0.titleLabel?.font = .font(size: 14, type: .regular)
        case .english:
            $0.titleLabel?.font = .font(size: 10, type: .regular)
        }
        $0.setTitleColor(Colors.blue_2da3f6, for: .normal)
    }
    
    private lazy var updateButton = Button().then {
        $0.setTitle("更新".localizedString, for: .normal)
        switch getCurrentLanguage() {
        case .chinese:
            $0.titleLabel?.font = .font(size: 14, type: .regular)
        case .english:
            $0.titleLabel?.font = .font(size: 10, type: .regular)
        }
        $0.setTitleColor(Colors.blue_2da3f6, for: .normal)
    }
    
    private lazy var deleteButton = Button().then {
        $0.setTitle("删除".localizedString, for: .normal)
        switch getCurrentLanguage() {
        case .chinese:
            $0.titleLabel?.font = .font(size: 14, type: .regular)
        case .english:
            $0.titleLabel?.font = .font(size: 10, type: .regular)
        }
        $0.setTitleColor(Colors.blue_2da3f6, for: .normal)
    }

    private lazy var line = UIView().then {
        $0.backgroundColor = Colors.gray_eeeeee
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(versionLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(addButton)
        contentView.addSubview(updateButton)
        contentView.addSubview(deleteButton)
        contentView.addSubview(line)
    }
    
    private func setConstrains() {
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15.5)
            $0.left.equalToSuperview().offset(20.5)
            $0.right.equalToSuperview().offset(-100)
        }
        
        versionLabel.snp.makeConstraints {
            $0.left.equalTo(nameLabel.snp.left)
            $0.top.equalTo(nameLabel.snp.bottom)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(versionLabel.snp.bottom).offset(6)
            $0.left.equalTo(nameLabel.snp.left)
            $0.right.equalToSuperview().offset(-24.5)
        }
        
        line.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(15.5)
            $0.left.equalToSuperview().offset(20.5)
            $0.right.equalToSuperview().offset(-20.5)
            $0.bottom.equalToSuperview()
        }
    }

}

extension PluginCell {
    private func updateStatus(by status: Status) {
        addButton.isHidden = true
        updateButton.isHidden = true
        deleteButton.isHidden = true
        addButton.snp.removeConstraints()
        updateButton.snp.removeConstraints()
        deleteButton.snp.removeConstraints()
        
        switch status {
        case .normal:
            addButton.isHidden = false
            addButton.snp.makeConstraints {
                $0.top.equalToSuperview().offset(16.5)
                $0.right.equalToSuperview().offset(-21)
                $0.height.equalTo(15)
                $0.width.equalTo(30)
            }
        case .added:
            deleteButton.isHidden = false
            deleteButton.snp.makeConstraints {
                $0.top.equalToSuperview().offset(16.5)
                $0.right.equalToSuperview().offset(-21)
                $0.height.equalTo(15)
                $0.width.equalTo(30)
            }
        case .needUpdate:
            deleteButton.isHidden = false
            updateButton.isHidden = false
            updateButton.snp.makeConstraints {
                $0.top.equalToSuperview().offset(16.5)
                $0.right.equalToSuperview().offset(-21)
                $0.height.equalTo(15)
                $0.width.equalTo(35)
            }
            
            deleteButton.snp.makeConstraints {
                $0.top.equalToSuperview().offset(16.5)
                $0.right.equalTo(updateButton.snp.left).offset(-5)
                $0.height.equalTo(15)
                $0.width.equalTo(35)
            }
        case .updating:
            break

        }

    }

}
