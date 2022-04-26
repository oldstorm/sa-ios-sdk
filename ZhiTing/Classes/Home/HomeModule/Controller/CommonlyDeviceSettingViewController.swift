//
//  CommonlyDeviceSettingViewController.swift
//  ZhiTing
//
//  Created by zy on 2022/4/2.
//

import UIKit
import CryptoSwift
import SwiftUI

class CommonlyDeviceSettingViewController: BaseViewController {
    //初始数据
    private var originalCommonlyDatas:  [Device]?//初始常用数据 
    private var originalUncommonlyDatas: [Device]?//初始非常用数据
    //编辑后数据
    private var editedCommonlyDatas:  [Device]?//初始常用数据
    private var editedUncommonlyDatas: [Device]?//初始非常用数据

    private var commonlyTableIsFolded = false
    private var uncommonlyTableIsFolded = false

    //常用设备列表
    lazy var commonlyTableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        if #available(iOS 15.0, *) {
            $0.sectionHeaderTopPadding = 0
        }
        //创建Cell
        $0.register(CommonlySettingCell.self, forCellReuseIdentifier: CommonlySettingCell.reusableIdentifier)
    }
    //非常用设备列表
    lazy var uncommonlyTableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.alwaysBounceVertical = false
        if #available(iOS 15.0, *) {
            $0.sectionHeaderTopPadding = 0
        }
        //创建Cell
        $0.register(CommonlySettingCell.self, forCellReuseIdentifier: CommonlySettingCell.reusableIdentifier)
    }
    
    lazy var saveButton = CustomButton(buttonType:
                                                    .leftLoadingRightTitle(
                                                        normalModel:
                                                            .init(
                                                                title: "保存".localizedString,
                                                                titleColor: UIColor.custom(.white_ffffff).withAlphaComponent(1),
                                                                font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                                backgroundColor: UIColor.custom(.blue_2da3f6).withAlphaComponent(1)
                                                            ),
                                                        lodingModel:
                                                            .init(
                                                                title: "保存中...".localizedString,
                                                                titleColor: UIColor.custom(.white_ffffff).withAlphaComponent(0.7),
                                                                font: UIFont.font(size: ZTScaleValue(14), type: .bold),
                                                                backgroundColor: UIColor.custom(.blue_2da3f6).withAlphaComponent(0.7)
                                                            )
                                                    )
    ).then {
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.setTitleColor(.custom(.white_ffffff), for: .disabled)
        $0.addTarget(self, action: #selector(onClickDone), for: .touchUpInside)
    }

    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .custom(.gray_f6f8fd)
        // Do any additional setup after loading the view.
        Task {
            await getDeviceDatas()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "常用设备设置".localizedString
        navigationController?.setNavigationBarHidden(false, animated: true)
        showLoadingView()
    }
    
    // MARK: - layout
    
    override func setupViews() {
        view.addSubview(uncommonlyTableView)
        view.addSubview(commonlyTableView)
    }
    
    override func setupConstraints() {
        uncommonlyTableView.snp.makeConstraints {
            $0.top.equalTo(ZTScaleValue(10) + Screen.k_nav_height)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(51))
        }
        
        commonlyTableView.snp.makeConstraints {
            $0.top.equalTo(uncommonlyTableView.snp.bottom).offset(ZTScaleValue(10))
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(51))
        }

    }
    
    @objc private func onClickDone(){
        saveButton.selectedChangeView(isLoading: true)
        saveButton.selectedChangeView(isLoading: false)
    }
    
    private func creatHeaderView(isCommonly: Bool) -> UIButton {
        
        let isFolded = isCommonly ? commonlyTableIsFolded : uncommonlyTableIsFolded
        
        let button = UIButton.init(type: .custom)
        button.backgroundColor = .custom(.white_ffffff)
        button.tag = isCommonly ? 0 : 1
        //标题
        let title = UILabel()
        title.font = .font(size: ZTScaleValue(16), type: .bold)
        title.textColor = .custom(.black_3f4663)
        title.text = isCommonly ? "常用的设备".localizedString : "非常用的设备".localizedString
        title.numberOfLines = 0
        button.addSubview(title)
        //添加约束

        //箭头
        let arrowIcon = UIImageView()
        if isFolded {//折叠
            arrowIcon.image = .assets(.arrow_down)
        }else{
            arrowIcon.image = .assets(.arrow_up)
        }
        button.addSubview(arrowIcon)
        
        
        title.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.left.equalTo(ZTScaleValue(14))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(100))

        }
        arrowIcon.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(13.5))
            $0.height.equalTo(ZTScaleValue(8.0))
        }
                
        button.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        return button
        
    }

    @objc private func buttonPress(sender: UIButton){
        switch sender.tag {
        case 0://常用
            commonlyTableIsFolded = !commonlyTableIsFolded
            commonlyTableView.reloadData()
            countTableViewHeight()

        case 1://非常用
            uncommonlyTableIsFolded = !uncommonlyTableIsFolded
            uncommonlyTableView.reloadData()
            countTableViewHeight()
        default:
            break
        }
    }
    
    @MainActor
    private func getDeviceDatas() async{
        do {
            let currentArea = AuthManager.shared.currentArea
            let devices = try await AsyncApiService.deviceList(area: currentArea)
            hideLoadingView()
            self.originalUncommonlyDatas = devices
            self.editedUncommonlyDatas = originalUncommonlyDatas
            self.uncommonlyTableView.reloadData()
            self.commonlyTableView.reloadData()
            self.countTableViewHeight()
        }catch{
            self.countTableViewHeight()
            self.uncommonlyTableView.reloadData()
            self.commonlyTableView.reloadData()
        }
    }
    
    private func countTableViewHeight() {
        
        var commonlyHeight = ZTScaleValue(51)
        if editedCommonlyDatas != nil && editedCommonlyDatas?.count != 0{
            if !commonlyTableIsFolded {//未折叠
                commonlyHeight += CGFloat(editedCommonlyDatas?.count ?? 0) * ZTScaleValue(70)
            }
        }
        
        var uncommonlyHeight = ZTScaleValue(51)
        if editedUncommonlyDatas != nil && editedUncommonlyDatas?.count != 0{
            if !uncommonlyTableIsFolded {//未折叠
                uncommonlyHeight += CGFloat(editedUncommonlyDatas?.count ?? 0) * ZTScaleValue(70)
            }
        }
        
        if uncommonlyHeight > view.bounds.height {
            uncommonlyHeight = view.bounds.height
        }
        uncommonlyTableView.snp.remakeConstraints {
            $0.top.equalTo(ZTScaleValue(10) + Screen.k_nav_height)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(uncommonlyHeight)
        }
        
        if commonlyHeight > view.bounds.height {
            commonlyHeight = view.bounds.height
        }
        commonlyTableView.snp.remakeConstraints {
            $0.top.equalTo(uncommonlyTableView.snp.bottom).offset(ZTScaleValue(10))
            $0.left.right.equalToSuperview()
            $0.height.equalTo(commonlyHeight)
        }

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let height = (change![.newKey] as? CGSize)?.height  else {
                return
            }
            
            if object as? UITableView == uncommonlyTableView {
                uncommonlyTableView.snp.remakeConstraints {
                    $0.top.equalTo(ZTScaleValue(10))
                    $0.left.right.equalToSuperview()
                    $0.height.equalTo(height)
                }

            }else if object as? UITableView == commonlyTableView {
                commonlyTableView.snp.remakeConstraints {
                    $0.top.equalTo(uncommonlyTableView.snp.bottom).offset(ZTScaleValue(10))
                    $0.left.right.equalToSuperview()
                    $0.height.equalTo(height)
                }
            }
        }
    }
}


