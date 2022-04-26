//
//  CompanyGenerateQRCodeAlert.swift
//  ZhiTing
//
//  Created by iMac on 2021/12/15.
//

import Foundation


class CompanyGenerateQRCodeAlert: UIView {
    var callback: ((_ role: [Role], _ departments: [Location]) -> Void)?

    
    private lazy var roleAlert = RoleAlert()
    private lazy var departmentAlert = DepartmentAlert()
    
    private lazy var selectedRoles = [Role]()
    private lazy var selectedDepartments = [Location]()


    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private lazy var departmentCell = ValueDetailCell().then {
        $0.title.text = "部门".localizedString
        $0.valueLabel.text = "请选择部门".localizedString
    }
    
    private lazy var roleCell = ValueDetailCell().then {
        $0.title.text = "角色".localizedString
        $0.valueLabel.text = "请选择角色".localizedString
        $0.bottomLine.isHidden = false
    }

    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "邀请码".localizedString
    }
    
    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 11, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "选择部门和角色生成邀请码，即可邀请员工加入，邀请码10分钟内有效".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var closeButton = Button().then {
        $0.isEnhanceClick = true
        $0.setImage(.assets(.close_button), for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.rowHeight = 60
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
    }
    
    
    lazy var generateButton = CustomButton(buttonType:
                                                    .leftLoadingRightTitle(
                                                        normalModel:
                                                            .init(
                                                                title: "生成邀请码".localizedString,
                                                                titleColor: UIColor.custom(.black_3f4663),
                                                                font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                                backgroundColor: UIColor.custom(.gray_f6f8fd)
                                                            ),
                                                        lodingModel:
                                                            .init(
                                                                title: "生成中...".localizedString,
                                                                titleColor: UIColor.custom(.gray_94a5be),
                                                                font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                                backgroundColor: UIColor.custom(.gray_f6f8fd)
                                                            )
                                                    )
    ).then {
        $0.isEnabled = false
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.title.textColor = .custom(.gray_94a5be)
        $0.addTarget(self, action: #selector(onClickGenerate), for: .touchUpInside)
    }
    
    @objc private func onClickGenerate() {
        if roleAlert.selectedRoles.count == 0 {
            self.makeToast("请选择角色".localizedString)
            return
        }
        
        if departmentAlert.selectedDepartments.count == 0 {
            self.makeToast("请选择部门".localizedString)
            return
        }

        callback?(roleAlert.selectedRoles, departmentAlert.selectedDepartments)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(cover)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(tipsLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(tableView)
        containerView.addSubview(generateButton)
        containerView.addSubview(line)
        
        roleAlert.callback = { [weak self] roles in
            guard let self = self else { return }
            self.selectedRoles = roles
            self.roleCell.valueLabel.text = self.selectedRoles.map(\.name).joined(separator: "、")
            if self.selectedRoles.count == 0 {
                self.roleCell.valueLabel.text = "请选择角色".localizedString
            }
            
            if self.selectedDepartments.count != 0 && self.selectedRoles.count != 0 {
                self.generateButton.isEnabled = true
                self.generateButton.title.textColor = .custom(.black_333333)
                
            } else {
                self.generateButton.isEnabled = false
                self.generateButton.title.textColor = .custom(.gray_94a5be)
            }
             
        }
        
        departmentAlert.callback = { [weak self] departments in
            guard let self = self else { return }
            self.selectedDepartments = departments
            self.departmentCell.valueLabel.text = self.selectedDepartments.map(\.name).joined(separator: "、")
            if self.selectedDepartments.count == 0 {
                self.departmentCell.valueLabel.text = "请选择部门".localizedString
            }
            
            if self.selectedRoles.count != 0 && self.selectedDepartments.count != 0 {
                self.generateButton.isEnabled = true
                self.generateButton.title.textColor = .custom(.black_333333)
            } else {
                self.generateButton.isEnabled = false
                self.generateButton.title.textColor = .custom(.gray_94a5be)
            }
        }

    }
    
    private func setupConstraints() {
        cover.snp.makeConstraints {
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
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16.5)
            $0.left.equalToSuperview().offset(20)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.equalTo(titleLabel.snp.left)
            $0.right.equalTo(closeButton.snp.left).offset(-5)
        }
        
        line.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.top.equalTo(tipsLabel.snp.bottom).offset(12.5)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(120)
        }
        
        generateButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(29.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-26 - Screen.bottomSafeAreaHeight)
        }
    }
    
    func setupRoles(roles: [Role]) {
        roleAlert.setupRoles(roles: roles)
    }
    
    func setupDepartments(departments: [Location]) {
        departmentAlert.setupDepartments(departments: departments)
    }
    
    func reset() {
        selectedRoles = []
        selectedDepartments = []
        roleAlert.selectedRoles = [Role]()
        departmentAlert.selectedDepartments = [Location]()
        roleCell.valueLabel.text = "请选择角色".localizedString
        departmentCell.valueLabel.text = "请选择部门".localizedString
        generateButton.isEnabled = false
        generateButton.title.textColor = .custom(.gray_94a5be)
    }
    
}

extension CompanyGenerateQRCodeAlert {
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
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
}

extension CompanyGenerateQRCodeAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return departmentCell
        } else {
            return roleCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            departmentAlert.selectedDepartments = self.selectedDepartments
            SceneDelegate.shared.window?.addSubview(departmentAlert)
        } else {
            roleAlert.selectedRoles = self.selectedRoles
            SceneDelegate.shared.window?.addSubview(roleAlert)
        }

    }
    
}

