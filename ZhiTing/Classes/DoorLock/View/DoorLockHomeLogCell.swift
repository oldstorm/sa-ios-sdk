//
//  DoorLockHomeLogCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/11.
//


import Foundation
import UIKit

class DoorLockHomeLogCell: UITableViewCell, ReusableView {
    var items = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectCallback: ((String) -> ())?
    
    private lazy var shadowBG = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.shadowRadius = 3
        $0.layer.shadowOffset = CGSize(width: -0.3, height: -0.3)
        $0.layer.shadowOpacity = 1
        $0.layer.shadowColor = UIColor.custom(.gray_cfd6e0).withAlphaComponent(0.6).cgColor
        $0.layer.masksToBounds = false
        $0.layer.cornerRadius = 10
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "5月2021年"
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = 50
        $0.isScrollEnabled = false
        $0.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reusableIdentifier)
    }
    
    lazy var btn = Button().then {
        $0.setTitle("查看日志".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 12, type: .medium)
        $0.layer.cornerRadius = 20
        $0.layer.borderColor = UIColor.custom(.blue_2da3f6).cgColor
        $0.layer.borderWidth = 0.5
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(shadowBG)
        contentView.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(tableView)
        container.addSubview(btn)
    }
    
    private func setupConstraints() {
        container.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview()
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        shadowBG.snp.makeConstraints {
            $0.edges.equalTo(container)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.equalToSuperview().offset(15)
        }

        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.height.equalTo(200)
        }
        
        btn.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(15)
            $0.height.equalTo(40)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-15)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let height = (change![.newKey] as? CGSize)?.height  else {
                return
            }
            
            let tableViewHeight = height
            tableView.snp.remakeConstraints {
                $0.left.right.equalToSuperview()
                $0.top.equalTo(titleLabel.snp.bottom).offset(10)
                $0.height.equalTo(tableViewHeight)
            }

        }
    }

}

extension DoorLockHomeLogCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reusableIdentifier, for: indexPath) as! ItemCell
        cell.item = items[indexPath.row]
        cell.line.isHidden = indexPath.row == items.count - 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectCallback?(items[indexPath.row])
        
    }
}


// MARK: - ItemCell
extension DoorLockHomeLogCell {
    class ItemCell: UITableViewCell, ReusableView {
        var item: String? {
            didSet {
                guard let item = item else {
                    return
                }

                titleLabel.text = item
            }
        }
        
        private lazy var icon = UIView().then {
            $0.layer.cornerRadius = 6
            $0.backgroundColor = .custom(.gray_cfd6e0)
        }
        
        private lazy var titleLabel = Label().then {
            $0.font = .font(size: 14, type: .bold)
            $0.textColor = .custom(.black_3f4663)
            $0.text = " "
        }

        private lazy var timeLabel = Label().then {
            $0.font = .font(size: 14, type: .bold)
            $0.textColor = .custom(.black_3f4663)
            $0.text = "5月08日 14:06"
        }
        
        lazy var line = UIView().then {
            $0.backgroundColor = .custom(.gray_cfd6e0)
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
            selectionStyle = .none
            contentView.addSubview(icon)
            contentView.addSubview(titleLabel)
            contentView.addSubview(timeLabel)
            contentView.addSubview(line)
            contentView.addSubview(icon)
        }
        
        private func setupConstraints() {
            icon.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(15)
                $0.height.width.equalTo(12).priority(.high)
            }
            
            titleLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(icon.snp.right).offset(15).priority(.high)
                $0.right.equalTo(timeLabel.snp.left).offset(-10).priority(.high)
            }
            
            timeLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().offset(-15).priority(.high)
            }
            
            line.snp.makeConstraints {
                $0.width.equalTo(1)
                $0.centerX.equalTo(icon.snp.centerX)
                $0.top.equalTo(icon.snp.bottom)
                $0.bottom.equalToSuperview().offset(25)
            }

        }
    }
}

