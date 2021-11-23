//
//  BrandMainViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/4.
//

import UIKit
import JXSegmentedView


class BrandMainViewController: BaseViewController {
    private var segmentedDataSource: JXSegmentedTitleDataSource?
    private var segmentedView: JXSegmentedView?
    private var listContainerView: JXSegmentedListContainerView?
    
    private lazy var systemVC = BrandSystemViewController()
    private lazy var creationVC = BrandCreationViewController()

    private lazy var backBtn: Button = {
        let btn = Button()
        btn.frame.size = CGSize.init(width: 30, height: 30)
        btn.setImage(.assets(.navigation_back), for: .normal)
        btn.addTarget(self, action: #selector(navPop), for: .touchUpInside)
        btn.contentHorizontalAlignment = .left
        btn.isEnhanceClick = true
        return btn
    }()

    private lazy var searchBtn = Button().then {
        $0.imageView?.contentMode = .scaleAspectFit
        $0.setImage(.assets(.search_bold), for: .normal)
        $0.isEnhanceClick = true
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    
    override func setupViews() {
        /// segments
        let titles = ["系统".localizedString, "创作".localizedString]
        //配置数据源
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.titles = titles
        dataSource.titleNormalColor = .custom(.gray_94a5be)
        dataSource.titleSelectedColor = .custom(.black_3f4663)
        dataSource.titleNormalFont = .font(size: ZTScaleValue(16.0), type: .bold)
        dataSource.isItemSpacingAverageEnabled = true
        
        segmentedDataSource = dataSource
        //配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.verticalOffset = 5
        indicator.indicatorWidthIncrement = -10
        indicator.indicatorColor = .custom(.blue_2da3f6)
        
        
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        segmentedView = JXSegmentedView()
        segmentedView?.indicators = [indicator]
        
        segmentedView?.dataSource = segmentedDataSource
        segmentedView?.delegate = self
        
        
        listContainerView = JXSegmentedListContainerView(dataSource: self)
        
        segmentedView?.listContainer = listContainerView
        
        /// callbacks
        searchBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            if self.segmentedView?.selectedIndex == 0 { /// 搜索系统
                let vc = BrandSystemSearchViewController()
                vc.selectCallback = { [weak self] name in
                    guard let self = self else { return }
                    let vc = BrandDetailViewController()
                    vc.brand_name = name
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            } else { /// 搜索创作
                let vc = BrandCreationSearchViewController()
                vc.selectCallback = { [weak self] plugin in
                    guard let self = self else { return }
                    let vc = PluginDetailViewController()
                    vc.isSys = false
                    vc.pluginId = plugin.id
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            
        }

        
        
        if let segmentedView = segmentedView, let listContainerView = listContainerView {
            view.addSubview(listContainerView)
            view.addSubview(segmentedView)
            view.addSubview(line)
            view.addSubview(backBtn)
            view.addSubview(searchBtn)


            segmentedView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(Screen.statusBarHeight)
                $0.width.equalTo(Screen.screenWidth * 2 / 3)
                $0.height.equalTo(Screen.k_nav_height - Screen.statusBarHeight)
                $0.centerX.equalToSuperview()
            }
            
            line.snp.makeConstraints {
                $0.left.right.equalToSuperview()
                $0.height.equalTo(0.5)
                $0.top.equalToSuperview().offset(Screen.k_nav_height + 5)
            }

            backBtn.snp.makeConstraints {
                $0.centerY.equalTo(segmentedView.snp.centerY)
                $0.width.equalTo(8)
                $0.height.equalTo(14)
                $0.left.equalToSuperview().offset(15)
            }

            searchBtn.snp.makeConstraints {
                $0.centerY.equalTo(segmentedView.snp.centerY)
                $0.height.width.equalTo(14)
                $0.right.equalToSuperview().offset(-18)
            }
            
            listContainerView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(Screen.k_nav_height + 5)
                $0.left.right.bottom.equalToSuperview()
            }
            
            
        }
        
    }

}

extension BrandMainViewController: JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView?.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if index == 0 {
            return systemVC
        } else {
            return creationVC
        }
        
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let dotDataSource = segmentedDataSource as? JXSegmentedDotDataSource {
            //update the datasource first
            dotDataSource.dotStates[index] = false
            //then reloadItem(at: index)
            segmentedView.reloadItem(at: index)
        }
    }
}

