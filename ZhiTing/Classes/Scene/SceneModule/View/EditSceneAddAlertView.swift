//
//  EditSceneAddAlertView.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/12.
//

import UIKit

class EditSceneAddAlertView: UIView {
    var selectCallback: ((_ index: Int) -> ())?

    lazy var items = [Item]()

    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(16), type: .bold)
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var closeButton = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = UITableView.automaticDimension
        $0.isScrollEnabled = false
        $0.separatorColor = .custom(.gray_eeeeee)
        $0.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reusableIdentifier)
    }


    func reloadData() {
        tableView.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    convenience init(title: String, items: [Item], callback: ((_ index: Int) -> ())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        self.titleLabel.text = title
        self.items = items
        self.tableView.reloadData()
        self.selectCallback = callback
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
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
                $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(18))
                $0.bottom.equalToSuperview()
                $0.height.equalTo(ZTScaleValue(tableViewHeight))
            }

        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
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
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
    
    private func dismissWithCallback(idx: Int) {
        self.endEditing(true)
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }, completion: { isFinished in
            if isFinished {
                weakSelf?.selectCallback?(idx)
                super.removeFromSuperview()
            }
        })
    }
}


extension EditSceneAddAlertView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reusableIdentifier, for: indexPath) as! ItemCell
        cell.item = items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismissWithCallback(idx: indexPath.row)
    }
    
}



extension EditSceneAddAlertView {
    class Item {
        let image: UIImage?
        let title: String
        let detail: String
        var isEnable: Bool = true
        init(image: UIImage?, title: String, detail: String) {
            self.image = image
            self.title = title
            self.detail = detail
        }
    }
    
    
    class ItemCell: UITableViewCell, ReusableView {
        var item: Item? {
            didSet {
                guard let item = item else { return }
                imageIcon.image = item.image
                titleLabel.text = item.title
                detailLabel.text = item.detail
                if item.isEnable {
                    contentView.alpha = 1
                    isUserInteractionEnabled = true
                } else {
                    contentView.alpha = 0.5
                    isUserInteractionEnabled = false
                }
            }
        }

        private lazy var line = UIView().then {
            $0.backgroundColor = .custom(.gray_eeeeee)
        }
        
        private lazy var imageIcon = ImageView().then {
            $0.contentMode = .scaleAspectFit
        }
        
        private lazy var arrow = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.right_arrow_gray)
        }
        
        private lazy var titleLabel = Label().then {
            $0.font = .font(size: ZTScaleValue(14), type: .bold)
            $0.textColor = .custom(.black_3f4663)
            $0.numberOfLines = 0
        }
        
        private lazy var detailLabel = Label().then {
            $0.font = .font(size: ZTScaleValue(11), type: .medium)
            $0.textColor = .custom(.gray_94a5be)
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
            contentView.addSubview(imageIcon)
            contentView.addSubview(titleLabel)
            contentView.addSubview(detailLabel)
            contentView.addSubview(line)
            contentView.addSubview(arrow)
        }
        
        private func setupConstraints() {
            line.snp.makeConstraints {
                $0.height.equalTo(0.5)
                $0.top.left.right.equalToSuperview()
            }
            
            imageIcon.snp.makeConstraints {
                $0.width.height.equalTo(ZTScaleValue(40))
                $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(15))
                $0.left.equalToSuperview().offset(ZTScaleValue(20))
            }
            
            arrow.snp.makeConstraints {
                $0.centerY.equalTo(imageIcon.snp.centerY)
                $0.right.equalToSuperview().offset(ZTScaleValue(-15))
                $0.width.equalTo(ZTScaleValue(7.5))
                $0.height.equalTo(ZTScaleValue(13.5))
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalTo(imageIcon.snp.top).offset(ZTScaleValue(2.5))
                $0.left.equalTo(imageIcon.snp.right).offset(ZTScaleValue(15))
                $0.right.equalTo(arrow.snp.left).offset(ZTScaleValue(-10))
            }
            
            detailLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom)
                $0.left.equalTo(imageIcon.snp.right).offset(ZTScaleValue(15))
                $0.right.equalTo(arrow.snp.left).offset(ZTScaleValue(-10))
                $0.bottom.equalToSuperview().offset(ZTScaleValue(-20.5))
            }


        }

    }

}
