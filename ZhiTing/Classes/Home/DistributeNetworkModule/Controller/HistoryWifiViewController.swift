//
//  HistoryWifiViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/7/9.
//

import UIKit

class HistoryWifiViewController: BaseViewController {
    private lazy var wifis = [WifiModel]()
    
    var callback: ((_ wifiModel: WifiModel) -> ())?

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.rowHeight = 50
        $0.delegate = self
        $0.dataSource = self
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "wificell")
        $0.separatorColor = .custom(.gray_eeeeee)
        $0.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "WLAN"
        wifis = networkStateManager.getHistoryWifiList()
        tableView.reloadData()
    }
    
    override func setupViews() {
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}

extension HistoryWifiViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wifis.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wificell", for: indexPath)
        cell.textLabel?.text = wifis[indexPath.row].wifiName
        cell.accessoryView = ImageView(image: .assets(.icon_wifi_blue))
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        callback?(wifis[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
}
