//
//  BrandDetailHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/26.
//

import UIKit

class BrandDetailHeader: UIView {
    var heightChangeCallback: ((_ height: CGFloat) -> ())?

    var pluginClickCallback: ((_ idx: Int) -> ())?
    
    var installPluginCallback: ((_ idx: Int) -> ())?
    
    var deletePluginCallback: ((_ idx: Int) -> ())?
    
    var updatePluginCallback: ((_ idx: Int) -> ())?
    
    var brand = Brand() {
        didSet {
            header.brand = brand
            tableView.reloadData()
        }
    }
    
    lazy var header = BrandDetailHeaderTopCell()

    lazy var shadow = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = false
        $0.layer.shadowColor = UIColor.lightGray.cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowRadius = 3
        $0.layer.shadowOffset = CGSize(width: -0.2, height: -0.2)
    }
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).withAlphaComponent(0.3).cgColor
        $0.separatorStyle = .none
        $0.register(PluginCell.self, forCellReuseIdentifier: PluginCell.reusableIdentifier)
        $0.estimatedRowHeight = 100
        $0.rowHeight = UITableView.automaticDimension
        $0.isScrollEnabled = false
        $0.delegate = self
        $0.dataSource = self
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
        
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
            heightChangeCallback?(height + 20)
            
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(shadow)
        addSubview(tableView)
    }
    
    private func setConstrains() {
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(15).priority(.low)
            $0.right.equalToSuperview().offset(-15).priority(.low)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        shadow.snp.makeConstraints {
            $0.edges.equalTo(tableView)
        }
    }
}

extension BrandDetailHeader: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brand.plugins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PluginCell.reusableIdentifier, for: indexPath) as! PluginCell
        cell.plugin = brand.plugins[indexPath.row]
        cell.installPluginCallback = { [weak self] in
            self?.installPluginCallback?(indexPath.row)
        }
        
        cell.deletePluginCallback = { [weak self] in
            self?.deletePluginCallback?(indexPath.row)
        }
        
        cell.updatePluginCallback = { [weak self] in
            self?.updatePluginCallback?(indexPath.row)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pluginClickCallback?(indexPath.row)
    }
    
    
}
