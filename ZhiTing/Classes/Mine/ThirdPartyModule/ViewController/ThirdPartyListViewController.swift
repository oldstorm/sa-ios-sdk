//
//  ThirdPartyListViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/10.
//

import UIKit

class ThirdPartyListViewController: BaseViewController {
    private lazy var items = [ThirdPartyCloudModel]()

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.register(ThirdPartyListCell.self, forCellReuseIdentifier: ThirdPartyListCell.reusableIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "第三方平台".localizedString
        requestNetwork()
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    @objc
    private func requestNetwork() {
        if items.count == 0 {
            showLoadingView()
        }
        
        if UserManager.shared.isLogin || AuthManager.shared.isSAEnviroment {
            ApiServiceManager.shared.thirdPartyCloudListSA(area: AuthManager.shared.currentArea) { [weak self] response in
                guard let self = self else { return }
                self.hideLoadingView()
                self.tableView.mj_header?.endRefreshing()
                self.items = response.apps
                self.tableView.reloadData()

            } failureCallback: { [weak self] code, err in
                guard let self = self else { return }
                ApiServiceManager.shared.thirdPartyCloudListSC(area: AuthManager.shared.currentArea) { [weak self] response in
                    guard let self = self else { return }
                    self.hideLoadingView()
                    self.tableView.mj_header?.endRefreshing()
                    self.items = response.apps
                    self.tableView.reloadData()

                } failureCallback: { [weak self] code, err in
                    guard let self = self else { return }
                    self.hideLoadingView()
                    self.tableView.mj_header?.endRefreshing()
                    self.showToast(string: err)
                }
            }
        } else {
            ApiServiceManager.shared.thirdPartyCloudListSC(area: AuthManager.shared.currentArea) { [weak self] response in
                guard let self = self else { return }
                self.hideLoadingView()
                self.tableView.mj_header?.endRefreshing()
                self.items = response.apps
                self.tableView.reloadData()

            } failureCallback: { [weak self] code, err in
                guard let self = self else { return }
                self.hideLoadingView()
                self.tableView.mj_header?.endRefreshing()
                self.showToast(string: err)
            }
        }
        
        

    }

}


extension ThirdPartyListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ThirdPartyListCell.reusableIdentifier, for: indexPath) as! ThirdPartyListCell
        cell.item = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let vc = ThirdPartyDetailViewController(link: item.link, item: item)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
