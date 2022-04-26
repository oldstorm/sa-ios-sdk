//
//  DepartmentSelectManagerAlert.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/16.
//


import UIKit

// MARK: - DepartmentSelectManagerAlert
class DepartmentSelectManagerAlert: UIView {
    var selectCallback: ((_ user: User?) -> ())?

    var users = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectedUser: User?

    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var label = Label().then {
        $0.text = "部门主管".localizedString
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 16, type: .bold)
    }
    
    private lazy var closeButton = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.isEnhanceClick = true
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private lazy var sureBtn = Button().then {
        $0.setTitle("确定".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.register(DepartmentSelectManagerAlertCell.self, forCellReuseIdentifier: DepartmentSelectManagerAlertCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    }
    
    private func setupViews() {
        sureBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.selectCallback?(self.selectedUser)
            self.removeFromSuperview()
            
        }

        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(label)
        containerView.addSubview(closeButton)
        containerView.addSubview(line)
        containerView.addSubview(tableView)
        containerView.addSubview(sureBtn)
        
    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(10)
            $0.height.equalTo(410)
        }
        
        label.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16.5)
            $0.left.equalToSuperview().offset(18)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(label.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.height.width.equalTo(14)
        }
        
        line.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.left.right.equalToSuperview()
            $0.top.equalTo(label.snp.bottom).offset(17)
        }
        
        sureBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(sureBtn.snp.top).offset(-10)
        }
    }

    @objc private func close() {
        removeFromSuperview()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
        
        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
        
        
    }
}

extension DepartmentSelectManagerAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DepartmentSelectManagerAlertCell.reusableIdentifier, for: indexPath) as! DepartmentSelectManagerAlertCell
        let user = users[indexPath.row]
        cell.titleLabel.text = user.nickname
        cell.detailLabel.text = user.role_infos.map(\.name).joined(separator: "、")
        
        if selectedUser?.user_id == user.user_id {
            cell.tickIcon.image = .assets(.selected_tick)
        } else {
            cell.tickIcon.image = .assets(.unselected_tick)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedUser?.user_id == users[indexPath.row].user_id {
            selectedUser = nil
        } else {
            selectedUser = users[indexPath.row]
        }
        
        tableView.reloadData()
        
    }
    
}



// MARK: - SwtichAreaViewCell
extension DepartmentSelectManagerAlert {
    class DepartmentSelectManagerAlertCell: UITableViewCell, ReusableView {
        lazy var line = UIView().then { $0.backgroundColor = .custom(.gray_eeeeee) }
        
        lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
            $0.image = .assets(.default_avatar)
        }
        
        lazy var titleLabel = Label().then {
            $0.font = .font(size: 14, type: .medium)
            $0.textColor = .custom(.black_3f4663)
            $0.text = "nickname"
        }
        
        lazy var detailLabel = Label().then {
            $0.font = .font(size: 12, type: .regular)
            $0.textColor = .custom(.gray_94a5be)
            $0.text = "role"
        }

        lazy var tickIcon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.unselected_tick)
            
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            contentView.backgroundColor = .custom(.white_ffffff)
            contentView.addSubview(icon)
            contentView.addSubview(titleLabel)
            contentView.addSubview(detailLabel)
            contentView.addSubview(tickIcon)
            contentView.addSubview(line)
            
            icon.snp.makeConstraints {
                $0.top.equalToSuperview().offset(10)
                $0.left.equalToSuperview().offset(17)
                $0.height.width.equalTo(40)
            }
            
            tickIcon.snp.makeConstraints {
                $0.centerY.equalTo(icon.snp.centerY)
                $0.right.equalToSuperview().offset(-15)
                $0.height.width.equalTo(18)
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(12)
                $0.left.equalTo(icon.snp.right).offset(12.5)
                $0.right.equalTo(tickIcon.snp.left).offset(-4.5)
            }
            
            detailLabel.snp.makeConstraints {
                $0.bottom.equalTo(line.snp.top).offset(-12)
                $0.left.equalTo(icon.snp.right).offset(12.5)
                $0.right.equalTo(tickIcon.snp.left).offset(-4.5)
            }
            
            line.snp.makeConstraints {
                $0.top.equalTo(icon.snp.bottom).offset(10.5)
                $0.right.equalToSuperview()
                $0.left.equalToSuperview().offset(44)
                $0.height.equalTo(0.5)
                $0.bottom.equalToSuperview()
            }

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
