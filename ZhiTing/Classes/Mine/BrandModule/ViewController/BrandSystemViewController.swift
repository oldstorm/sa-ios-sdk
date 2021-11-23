//
//  BrandSystemViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/24.
//

import UIKit
import Alamofire
import JXSegmentedView

class BrandSystemViewController: BaseViewController {
    private lazy var brands = [Brand]()

    private lazy var emptyView = EmptyStyleView(frame: .zero, style: .noContent)
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.white_ffffff)
        $0.register(BrandCell.self, forCellReuseIdentifier: BrandCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 80
        $0.delegate = self
        $0.dataSource = self
    }

    private lazy var headerView = BrandListHeader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestNetwork()
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        
        view.addSubview(headerView)
        view.addSubview(tableView)
        
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
        tableView.addSubview(emptyView)
        emptyView.isHidden = true
        
    }
    
    override func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.width.equalTo(tableView)
            $0.height.equalTo(tableView)
            $0.center.equalToSuperview()
        }
        
    }
    
    @objc func requestNetwork() {
        ApiServiceManager.shared.brands(name: "") { [weak self] (response) in
            guard let self = self else { return }
            self.brands = response.brands
            self.emptyView.isHidden = self.brands.count != 0
            self.tableView.reloadData()
            

            self.tableView.mj_header?.endRefreshing()
            
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.emptyView.isHidden = self.brands.count != 0
            self.tableView.mj_header?.endRefreshing()
        }

    }
    
}

extension BrandSystemViewController {
    
    func installPlugin(brand: Brand) {
        let plugins = brand.plugins.filter({ !$0.is_newest || !$0.is_added }).map(\.id)
        brand.is_updating = true
        tableView.reloadData()
        ApiServiceManager.shared.installPlugin(name: brand.name, plugins: plugins) { [weak self] resp in
            guard let self = self else { return }
            brand.is_updating = false
            if resp.success_plugins.count >= brand.plugins.count {
                brand.is_newest = true
                brand.is_added = true
            }
            
            self.tableView.reloadData()
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.showToast(string: err)
            brand.is_updating = false
            self.tableView.reloadData()
        }
    }

}


extension BrandSystemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BrandCell.reusableIdentifier, for: indexPath) as! BrandCell
        let brand = brands[indexPath.row]
        cell.brand = brand
        cell.buttonCallback = { [weak self] in
            guard let self = self else { return }
            self.installPlugin(brand: brand)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = BrandDetailViewController()
        vc.brand_name = brands[indexPath.row].name
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

extension BrandSystemViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
