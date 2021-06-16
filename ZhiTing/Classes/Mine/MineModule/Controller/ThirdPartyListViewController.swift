//
//  ThirdPartyListViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/23.
//

import UIKit


class ThirdPartyListViewController: BaseViewController {
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.rowHeight = 50
        $0.separatorStyle = .none
        $0.register(ThirdPartyCell.self, forCellReuseIdentifier: ThirdPartyCell.reusableIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "第三方平台".localizedString
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
}

extension ThirdPartyListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ThirdPartyCell.reusableIdentifier, for: indexPath) as! ThirdPartyCell
        cell.title.text = "小度"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = WKWebViewController(link: "http://192.168.0.184:8080/#/third-explain")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
