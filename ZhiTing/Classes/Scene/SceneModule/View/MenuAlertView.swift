//
//  MenuAlertVIew.swift
//  ZhiTing
//
//  Created by mac on 2021/4/20.
//

import UIKit

class MenuAlertView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    var currentSeletedIndex = 0
    
    var SelectCallback: ((_ selectIndex: Int) -> ())?
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.separatorColor = .custom(.gray_eeeeee)
//        $0.isScrollEnabled = false
        //创建场景Cell
        $0.register(MenuAlertCell.self, forCellReuseIdentifier: MenuAlertCell.reusableIdentifier)
        $0.alwaysBounceVertical = false
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.layer.masksToBounds = true
    }
    
    var currentDataArry: [Location]? {
        didSet{
            setupConstraints()
        }
    }
    private lazy var coverView = UIView().then {
        $0.backgroundColor = .clear
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    private lazy var shadowView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.shadowRadius = ZTScaleValue(10)
        $0.layer.shadowOffset = CGSize(width: 1, height: 1)
        $0.layer.shadowOpacity = 1
        $0.layer.shadowColor = UIColor.custom(.gray_cfd6e0).cgColor
        $0.layer.masksToBounds = false
        $0.layer.cornerRadius = ZTScaleValue(10)
    }

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(coverView)
        addSubview(shadowView)
        addSubview(tableView)
    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        shadowView.snp.makeConstraints {
            $0.top.equalTo(Screen.k_nav_height)
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(150))
            $0.height.equalTo(getTableViewHeight())
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(Screen.k_nav_height)
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(150))
            $0.height.equalTo(getTableViewHeight())
        }
    }
    
    private func getTableViewHeight() -> CGFloat{
        let height = ZTScaleValue(50)
        if (currentDataArry?.count ?? 0) <= 4 {//小于4行
            return height * CGFloat(currentDataArry?.count ?? 0)
        }else {//大于4行仅返回四行高度
            if height * CGFloat(currentDataArry?.count ?? 0) > (Screen.screenHeight - Screen.k_nav_height) {
                return Screen.screenHeight - Screen.k_nav_height - 20
            }else{
                return height * CGFloat(currentDataArry?.count ?? 0)
            }
          
        }
    }
    
}

extension MenuAlertView {
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        super.removeFromSuperview()
    }
    
    @objc private func dismiss() {
        removeFromSuperview()
    }

}

extension MenuAlertView {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDataArry?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(50)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuAlertCell.reusableIdentifier, for: indexPath) as! MenuAlertCell
        
        cell.selectionStyle = .none
        cell.title.text = currentDataArry?[indexPath.row].name
        if currentSeletedIndex == indexPath.row {
            cell.setSelectedState(isSelcted: true)
        }else{
            cell.setSelectedState(isSelcted: false)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            tableView.reloadData()
        }
        SelectCallback!(indexPath.row)
        
        dismiss()
    }
}
