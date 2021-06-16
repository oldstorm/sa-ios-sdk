//
//  BrandDetailHeaderTopCell.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/26.
//

import UIKit

class BrandDetailHeaderTopCell: UITableViewCell, ReusableView {
    var installAllCallback: (() -> ())?
    var updateAllCallback: (() -> ())?
    var removeAllCallback: (() -> ())?

    var brand: Brand? {
        didSet {
            guard let brand = brand else { return }
            icon.setImage(urlString: brand.logo_url, placeHolder: .assets(.default_device))
            nameLabel.text = brand.name
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

    enum Status {
        case normal
        case needUpdate
        case added
        case updating
    }
    
    var status: Status = .added {
        didSet {
            updateStatus(by: status)
        }
    }

    private lazy var icon = ImageView().then {
        $0.layer.cornerRadius = 10
        $0.image = .assets(.default_device)
        
    }
    
    private lazy var nameLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.numberOfLines = 2
        $0.textColor = .custom(.black_3f4663)
        $0.text = "Unknown Brand Name"
    }
    
    private lazy var updatedLabel = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.text = "已添加".localizedString
        $0.textColor = .custom(.gray_94a5be)
        
    }
    
    private lazy var updateBtn = Button().then {
        $0.setTitle("全部更新".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.layer.cornerRadius = 4
        $0.titleLabel?.font = .font(size: 14, type: .regular)
        $0.isHidden = true
        $0.clickCallBack = { [weak self] _ in
            self?.updateAllCallback?()
        }
    }
    
    private lazy var installBtn = Button().then {
        $0.setTitle("全部安装".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.layer.cornerRadius = 4
        $0.titleLabel?.font = .font(size: 14, type: .regular)
        $0.isHidden = true
        $0.clickCallBack = { [weak self] _ in
            self?.installAllCallback?()
        }
    }
    
    lazy var progressView = CircularProgress(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
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
        selectionStyle = .none
        contentView.addSubview(icon)
        contentView.addSubview(nameLabel)
        contentView.addSubview(updatedLabel)
        contentView.addSubview(installBtn)
        contentView.addSubview(updateBtn)
        contentView.addSubview(progressView)
        contentView.addSubview(line)
    }
    
    private func setConstrains() {
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20).priority(.high)
            $0.left.equalToSuperview().offset(20).priority(.high)
            $0.width.height.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.left.equalTo(icon.snp.right).offset(11.5)
            $0.right.equalToSuperview().offset(-107.5)
        }
        
        updateBtn.snp.makeConstraints {
            $0.top.equalToSuperview().offset(21)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(30)
            $0.width.equalTo(70)
        }
        
        installBtn.snp.makeConstraints {
            $0.top.equalToSuperview().offset(21)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(30)
            $0.width.equalTo(70)
        }
        
        updatedLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(30)
        }
        
        progressView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-23)
            $0.top.equalToSuperview().offset(24)
            $0.width.height.equalTo(30)
        }
        
        line.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.left.right.equalToSuperview()
            $0.top.equalTo(icon.snp.bottom).offset(19.5)
            $0.bottom.equalToSuperview()
        }
    }
    
}

extension BrandDetailHeaderTopCell {
    private func updateStatus(by status: Status) {
        updateBtn.isHidden = true
        updatedLabel.isHidden = true
        installBtn.isHidden = true
        progressView.isHidden = true
        progressView.stopRotating()
        
        switch status {
        case .added:
            updatedLabel.isHidden = false
        case .needUpdate:
            updateBtn.isHidden = false
        case .normal:
            installBtn.isHidden = false
        case.updating:
            progressView.isHidden = false
            progressView.startRotating()
        }
        

    }

}
