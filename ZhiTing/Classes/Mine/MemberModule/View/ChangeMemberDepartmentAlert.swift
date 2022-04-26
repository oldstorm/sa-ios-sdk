//
//  ChangeMemberDepartmentAlert.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/17.
//



import UIKit

// MARK: - ChangeMemberDepartmentAlert
class ChangeMemberDepartmentAlert: UIView {
    var selectCallback: ((_ departments: [Location]) -> ())?

    var locations = [Location]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectedDepartments = [Location]()

    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var label = Label().then {
        $0.text = "选择部门".localizedString
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
        $0.register(ChangeMemberDepartmentAlertCell.self, forCellReuseIdentifier: ChangeMemberDepartmentAlertCell.reusableIdentifier)
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
            self.selectCallback?(self.selectedDepartments)
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
            $0.bottom.equalToSuperview().offset(10)
            $0.left.right.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(9)
            $0.top.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-15)
        }
        
        label.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16.5)
            $0.left.equalToSuperview().offset(20)
        }
        
        
        line.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.top.equalTo(label.snp.bottom).offset(12.5)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.height.equalTo(360)
            $0.left.right.equalToSuperview()
        }
        
        sureBtn.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(29.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-26 - Screen.bottomSafeAreaHeight)
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

extension ChangeMemberDepartmentAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChangeMemberDepartmentAlertCell.reusableIdentifier, for: indexPath) as! ChangeMemberDepartmentAlertCell
        let location = locations[indexPath.row]
        cell.titleLabel.text = location.name
        
        if selectedDepartments.map(\.id).contains(location.id) {
            cell.tickIcon.image = .assets(.selected_tick)
            cell.titleLabel.textColor = .custom(.blue_2da3f6)
        } else {
            cell.tickIcon.image = .assets(.unselected_tick)
            cell.titleLabel.textColor = .custom(.black_3f4663)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedDepartments.contains(where: { $0.id == locations[indexPath.row].id }) {
            selectedDepartments.removeAll(where: { $0.id == locations[indexPath.row].id})
        } else {
            selectedDepartments.append(locations[indexPath.row])
        }
        tableView.reloadData()
    }
    
}



// MARK: - SwtichAreaViewCell
extension ChangeMemberDepartmentAlert {
    class ChangeMemberDepartmentAlertCell: UITableViewCell, ReusableView {
        lazy var line = UIView().then { $0.backgroundColor = .custom(.gray_eeeeee) }
        
        lazy var titleLabel = Label().then {
            $0.font = .font(size: 14, type: .medium)
            $0.textColor = .custom(.black_3f4663)
            $0.text = "nickname"
        }
        
        

        lazy var tickIcon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.unselected_tick)
            
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            contentView.backgroundColor = .custom(.white_ffffff)
            contentView.addSubview(titleLabel)
            contentView.addSubview(tickIcon)
            contentView.addSubview(line)
            
            
            tickIcon.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel.snp.centerY)
                $0.right.equalToSuperview().offset(-15)
                $0.height.width.equalTo(18)
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(18)
                $0.left.equalToSuperview().offset(18)
                $0.right.equalTo(tickIcon.snp.left).offset(-4.5)
            }
            
            
            line.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(18)
                $0.right.equalToSuperview()
                $0.left.equalToSuperview()
                $0.height.equalTo(0.5)
                $0.bottom.equalToSuperview()
            }

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
