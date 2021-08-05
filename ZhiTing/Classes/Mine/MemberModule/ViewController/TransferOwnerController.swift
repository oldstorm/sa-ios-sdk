//
//  TransferOwnerController.swift
//  ZhiTing
//
//  Created by zy on 2021/7/7.
//

import UIKit

class TransferOwnerController: BaseViewController {

    private lazy var loadingView = LodingView().then {
        $0.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight - Screen.k_nav_height)
    }

    var area = Area()

    var members = [User]()
    
    var choosedUser : User?
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.register(TransferMemberCell.self, forCellReuseIdentifier: TransferMemberCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 50
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var tipsLabel = Label().then {
        $0.backgroundColor = .clear
        $0.font = .font(size: ZTScaleValue(12), type: .bold)
        $0.textColor = .custom(.gray_94a5be)
        $0.text = "家庭拥有者有家庭的最高权限并且可以删除家庭，你可以转移拥有者角色给成员，转移后你的角色将变更为管理者。".localizedString
        $0.numberOfLines = 0
        
    }
    
    private lazy var labelBGView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var membersLabel = Label().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.text = "选择成员将拥有者角色转移给他：".localizedString
        $0.numberOfLines = 0
    }
    
    //转移按钮
    private lazy var transferButton = CustomButton(buttonType:
                                                    .centerTitleAndLoading(normalModel:
                                                                            .init(
                                                                                title: "转移".localizedString,
                                                                                titleColor: .custom(.white_ffffff),
                                                                                font: .font(size: 14, type: .bold),
                                                                                bagroundColor: .custom(.blue_427aed)
                                                                            )
                                                    )).then {
                                                        $0.alpha = 0.5
                                                        $0.isUserInteractionEnabled = false
                                                        $0.layer.cornerRadius = ZTScaleValue(10)
                                                        $0.layer.masksToBounds = true
                                                        $0.addTarget(self, action: #selector(transferOwner(sender:)), for: .touchUpInside)
                                                    }
        

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "转移拥有者".localizedString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getMembers()
        
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tipsLabel)
        view.addSubview(labelBGView)
        view.addSubview(membersLabel)
        view.addSubview(tableView)
        view.addSubview(transferButton)
    }
    
    override func setupConstraints() {
        tipsLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(-ZTScaleValue(15))
            $0.height.equalTo(ZTScaleValue(50))
        }
        
        labelBGView.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(38.5))
        }

        
        membersLabel.snp.makeConstraints {
            $0.top.equalTo(labelBGView)
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(-ZTScaleValue(15))
            $0.height.equalTo(ZTScaleValue(38.5))
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(membersLabel.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(transferButton.snp.top).offset(ZTScaleValue(5))
        }
        
        transferButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(15))
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(-ZTScaleValue(15))
            $0.height.equalTo(ZTScaleValue(50))
        }
        
    }

    private func getMembers() {
        showLoadingView()
        ApiServiceManager.shared.memberList(area: area) { [weak self] response in
            guard let self = self else { return }
            self.hideLoadingView()
            for (_,user) in response.users.enumerated() {
                if user.user_id != self.area.sa_user_id {
                    self.members.append(user)
                }
            }
            self.tableView.reloadData()
        } failureCallback: {[weak self] code, err in
            self?.showToast(string: err)
            self?.hideLoadingView()
        }

    }
}


extension TransferOwnerController :  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: TransferMemberCell.reusableIdentifier, for: indexPath) as! TransferMemberCell
            cell.selectionStyle = .none
            cell.member = members[indexPath.row]
            return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transferButton.alpha = 1
        transferButton.isUserInteractionEnabled = true
        
        if choosedUser?.user_id == self.members[indexPath.row].user_id  {
            return
        }
        choosedUser = self.members[indexPath.row]
        for (index,user) in self.members.enumerated() {
            if index == indexPath.row {
                if user.isSelected == true {
                    return
                }else{
                    user.isSelected = true
                }
            }else{
                user.isSelected = false
            }
        }
        
        self.tableView.reloadData()
    }
    
    
}

extension TransferOwnerController {
    private func showLoadingView(){
        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        loadingView.show()
    }
    
    private func hideLoadingView(){
        loadingView.hide()
        loadingView.removeFromSuperview()
    }

    @objc private func transferOwner(sender: CustomButton){
        sender.selectedChangeView(isLoading: true)
        ApiServiceManager.shared.transferOwner(area: area, id: choosedUser!.user_id) { [weak self] _ in
            guard let self = self else {return}
            sender.selectedChangeView(isLoading: false)
            SceneDelegate.shared.window?.makeToast("转移成功".localizedString)
            self.navigationController?.popViewController(animated: true)
            
        } failureCallback: { code, error in
            sender.selectedChangeView(isLoading: false)
            self.showToast(string: error)
        }
    }
}

