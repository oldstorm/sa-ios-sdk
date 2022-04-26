//
//  DoorLockValidationViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/4/19.
//

import Foundation
import JXSegmentedView


class DoorLockValidationViewController: BaseViewController {
    
    private lazy var tipsView = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        let label = Label()
        label.text = "以下验证方式已在门锁本地添加但未绑定到用户，请绑定".localizedString
        label.textColor = .custom(.gray_94a5be)
        label.font = .font(size: 11, type: .regular)
        $0.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
    }
    
    private var segmentedDataSource: JXSegmentedTitleDataSource!
    private var segmentedView: JXSegmentedView!
    private var listContainerView: JXSegmentedListContainerView!
    private lazy var subVCs = [DoorLockValidationSubViewController]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "验证方式".localizedString
    }
    
    override func setupViews() {
        
    }

    override func setupConstraints() {
        
    }
    
    /// 初始化SegmentView
    private func setupSegmentDataSource() {
        let titles = DoorLockUserType.allCases.map(\.title)
        let vcs = DoorLockUserType.allCases.map { DoorLockValidationSubViewController(userType: $0) }
        subVCs = vcs

        //配置数据源
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.titles = titles
        dataSource.titleNormalColor = .custom(.gray_94a5be)
        dataSource.titleSelectedColor = .custom(.black_3f4663)
        dataSource.titleNormalFont = .font(size: ZTScaleValue(14.0), type: .bold)
        dataSource.isItemSpacingAverageEnabled = false
        segmentedDataSource = dataSource
        //配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.verticalOffset = 10
        indicator.indicatorWidthIncrement = -10
        indicator.indicatorColor = .custom(.blue_2da3f6)
        
        
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        segmentedView = JXSegmentedView()
        segmentedView!.indicators = [indicator]
        
        segmentedView!.dataSource = segmentedDataSource
        segmentedView!.delegate = self
        
        
        listContainerView = JXSegmentedListContainerView(dataSource: self)
        
        
        segmentedView.listContainer = listContainerView
        
        view.addSubview(segmentedView)
        view.addSubview(listContainerView)
        
        segmentedView.snp.makeConstraints {
            $0.top.equalTo(tipsView.snp.bottom)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        listContainerView.snp.makeConstraints {
            $0.top.equalTo(segmentedView.snp.bottom)
            $0.height.equalTo(view.bounds.height - Screen.k_nav_height)
            $0.left.right.bottom.equalToSuperview()
        }
    }


}

extension DoorLockValidationViewController: JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView?.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {

        let vc = subVCs[index]
        return vc
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let dotDataSource = segmentedDataSource as? JXSegmentedDotDataSource {
            //update the datasource first
            dotDataSource.dotStates[index] = false
            //then reloadItem(at: index)
            segmentedView.reloadItem(at: index)
        }
    }
    
    func scrollViewClass(in listContainerView: JXSegmentedListContainerView) -> AnyClass {
        return CustomScrollView.self
    }
}