extension CommonlyDeviceSettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ZTScaleValue(50)
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //构建分区头
        if tableView == uncommonlyTableView {//非常用
            return creatHeaderView(isCommonly: false)
        }else{
            return creatHeaderView(isCommonly: true)
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == uncommonlyTableView {//非常用
            if !uncommonlyTableIsFolded {
                guard let datas = editedUncommonlyDatas else {
                    return 0
                }
                return datas.count
            }else{
                return 0
            }
        }else{//常用
            if !commonlyTableIsFolded {
                guard let datas = editedCommonlyDatas else {
                    return 0
                }
                return datas.count
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(70)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommonlySettingCell.reusableIdentifier, for: indexPath) as! CommonlySettingCell
        var model = Device()
        if tableView == uncommonlyTableView {//非常用
            model = editedUncommonlyDatas?[indexPath.row] ?? Device()
            cell.executiveBtn.setImage(.assets(.commonly_Add), for: .normal)
            cell.executiveCallback = {[weak self] in
                guard let device = self?.editedUncommonlyDatas?[indexPath.row] else {
                    return
                }
                self?.editedUncommonlyDatas?.remove(at: indexPath.row)
                if self?.editedCommonlyDatas == nil {
                    self?.editedCommonlyDatas = [device]
                }else{
                    self?.editedCommonlyDatas?.append(device)
                }
                
                self?.countTableViewHeight()
                self?.uncommonlyTableView.reloadData()
                self?.commonlyTableView.reloadData()
            }
        }else{
            model = editedCommonlyDatas?[indexPath.row] ?? Device()
            cell.executiveBtn.setImage(.assets(.commonly_Delete), for: .normal)
            cell.executiveCallback = {[weak self] in
                guard let device = self?.editedCommonlyDatas?[indexPath.row] else {
                    return
                }
                self?.editedCommonlyDatas?.remove(at: indexPath.row)
                self?.editedUncommonlyDatas?.append(device)
                self?.countTableViewHeight()
                self?.uncommonlyTableView.reloadData()
                self?.commonlyTableView.reloadData()
            }
        }
        cell.selectionStyle = .none
        cell.title.text = model.name
        cell.iconImgView.setImage(urlString: model.logo_url, placeHolder: .assets(.default_device))
        return cell
    }
}
