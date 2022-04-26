//
//  DoorLockHomeAlert.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/8.
//

import Foundation
import UIKit


class DoorLockHomeAlert: UIView {
    var selectCallback: ((_ item: Item) -> ())?

    var items = [Item]() {
        didSet {
            tableView.reloadData()
        }
    }

    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var closeButton = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private lazy var tableView = UITableView().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = 50
        $0.isScrollEnabled = false
        $0.register(ValueDetailCell.self, forCellReuseIdentifier: ValueDetailCell.reusableIdentifier)
    }


    func reloadData() {
        tableView.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    convenience init(items: [Item], callback: ((_ item: Item) -> ())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.items = items
        self.tableView.reloadData()
        self.selectCallback = callback
        
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize", context: nil)
            
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let height = (change![.newKey] as? CGSize)?.height  else {
                return
            }
            
            let tableViewHeight = height + 10
            tableView.snp.remakeConstraints {
                $0.left.right.equalToSuperview()
                $0.top.equalToSuperview()
                $0.height.equalTo(tableViewHeight)
            }

        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(tableView)
        containerView.addSubview(closeButton)
        closeButton.isEnhanceClick = true
    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(14)
            $0.bottom.equalToSuperview().offset(-20 - Screen.bottomSafeAreaHeight)
        }

        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(200)
        }


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
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
    
}


extension DoorLockHomeAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ValueDetailCell.reusableIdentifier, for: indexPath) as! ValueDetailCell
        cell.title.text = items[indexPath.row].title
        cell.bottomLine.isHidden = false
        cell.line.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectCallback?(items[indexPath.row])
        dismiss()
    }
    
}



extension DoorLockHomeAlert {
    enum Item {
        /// 一次性密码
        case oneTimePwd
        /// 用户管理
        case usersManagement
        /// 门锁设置
        case lockSettings
        
        var title: String {
            switch self {
            case .oneTimePwd:
                return "一次性密码".localizedString
            case .usersManagement:
                return "用户管理".localizedString
            case .lockSettings:
                return "门锁设置".localizedString

            }
        }
    }
}
