//
//  MemberInfoViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/31.
//

import UIKit

class MemberInfoViewController: BaseViewController {
    
    private lazy var roleCell = MemberInfoRoleCell()
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f1f4fc)
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var deleteButton = BottomButton(frame: .zero, icon: nil, title: "删除成员".localizedString, titleColor: .custom(.black_3f4663), backgroundColor: .custom(.white_ffffff))
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "成员信息".localizedString
    }
    
    

}

extension MemberInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return roleCell
    }
    
    
}
