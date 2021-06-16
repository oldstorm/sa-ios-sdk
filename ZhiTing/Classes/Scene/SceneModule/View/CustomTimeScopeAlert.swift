//
//  CustomTimeScopeAlert.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/20.
//

import UIKit

class CustomTimeScopeAlert: UIView {
    

    var callback: ((_ days: [Day]) -> Void)?
    var days = [Day]()
    
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "自定义".localizedString
    }
    
    
    private lazy var closeButton = Button().then {
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
        $0.register(RoleCell.self, forCellReuseIdentifier: RoleCell.reusableIdentifier)
    }
    
    private lazy var sureButton = ImageTitleButton(frame: .zero, icon: nil, title: "完成".localizedString, titleColor: .custom(.black_3f4663), backgroundColor: .custom(.gray_f1f4fd)).then {
        $0.clickCallBack = { [weak self] in
            guard let self = self else { return }
            let selectedRoles = self.days.filter { $0.is_selected }
            if selectedRoles.count == 0 {
                self.makeToast("请选择日期".localizedString)
                return
            }

            self.callback?(selectedRoles)
            self.dismiss()
            
        }
        
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .disabled)
    }
    
    
    override init(frame: CGRect = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight)) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        
        ///  设置
        setupDays(days: [
            .init(name: "周一", is_selected: false),
            .init(name: "周二", is_selected: false),
            .init(name: "周三", is_selected: false),
            .init(name: "周四", is_selected: false),
            .init(name: "周五", is_selected: false),
            .init(name: "周六", is_selected: false),
            .init(name: "周日", is_selected: false)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(cover)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(tableView)
        containerView.addSubview(line)
        containerView.addSubview(sureButton)
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
            $0.height.equalTo(420)
            $0.left.right.equalToSuperview()
        }
        
        sureButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(29.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-26 - Screen.bottomSafeAreaHeight)
        }
    }
    
    func setupDays(days: [Day]) {
        self.days = days
        sureButton.isEnabled = (days.filter { $0.is_selected }.count > 0)
        tableView.reloadData()
    }
    
}

extension CustomTimeScopeAlert {
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

extension CustomTimeScopeAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoleCell.reusableIdentifier, for: indexPath) as! RoleCell
        cell.titleLabel.text = days[indexPath.row].name
        cell.titleLabel.textColor = days[indexPath.row].is_selected ? .custom(.blue_2da3f6) : .custom(.gray_94a5be)
        cell.selectButton.isSelected = days[indexPath.row].is_selected
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        days[indexPath.row].is_selected = !days[indexPath.row].is_selected
        sureButton.isEnabled = (days.filter { $0.is_selected }.count > 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}

extension CustomTimeScopeAlert {
    class RoleCell: UITableViewCell, ReusableView {

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
}


extension CustomTimeScopeAlert {
    struct Day {
        var name: String
        var is_selected: Bool
        
    }
}