// MARK: - ValueCell
fileprivate class ValueCell: UITableViewCell, ReusableView {
    
    lazy var titleLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
    }
    
    lazy var selectButton = SelectButton(type: .square).then { $0.isUserInteractionEnabled = false }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(titleLabel)
        contentView.addSubview(selectButton)
        contentView.addSubview(line)
    }
    
    private func setupConstraints() {
        selectButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17.5)
            $0.right.equalToSuperview().offset(-15)
            $0.height.width.equalTo(18.5)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalTo(selectButton.snp.left)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(17)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.bottom.equalToSuperview()
        }
        
    }
    
    
}

// MARK: - RoleAlert
fileprivate class RoleAlert: UIView {
    var callback: ((_ role: [Role]) -> Void)?
    private lazy var roles = [Role]()
    
    var selectedRoles = [Role]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "角色".localizedString
    }
    
    
    private lazy var closeButton = Button().then {
        $0.isEnhanceClick = true
        $0.setImage(.assets(.close_button), for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.rowHeight = 60
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.register(ValueCell.self, forCellReuseIdentifier: ValueCell.reusableIdentifier)
    }
    
    lazy var doneButton = Button().then {
        $0.setTitle("确定".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.addTarget(self, action: #selector(done), for: .touchUpInside)
    }
    
    @objc private func done() {
        if selectedRoles.count == 0 {
            self.makeToast("请选择角色".localizedString)
            return
        }
        
        callback?(selectedRoles)
        removeFromSuperview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize", context: nil)
            
    }
    
    private func setupViews() {
        addSubview(cover)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(tableView)
        containerView.addSubview(line)
        containerView.addSubview(doneButton)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let height = (change![.newKey] as? CGSize)?.height  else {
                return
            }
            
            var tableViewHeight = height
            tableViewHeight = max(220, min(tableViewHeight, 500))

            tableView.snp.remakeConstraints {
                $0.top.equalTo(line.snp.bottom)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(tableViewHeight)
            }

        }
    }
    
    private func setupConstraints() {
        cover.snp.makeConstraints {
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
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16.5)
            $0.left.equalToSuperview().offset(20)
        }
        
        line.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12.5)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(290)
        }
        
        doneButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(29.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-26 - Screen.bottomSafeAreaHeight)
        }
    }
    
    func setupRoles(roles: [Role]) {
        /// 筛选掉拥有者
        self.roles = roles.filter({ $0.id != -1 })
        tableView.reloadData()
    }
    
}

extension RoleAlert {
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
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
}

extension RoleAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ValueCell.reusableIdentifier, for: indexPath) as! ValueCell
        cell.titleLabel.text = roles[indexPath.row].name
        cell.titleLabel.textColor = selectedRoles.contains(where: { $0.id == roles[indexPath.row].id }) ? .custom(.blue_2da3f6) : .custom(.gray_94a5be)
        cell.selectButton.type = .square
        cell.selectButton.isSelected = selectedRoles.contains(where: { $0.id == roles[indexPath.row].id })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedRoles.contains(where: { $0.id == roles[indexPath.row].id }) {
            selectedRoles.removeAll(where: { $0.id == roles[indexPath.row].id })
        } else {
            selectedRoles.append(roles[indexPath.row])
        }
        
        tableView.reloadData()
        
    }
    
}





// MARK: - DepartmentAlert
fileprivate class DepartmentAlert: UIView {
    var callback: ((_ departments: [Location]) -> Void)?
    
    private lazy var departments = [Location]()
    
    var selectedDepartments = [Location]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "部门".localizedString
    }
    
    
    private lazy var closeButton = Button().then {
        $0.isEnhanceClick = true
        $0.setImage(.assets(.close_button), for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.rowHeight = 60
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.register(ValueCell.self, forCellReuseIdentifier: ValueCell.reusableIdentifier)
    }
    
    lazy var doneButton = Button().then {
        $0.setTitle("确定".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.addTarget(self, action: #selector(done), for: .touchUpInside)
    }
    
    @objc private func done() {
        if selectedDepartments.count == 0 {
            self.makeToast("请选择部门".localizedString)
            return
        }
        
        callback?(selectedDepartments)
        removeFromSuperview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize", context: nil)
            
    }
    
    private func setupViews() {
        addSubview(cover)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(tableView)
        containerView.addSubview(line)
        containerView.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        cover.snp.makeConstraints {
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
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16.5)
            $0.left.equalToSuperview().offset(20)
        }
        
        line.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12.5)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(290)
            
        }
        
        doneButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(29.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-26 - Screen.bottomSafeAreaHeight)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let height = (change![.newKey] as? CGSize)?.height  else {
                return
            }
            
            var tableViewHeight = height
            tableViewHeight = max(220, min(tableViewHeight, 500))

            tableView.snp.remakeConstraints {
                $0.top.equalTo(line.snp.bottom)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(tableViewHeight)
                
            }

        }
    }
    
    func setupDepartments(departments: [Location]) {
        self.departments = departments
        tableView.reloadData()
    }
    
}

extension DepartmentAlert {
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
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
}

extension DepartmentAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ValueCell.reusableIdentifier, for: indexPath) as! ValueCell
        cell.titleLabel.text = departments[indexPath.row].name
        cell.titleLabel.textColor = selectedDepartments.contains(where: { $0.id == departments[indexPath.row].id }) ? .custom(.blue_2da3f6) : .custom(.gray_94a5be)
        cell.selectButton.type = .rounded
        cell.selectButton.isSelected = selectedDepartments.contains(where: { $0.id == departments[indexPath.row].id })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedDepartments.contains(where: { $0.id == departments[indexPath.row].id }) {
            selectedDepartments.removeAll(where: { $0.id == departments[indexPath.row].id })
        } else {
            selectedDepartments = [departments[indexPath.row]]
        }
        
        tableView.reloadData()
        
    }
    
}

