//
//  ViewController.swift
//  ZhiTing
//
//  Created by zy on 2022/2/24.
//

import UIKit
import JXSegmentedView

class SceneSubViewController: BaseViewController {

    var sceneType = SceneType.manual
    var dataSource = [SceneTypeModel]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var refreshDatasCallback: (() -> ())?
    var endEditCallBack: (() -> ())?
    
    /// 是否可以滚动
    var canScroll = true

    var superCanScrollCallback: ((Bool) -> ())?
    
    
    lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.estimatedSectionHeaderHeight = 10
        $0.estimatedSectionFooterHeight = 0
        $0.sectionFooterHeight = 0
        $0.separatorStyle = .none
        $0.contentInset.bottom = ZTScaleValue(10)
        $0.alwaysBounceVertical = true
        $0.alwaysBounceHorizontal = false
        /// 添加三行,阻止tableView.reload方法后的闪动效果
        $0.estimatedRowHeight = 0

        //场景Cell
        $0.register(SceneCell.self, forCellReuseIdentifier: SceneCell.reusableIdentifier)
        
        //拖拽代理
        $0.dragDelegate = self
        $0.dropDelegate = self
        /// 程序内拖拽功能开启,默认ipad为true,iphone为false
        $0.dragInteractionEnabled = false
        /// 系统自动调整scrollView.contentInset保证滚动视图不被tabbar,navigationbar遮挡
        $0.contentInsetAdjustmentBehavior = .scrollableAxes
    }

    var isEditingCell = false {
        didSet {
            if isEditingCell {
                tableView.mj_header?.removeFromSuperview()
                tableView.dragInteractionEnabled = true
            } else {
                let header = ZTGIFRefreshHeader()
                tableView.mj_header = header
                tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(reloadAll))
                tableView.dragInteractionEnabled = false
            }
            tableView.reloadData()
        }
    }
    
    /// 为cell注册拖拽方法
    private func dragCell(cell:UITableViewCell?) {
        /// 当cell在拖拽过程中是否允许交互
        cell?.userInteractionEnabledWhileDragging = false
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endEditCallBack?()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .custom(.gray_f6f8fd)
        // Do any additional setup after loading the view.
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(reloadAll))
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-15)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Screen.tabbarHeight).priority(.high)
        }
    }
    
}

extension SceneSubViewController {
    
    //更新当前排序
    public func updateSceneSort(){
        let sceneIds = dataSource.map(\.id)
        ApiServiceManager.shared.setSceneSort(sceneIds: sceneIds) { response in
            self.showToast(string: "排序成功")
        } failureCallback: { code, err in
            self.showToast(string: err)
        }
    }
    
    @objc private func reloadAll(){
        refreshDatasCallback?()
    }
    
    private func countCellHeight(scene: SceneTypeModel) -> CGFloat{
        var baseHeight = ZTScaleValue(75)
        //计算collection 高度
        var collectionHeight = ZTScaleValue(40)
        let rowSpereterHeight = ZTScaleValue(10)
        var row = 0
        if sceneType == .manual {
            //计算collection 高度
            row = scene.items.count / 6
            if scene.items.count % 4 != 0 {
                row += 1
            }
        }else{
            row = scene.items.count / 5
            if scene.items.count % 4 != 0 {
                row += 1
            }
        }
        
        if row == 0 {
            row = 1
        }
        collectionHeight = collectionHeight*CGFloat(row) + CGFloat((row - 1))*rowSpereterHeight
        baseHeight += collectionHeight
        return baseHeight
    }
}

extension SceneSubViewController: UITableViewDelegate, UITableViewDataSource{
        
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return countCellHeight(scene: dataSource[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SceneCell.reusableIdentifier, for: indexPath) as! SceneCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        cell.setModelAndTypeWith(model: dataSource[indexPath.row], type: sceneType)
        cell.updateViews(isEditing: isEditingCell)
        cell.executiveCallback = {[weak self] result in
            guard let self = self else {
                return
            }
            //提示执行结果
            self.showToast(string: result)
            //重新刷新列表，更新执行后状态
//            self.reloadAll()
        }
        dragCell(cell: cell)

        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if isEditingCell {
            return
        }
        
        let scene_id = dataSource[indexPath.row].id
        //权限判断
        if !authManager.currentRolePermissions.update_scene {//无执行权限
            self.showToast(string: "暂无修改场景权限")
            return
        }
        let vc = EditSceneViewController(type: .edit)
        vc.scene_id = scene_id
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
                
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            if !canScroll {
                if scrollView.contentOffset.y > 0 {
                    scrollView.contentOffset.y = 0
                }
            } else {
                if scrollView.contentOffset.y <= 0 {
                    canScroll = false
                    superCanScrollCallback?(true)
                }
            }
        }

    }
}

// MARK: - UITableView ios11以上拖拽drag,dropDelegate
extension SceneSubViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    /***
     *  iOS11以上版本,实现UITableViewDragDelegate,UITableViewDropDelegate代理方法,使用原生方式实现拖拽功能.
     */
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = UIDragItem(itemProvider: NSItemProvider(object: UIImage()))
        return [item]
    }
    // MARK: UITableViewDropDelegate
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {

    }
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        // Only receive image data
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    /// 这是UITableViewDataSourceDelegate中的方法,但是只有iOS11以上版本拖拽中才用的到,方便查看放在这里.
    /// 当拖拽完成时调用.将tableView数据源更新
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        objc_sync_enter(self)
        let model = dataSource[sourceIndexPath.row]
        dataSource.remove(at: sourceIndexPath.row)
        if destinationIndexPath.row > dataSource.count {
            dataSource.append(model)
        } else {
            dataSource.insert(model, at: destinationIndexPath.row)
        }
        objc_sync_exit(self)
        tableView.reloadData()
    }
}



extension SceneSubViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

