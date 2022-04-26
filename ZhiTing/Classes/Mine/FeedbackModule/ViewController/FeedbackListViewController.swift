//
//  FeedbackListViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/21.
//

import Foundation
import UIKit

class FeedbackListViewController: BaseViewController {
    private lazy var feedbacks = [Feedback]()
    
    private lazy var emptyView = EmptyStyleView(frame: .zero, style: .noFeedbacks)
    
    private lazy var navRightButton = Button().then {
        $0.setImage(.assets(.icon_create_feedback), for: .normal)
        $0.frame.size = CGSize(width: 24, height: 24)
    }

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.contentInset.bottom = 15
        $0.register(FeedbackListCell.self, forCellReuseIdentifier: FeedbackListCell.reusableIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "我的反馈".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightButton)
        
        requestNetwork()
    }
    
    
    override func setupViews() {
        view.addSubview(tableView)
        tableView.addSubview(emptyView)
        emptyView.isHidden = true
        
        navRightButton.clickCallBack = { [weak self] _ in
            let vc = FeedbackViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }

        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
        
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.width.equalTo(tableView)
            $0.height.equalTo(tableView)
            $0.center.equalToSuperview()
        }
    }

}

extension FeedbackListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbacks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedbackListCell.reusableIdentifier, for: indexPath) as! FeedbackListCell
        cell.feedback = feedbacks[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = FeedbackDetailViewController()
        vc.feedback_id = feedbacks[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension FeedbackListViewController {
    @objc
    private func requestNetwork() {
        if feedbacks.count == 0 {
            showLoadingView()
        }
        
        ApiServiceManager.shared.feedbackList(user_id: UserManager.shared.currentUser.user_id) { [weak self] response in
            guard let self = self else { return }
            self.hideLoadingView()
            self.tableView.mj_header?.endRefreshing()
            self.feedbacks = response.feedbacks
            self.tableView.reloadData()
            self.emptyView.isHidden = !(self.feedbacks.count == 0)

        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.hideLoadingView()
            self.tableView.mj_header?.endRefreshing()
            self.showToast(string: err)
            self.emptyView.isHidden = !(self.feedbacks.count == 0)

        }
    }
}
