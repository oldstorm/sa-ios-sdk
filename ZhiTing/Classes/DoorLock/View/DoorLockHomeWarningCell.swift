//
//  DoorLockHomeWarningCell.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/8.
//

import Foundation
import UIKit

class DoorLockHomeWarningCell: UITableViewCell, ReusableView {
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
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = 50
        $0.isScrollEnabled = false
        $0.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reusableIdentifier)
    }
    
    lazy var btn = UnfoldButton()
    
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

        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(200)
        }
        
        btn.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom)
            $0.height.equalTo(50)
            $0.left.right.bottom.equalToSuperview()
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
                $0.top.equalToSuperview()
                $0.height.equalTo(tableViewHeight).priority(.high)
            }

        }
    }

}

extension DoorLockHomeWarningCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reusableIdentifier, for: indexPath) as! ItemCell
        cell.item = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectCallback?(items[indexPath.row])
        
    }
}


// MARK: - ItemCell
extension DoorLockHomeWarningCell {
    class ItemCell: UITableViewCell, ReusableView {
        var item: String? {
            didSet {
                guard let item = item else {
                    return
                }

                titleLabel.text = item
                icon.image = Int.random(in: 1...3) > 1 ? .assets(.icon_warning_red) : .assets(.icon_tips_blue)
            }
        }
        
        private lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.icon_warning)
        }
        
        private lazy var titleLabel = Label().then {
            $0.font = .font(size: 14, type: .bold)
            $0.textColor = .custom(.black_3f4663)
            $0.text = " "
        }

        private lazy var arrow = ImageView().then {
            $0.image = .assets(.arrow_right)
            $0.contentMode = .scaleAspectFit
            $0.alpha = 0.3
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
            selectionStyle = .none
            contentView.addSubview(icon)
            contentView.addSubview(titleLabel)
            contentView.addSubview(arrow)
            contentView.addSubview(line)
        }
        
        private func setupConstraints() {
            icon.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(15)
                $0.height.width.equalTo(18)
            }
            
            titleLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(icon.snp.right).offset(15)
                $0.right.equalTo(arrow.snp.left).offset(-10)
            }
            
            arrow.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().offset(-15)
                $0.width.equalTo(7)
                $0.height.equalTo(14)
            }
            
            line.snp.makeConstraints {
                $0.bottom.equalToSuperview()
                $0.height.equalTo(0.5)
                $0.left.equalToSuperview().offset(15)
                $0.right.equalToSuperview().offset(-15)
            }

        }
    }
}


// MARK: - UnfoldButton
extension DoorLockHomeWarningCell {
    class UnfoldButton: Button {
        /// 是否折叠
        var isFolded: Bool {
            get {
                return isSelected
            }
            
            set {
                isSelected = newValue
                image.transform = newValue ? .identity : .init(rotationAngle: CGFloat.pi)
                title.text = isSelected ? "展开".localizedString : "收起".localizedString
            }
        }
        
        private lazy var title = Label().then {
            $0.textColor = .custom(.gray_94a5be)
            $0.font = .font(size: 14, type: .bold)
            $0.text = "展开".localizedString
        }
        
        private lazy var image = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.icon_double_arrow)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            isFolded = true
            addSubview(image)
            addSubview(title)
            
            title.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.centerX.equalToSuperview().offset(-20)
            }
            
            image.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(title.snp.right).offset(8).priority(.high)
                $0.height.width.equalTo(10)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        


    }
    
}
