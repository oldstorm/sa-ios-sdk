//
//  HistoryViewController.swift
//  ZhiTing
//
//  Created by mac on 2021/4/13.
//

import UIKit

class HistoryViewController: BaseViewController {
    
    private var currentDataArray:  [SceneHistoryMonthModel]?
    private var stateArray: [historyStateModel]?//状态数据
    private var currentPage = 0 //当前分页
    private var isGetAllData = false//是否已获取服务器所有数据
    private lazy var emptyView = EmptyStyleView(frame: .zero, style: .noHistory)



    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.estimatedSectionHeaderHeight = 10
        $0.estimatedSectionFooterHeight = 0
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        //创建Cell
        $0.register(HistoryFirstCell.self, forCellReuseIdentifier: HistoryFirstCell.reusableIdentifier)

    }
    


    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "执行日志".localizedString
        navigationController?.setNavigationBarHidden(false, animated: true)
        showLoadingView()
        reloadRequest()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)

    }
    
    override func setupViews() {
        

        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(tableView)
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(reload))
        tableView.mj_footer = MJRefreshAutoNormalFooter()
        tableView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(loadNextData))
        
        tableView.addSubview(emptyView)
        emptyView.isHidden = true
    }
    
    @objc func reloadAllData() {
        tableView.reloadData()
    }
    
    override func setupConstraints() {
        
        tableView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.width.equalTo(tableView)
            $0.height.equalTo(tableView)
            $0.center.equalToSuperview()
        }
        
    }
        
      private func getStateData() {
        guard let datas = currentDataArray else {
            return
        }
        stateArray = nil
        var states = [historyStateModel]()
        
        for (index,element) in datas.enumerated() {

           for (index2,element2) in element.items.enumerated(){
            let stateModel = historyStateModel()
            stateModel.isOpen = false
            stateModel.section = index
            stateModel.row = index2
            stateModel.openHeight = CGFloat(element2.items.count) * ZTScaleValue(70.0)
            states.append(stateModel)
            }
        }
        stateArray = states
    }
}

extension HistoryViewController {
    private func reloadRequest() {
        let page = currentPage
        ApiServiceManager.shared.sceneLogs(start: page, size: 40) {[weak self] (respond) in
            guard let self = self else { return }
            if self.currentDataArray == nil{//下拉刷新 or 首次加载数据
                self.tableView.mj_header?.endRefreshing()
                self.currentDataArray = respond
                self.getStateData()
                if respond.count == 0 {
                    self.emptyView.isHidden = false
                }else{
                    self.emptyView.isHidden = true
                }
                
                if respond.count < 40 {
                    self.tableView.mj_footer?.isHidden = true
                }else{
                    self.tableView.mj_footer?.isHidden = false
                }
                self.tableView.reloadData()
                self.hideLoadingView()
            }else{//上拉加载更多数据
                self.tableView.mj_footer?.endRefreshing()
                if respond.count == 0 {//已无数据
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    self.isGetAllData = true
                    return
                }
                self.isGetAllData = false
                var sctionNames = [String]()
                self.currentDataArray!.forEach({
                    sctionNames.append($0.date)
                })
                
                var dataArray = self.currentDataArray!
                
                for (_,element) in respond.enumerated() {
                    if sctionNames.contains(element.date) {//如果数据来源存在已有月份，则插入新数据到当前月份
                        for (index,element2) in self.currentDataArray!.enumerated() {
                            if element.date == element2.date {
                                dataArray[index].items.append(contentsOf: element.items)
                            }
                        }
                    }else{//如果数据来源不存在已有月份，则插入新数据到新月份中
                        dataArray.append(element)
                    }
                }
                //重置数据
                self.currentDataArray = dataArray
                self.getStateData()
                self.tableView.reloadData()
                self.hideLoadingView()
            }

        } failureCallback: { (code, error) in
            if self.currentDataArray?.count == 0 || self.currentDataArray == nil {
                self.emptyView.isHidden = false
            }else{
                self.emptyView.isHidden = true
            }
            self.tableView.reloadData()
            self.showToast(string: error)
            self.hideLoadingView()
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
        }

    }
    
    @objc private func reload(){
        currentDataArray = nil
        currentPage = 0
        isGetAllData = false
        reloadRequest()
    }
    
    @objc private func loadNextData() {
        if isGetAllData {
            return
        }
        currentPage += 40
        reloadRequest()
    }
    

}


extension HistoryViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = currentDataArray?.count ?? 0
        
        return count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view = UIView()
        view.backgroundColor = .custom(.gray_f1f4fd)
        view.frame = CGRect(x: ZTScaleValue(15.0), y: 0, width: Screen.screenWidth - ZTScaleValue(30.0), height: ZTScaleValue(53.0))
        let lable = UILabel()
        lable.font = .font(size: ZTScaleValue(19.0))
        if currentDataArray != nil {
            let model = currentDataArray![section]
            let monthStr = model.date.components(separatedBy: "-").last
            lable.attributedText = String.attributedStringWith(monthStr ?? "",.font(size: ZTScaleValue(24.0), type: .bold),"月",.font(size: ZTScaleValue(13.0), type: .bold))
        }
        lable.textColor = .custom(.black_3f4663)
        lable.backgroundColor = .clear
        lable.frame = view.frame
        view.addSubview(lable)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //全部折叠时高度
        var row_height = CGFloat(currentDataArray?[indexPath.section].items.count ?? 0) * ZTScaleValue(80)+ZTScaleValue(20)

        
        let states = stateArray
        states?.forEach(){
            if $0.section == indexPath.section{//判断分区状态
                    if $0.isOpen {
                        row_height += $0.openHeight - ZTScaleValue(10)
                    }
            }
        }
        return row_height
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ZTScaleValue(50.0)
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentDataArray != nil {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryFirstCell.reusableIdentifier, for: indexPath) as! HistoryFirstCell
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        cell.tag = indexPath.section + 1
        if currentDataArray != nil {
            let model = currentDataArray![indexPath.section]
            cell.currentModelArray = model.items
        }
        cell.callback = { [weak self] section, tag , isOpen in
            print("section : \(section)\ntag : \(tag)\nisOpen:\(isOpen)\n")
            self?.stateArray?.forEach(){
                if section == $0.section{//
                    if tag == $0.row {
                        $0.isOpen = isOpen
                        //刷新页面高度
                        DispatchQueue.main.async {
                            tableView.reloadData()
                        }
                    }
                }
            }
        }
        return cell
    }
}

class historyStateModel: NSObject {
    //第一个分区
    var section = 0
    //分区第几个场景
    var row = 0
    /// 是否展开状态
    var isOpen = false
    ///展开开度
    var openHeight:CGFloat = 0.0

}

