//
//  BrandCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/25.
//

import UIKit

class BrandCell: UITableViewCell, ReusableView {
    enum Status {
        case added
        case needUpdate
        case updating
        case normal
    }

    var buttonCallback: (() -> ())?
    
    var brand: Brand? {
        didSet {
            guard let brand = brand else { return }
            icon.setImage(urlString: brand.logo_url, placeHolder: .assets(.default_device))
            brandNameLabel.text = brand.name
            
            
            if brand.is_added {
                if brand.is_newest {
                    status = .added
                } else {
                    status = .needUpdate
                }
            } else {
                status = .normal
            }
            
            if brand.is_updating {
                status = .updating
            }
            
            
        }
    }

    var status: Status = .normal {
        didSet {
            updateStatus(by: status)
        }
    }

    private lazy var icon = ImageView().then {
        $0.layer.cornerRadius = 10
        $0.contentMode = .scaleAspectFit
        
    }
    
    private lazy var brandNameLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "unknown"
    }
    
    
    private lazy var bottomLine = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    
    private lazy var updateButton = Button().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.setTitle("更新".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .medium)
        $0.layer.cornerRadius = 4
        $0.clickCallBack = { [weak self] _ in
            self?.buttonCallback?()
        }
    }
    
    private lazy var installButton = Button().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.setTitle("添加".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .medium)
        $0.layer.cornerRadius = 4
        $0.clickCallBack = { [weak self] _ in
            self?.buttonCallback?()
        }
    }
    
    private lazy var addedLabel = Label().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.gray_94a5be)
        $0.text = "已添加".localizedString
        $0.isHidden = true
    }
    
    lazy var progressView = CircularProgress(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        icon.image = nil
        addedLabel.isHidden = true
        updateButton.isHidden = true
        installButton.isHidden = true
        progressView.isHidden = true
    }
    
    private func setupViews() {
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(icon)
        contentView.addSubview(brandNameLabel)
        contentView.addSubview(bottomLine)
        contentView.addSubview(addedLabel)
        contentView.addSubview(updateButton)
        contentView.addSubview(installButton)
        contentView.addSubview(progressView)
    }
    
    private func setConstrains() {
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)
            $0.left.equalToSuperview().offset(15)
            $0.width.height.equalTo(40)
        }
        
        installButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.right.equalToSuperview().offset(-15)
            $0.width.equalTo(50)
            $0.height.equalTo(30)
        }
        
        updateButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.right.equalToSuperview().offset(-15)
            $0.width.equalTo(50)
            $0.height.equalTo(30)
        }
        
        addedLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.right.equalToSuperview().offset(-15)
        }
        
        progressView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-23)
            $0.top.equalToSuperview().offset(24)
            $0.width.height.equalTo(30)
        }

        brandNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.left.equalTo(icon.snp.right).offset(15.5)
            $0.right.equalToSuperview().offset(-70)
        }

        
        bottomLine.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(20.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(0.5)
            $0.bottom.equalToSuperview()
        }

    }
}


extension BrandCell {
    private func updateStatus(by status: Status) {
        addedLabel.isHidden = true
        updateButton.isHidden = true
        installButton.isHidden = true
        progressView.isHidden = true
        progressView.stopRotating()
        #warning("暂时先直接返回")
        return
        
        switch status {
        case .added:
            addedLabel.isHidden = false
        case .needUpdate:
            updateButton.isHidden = false
        case .normal:
            installButton.isHidden = false
        case .updating:
            progressView.isHidden = false
            progressView.startRotating()
        }

    }
    
}
