//
//  DoorLockSettingLanguageAlert.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/12.
//

import Foundation

class DoorLockSettingLanguageAlert: UIView {
    var selectCallback: ((_ item: Item) -> ())?
    var selectedItem: Item? {
        didSet {
            tableView.reloadData()
        }
    }
   
    var items = [Item]()
    
    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    lazy var titleLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(16), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "语言选择".localizedString
    }
    
    lazy var detailLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.gray_94a5be)
        $0.textAlignment = .center
    }
    
    private lazy var closeButton = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    
    lazy var tableView = UITableView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = UITableView.automaticDimension
        $0.isScrollEnabled = false
        $0.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reusableIdentifier)
        
    }
    
    
    // MARK: - Life Cycle
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        items = Item.allCases
        tableView.reloadData()
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(tableView)
        containerView.addSubview(titleLabel)
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
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(ZTScaleValue(20.5))
            $0.top.equalToSuperview().offset(ZTScaleValue(16.5))
            $0.right.equalTo(closeButton.snp.left).offset(ZTScaleValue(-10))
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(17.5))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.width.equalTo(ZTScaleValue(9))
        }
        
        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(18))
            $0.bottom.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(210))
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
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
    
    private func dismissWithCallback(value: Item) {
        self.endEditing(true)
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }, completion: { isFinished in
            if isFinished {
                weakSelf?.selectCallback?(value)
                super.removeFromSuperview()
            }
        })
    }
    
}

// MARK: - 选项相关方法
extension DoorLockSettingLanguageAlert {
    class ItemCell: UITableViewCell, ReusableView {
        
        private lazy var line = UIView().then {
            $0.backgroundColor = .custom(.gray_eeeeee)
        }
        
        
        lazy var selection = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.unselected_tick)
        }
        
        lazy var titleLabel = Label().then {
            $0.font = .font(size: ZTScaleValue(14), type: .regular)
            $0.textColor = .custom(.black_3f4663)
            $0.numberOfLines = 0
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
            contentView.addSubview(titleLabel)
            contentView.addSubview(line)
            contentView.addSubview(selection)
           
        }
        
        private func setupConstraints() {
            line.snp.makeConstraints {
                $0.height.equalTo(0.5)
                $0.top.left.right.equalToSuperview()
            }
            
            selection.snp.makeConstraints {
                $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(20.5))
                $0.right.equalToSuperview().offset(ZTScaleValue(-15))
                $0.width.equalTo(ZTScaleValue(18.5))
                $0.height.equalTo(ZTScaleValue(18.5))
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(22.5))
                $0.left.equalToSuperview().offset(ZTScaleValue(15))
                $0.right.equalTo(selection.snp.left).offset(ZTScaleValue(-10))
                $0.bottom.equalToSuperview().offset(ZTScaleValue(-23.5))
            }
            
            
            
            
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let height = (change![.newKey] as? CGSize)?.height  else {
                return
            }
            
            let tableViewHeight = height + 10
            tableView.snp.remakeConstraints {
                $0.left.right.equalToSuperview()
                $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(18))
                $0.bottom.equalToSuperview()
                $0.height.equalTo(ZTScaleValue(tableViewHeight))
            }
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
}

extension DoorLockSettingLanguageAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reusableIdentifier, for: indexPath) as! ItemCell
        let item = items[indexPath.row]
        cell.titleLabel.text = item.title
        cell.titleLabel.textColor = item.title == selectedItem?.title ? .custom(.blue_2da3f6) : .custom(.black_3f4663)
        cell.selection.image = item.title == selectedItem?.title ? .assets(.selected_tick) : .assets(.unselected_tick)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedItem = items[indexPath.row]
        tableView.reloadData()
        dismissWithCallback(value: items[indexPath.row])
    }
    
}


extension DoorLockSettingLanguageAlert {
    enum Item: CaseIterable {
        case cn
        case en
        
        var title: String {
            switch self {
            case .en:
                return "英文".localizedString
            case .cn:
                return "中文".localizedString
                
            }
        }
    }
}
