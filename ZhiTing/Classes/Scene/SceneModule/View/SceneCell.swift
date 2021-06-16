//
//  SceneCell.swift
//  ZhiTing
//
//  Created by zy on 2021/4/12.
//

import UIKit

enum SceneCellType {
    case manual
    case auto_run
}

class SceneCell: UITableViewCell,ReusableView {
    
    var selectCallback: ((_ isOn: Bool, _ isAuto: Bool) -> ())?
    
    var dependency: AppDependency {
        return (UIApplication.shared.delegate as! AppDelegate).appDependency
          }

    var authManager: AuthManager {
        return dependency.authManager
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var currentSceneModel : SceneTypeModel?
    
    public func setModelAndTypeWith(model: SceneTypeModel, type: SceneCellType) {
        currentSceneModel = model
        title.text = currentSceneModel?.name
        switch type {
        case .auto_run:
            setupAutoView()
        case .manual:
            setupManualView()
        }
        //点击执行开关
        executiveBtn.clickCallBack = {[weak self] _ in
            guard let self = self  else {return}
            self.selectCallback!(true, false)
        }

        deviceCollectionView.reloadData()
    }
    
    
    lazy var bgView = UIView().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(10.0)
        $0.layer.masksToBounds = true
    }

    
    lazy var title = Label().then {
        $0.text = "".localizedString
        $0.font = .font(size: ZTScaleValue(17.0), type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.lineBreakMode = .byCharWrapping
        $0.numberOfLines = 0
    }
    
    //执行按钮
    lazy var executiveBtn = Button().then {
        $0.setTitle(" ", for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.backgroundColor = .custom(.gray_f1f4fd)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.layer.cornerRadius = ZTScaleValue(4.0)
        $0.layer.masksToBounds = true
    }
    
    //开关
    lazy var autoSwitch = UISwitch().then {
        $0.onTintColor = .custom(.blue_2da3f6)
        $0.isOn = false
        $0.addTarget(self, action: #selector(switchValueChange(sender:)), for: .valueChanged)
    }
    
    lazy var noPermissionsBtn = Button().then {
        $0.backgroundColor = .clear
        $0.isHidden = true
        $0.clickCallBack = { _ in
            SceneDelegate.shared.window?.makeToast("暂无控制权限")
        }
    }
    
    //是否定时操作
    lazy var statusIcon = ImageView().then {
        $0.image = .assets(.scene_time)
        $0.layer.borderWidth = ZTScaleValue(0.5)
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.layer.cornerRadius = ZTScaleValue(4.0)
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFit
    }
    
    //状态Label
    lazy var stateLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(10))
        $0.textColor = .custom(.white_ffffff)
        $0.textAlignment = .center
        $0.backgroundColor = .custom(.black_3f4663)
        $0.alpha = 0.8
    }

    
    //连接icon
    lazy var connectIcon = ImageView().then {
        $0.image = .assets(.scene_connect)
    }
    
    //设备列表
    
    private lazy var flowLayout = UICollectionViewFlowLayout().then {
        $0.itemSize = CGSize(width: ZTScaleValue(40.0), height:  ZTScaleValue(40.0))
        //行列间距
        $0.minimumLineSpacing = ZTScaleValue(10)
        $0.minimumInteritemSpacing = ZTScaleValue(5)
        
    }
    lazy var deviceCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then{
        $0.backgroundColor = .clear
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.alwaysBounceHorizontal = false
        $0.isUserInteractionEnabled = false
        $0.register(SceneCollectDeviceCell.self, forCellWithReuseIdentifier: SceneCollectDeviceCell.reusableIdentifier)
    }

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func switchValueChange(sender:UISwitch){
        let openStatus = sender.isOn
        selectCallback!(openStatus, true)
    }
    
    private func setupManualView(){//设置手动样式
        contentView.addSubview(bgView)
        bgView.addSubview(title)
        bgView.addSubview(executiveBtn)
        bgView.addSubview(deviceCollectionView)
        bgView.addSubview(noPermissionsBtn)
        
        //权限判断
        if !authManager.currentRolePermissions.control_scene {//无执行权限
            executiveBtn.backgroundColor = .custom(.gray_cfd6e0)
            executiveBtn.setTitleColor(.custom(.white_ffffff), for: .normal)
            executiveBtn.isUserInteractionEnabled = false
            executiveBtn.alpha = 0.5
            noPermissionsBtn.isHidden = false
            bgView.bringSubviewToFront(noPermissionsBtn)
        }else{
            if !(currentSceneModel?.control_permission ?? false) {//无执行权限
                executiveBtn.backgroundColor = .custom(.gray_cfd6e0)
                executiveBtn.setTitleColor(.custom(.white_ffffff), for: .normal)
                executiveBtn.isUserInteractionEnabled = false
                executiveBtn.alpha = 0.5
                noPermissionsBtn.isHidden = false
                bgView.bringSubviewToFront(noPermissionsBtn)
            }else{
                executiveBtn.setTitleColor(.custom(.blue_2da3f6), for: .normal)
                executiveBtn.backgroundColor = .custom(.gray_f1f4fd)
                executiveBtn.isUserInteractionEnabled = true
                executiveBtn.alpha = 1
                noPermissionsBtn.isHidden = true
                bgView.bringSubviewToFront(executiveBtn)
            }
        }
        
        bgView.snp.makeConstraints{
            $0.top.equalToSuperview().offset(ZTScaleValue(10.0)).priority(.high)
            $0.left.equalToSuperview().offset(ZTScaleValue(15.0)).priority(.high)
            $0.right.equalTo(-ZTScaleValue(15.0)).priority(.high)
            $0.bottom.equalToSuperview().priority(.high)
        }

        title.snp.makeConstraints{
            $0.left.equalTo(ZTScaleValue(15.0))
            $0.top.equalTo(ZTScaleValue(15))
            $0.right.equalTo(executiveBtn.snp.left).offset(-ZTScaleValue(20))
        }

        executiveBtn.setTitle("执行", for: .normal)
        executiveBtn.snp.makeConstraints{
                $0.right.equalTo(-ZTScaleValue(15.0))
                $0.centerY.equalTo(title)
                $0.width.equalTo(ZTScaleValue(70.0))
                $0.height.equalTo(ZTScaleValue(30.0))
            }
        
        noPermissionsBtn.snp.makeConstraints {
            $0.edges.equalTo(executiveBtn)
        }
        
            //计算collection 高度
            var height = ZTScaleValue(40)
            let rowSpereterHeight = ZTScaleValue(10)
            var row = (currentSceneModel?.items.count ?? 0) / 6
            if (currentSceneModel?.items.count ?? 0) % 4 != 0 {
                row += 1
            }
            height = height*CGFloat(row) + CGFloat((row - 1))*rowSpereterHeight


            deviceCollectionView.snp.makeConstraints{
                $0.top.equalTo(title.snp.bottom).offset(ZTScaleValue(10))
                $0.left.equalTo(ZTScaleValue(15.0))
                $0.right.equalTo(-ZTScaleValue(15.0))
                $0.height.equalTo(height)
                $0.bottom.equalTo(-ZTScaleValue(15.0))
            }
    }
    
    private func setupAutoView(){//设置自动样式
        contentView.addSubview(bgView)
        bgView.addSubview(title)
        bgView.addSubview(autoSwitch)
        bgView.addSubview(statusIcon)
        bgView.addSubview(connectIcon)
        bgView.addSubview(deviceCollectionView)
        statusIcon.addSubview(stateLabel)
        bgView.addSubview(noPermissionsBtn)
                
        autoSwitch.isOn = currentSceneModel?.is_on ?? false
        
        if currentSceneModel?.condition.status == 1 {
            stateLabel.isHidden = true
        }else{
            stateLabel.isHidden = false
            switch currentSceneModel?.condition.status {
            case 2://已删除
                stateLabel.text = "已删除"
            case 3://离线
                stateLabel.text = "离线"
            default:
                stateLabel.isHidden = true
            }
        }

        stateLabel.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(15.0))
        }
        
        //权限判断
        if !authManager.currentRolePermissions.control_scene {//无执行权限
            autoSwitch.onTintColor = .custom(.gray_cfd6e0)
            autoSwitch.alpha = 0.5
            autoSwitch.isUserInteractionEnabled = false
            noPermissionsBtn.isHidden = false
            bgView.bringSubviewToFront(noPermissionsBtn)
        }else{
            if !(currentSceneModel?.control_permission ?? false) {//无执行权限
                autoSwitch.onTintColor = .custom(.gray_cfd6e0)
                autoSwitch.alpha = 0.5
                autoSwitch.isUserInteractionEnabled = false
                noPermissionsBtn.isHidden = false
                bgView.bringSubviewToFront(noPermissionsBtn)
            }else{
                autoSwitch.onTintColor = .custom(.blue_2da3f6)
                autoSwitch.alpha = 1
                autoSwitch.isUserInteractionEnabled = true
                noPermissionsBtn.isHidden = true
                bgView.bringSubviewToFront(autoSwitch)
            }
        }
        if currentSceneModel?.condition.type == 1 {//定时
            statusIcon.image = .assets(.scene_time)
        }else if currentSceneModel?.condition.type == 2{//设备
            if currentSceneModel?.condition.logo_url != nil {
                statusIcon.setImage(urlString: (currentSceneModel?.condition.logo_url)!, placeHolder: .assets(.icon_condition_state))
            }else{
                statusIcon.image = .assets(.icon_condition_state)
            }
        }
        
        bgView.snp.makeConstraints{
            $0.top.equalToSuperview().offset(ZTScaleValue(10.0)).priority(.high)
            $0.left.equalToSuperview().offset(ZTScaleValue(15.0)).priority(.high)
            $0.right.equalTo(-ZTScaleValue(15.0)).priority(.high)
            $0.bottom.equalToSuperview().priority(.high)
        }

        title.snp.makeConstraints{
            $0.left.equalTo(ZTScaleValue(15.0))
            $0.top.equalTo(ZTScaleValue(15))
            $0.right.equalTo(autoSwitch.snp.left).offset(-ZTScaleValue(20))
        }

            //添加开关约束
        autoSwitch.snp.makeConstraints{
            $0.right.equalTo(-ZTScaleValue(15.0))
            $0.centerY.equalTo(title).offset(-ZTScaleValue(5))
            $0.width.equalTo(ZTScaleValue(35.0))
            $0.height.equalTo(ZTScaleValue(18.0))
            }
        
        noPermissionsBtn.snp.makeConstraints {
            $0.edges.equalTo(autoSwitch)
        }
            //添加状态约束
        statusIcon.snp.makeConstraints{
            $0.top.equalTo(title.snp.bottom).offset(ZTScaleValue(20))
            $0.left.equalTo(ZTScaleValue(15.0))
            $0.width.equalTo(ZTScaleValue(40.0))
            $0.height.equalTo(ZTScaleValue(40.0))
        }
        //添加连接icon约束
        connectIcon.snp.makeConstraints{
            $0.left.equalTo(statusIcon.snp.right).offset(ZTScaleValue(10.0))
            $0.width.equalTo(ZTScaleValue(16.0))
            $0.centerY.equalTo(statusIcon)
            $0.height.equalTo(ZTScaleValue(8.0))
        }
        
        //计算collection 高度
        var height = ZTScaleValue(40)
        let rowSpereterHeight = ZTScaleValue(10)
        var row = (currentSceneModel?.items.count ?? 0) / 5
        if (currentSceneModel?.items.count ?? 0) % 4 != 0 {
            row += 1
        }
        height = height*CGFloat(row) + CGFloat((row - 1))*rowSpereterHeight
        //添加设备列表约束
        deviceCollectionView.snp.makeConstraints{
            $0.top.equalTo(statusIcon)
            $0.left.equalTo(connectIcon.snp.right).offset(ZTScaleValue(10.0))
            $0.right.equalTo(-ZTScaleValue(15.0))
            $0.height.equalTo(height)
            $0.bottom.equalTo(-ZTScaleValue(15.0))
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        executiveBtn.removeFromSuperview()
        autoSwitch.removeFromSuperview()
        statusIcon.removeFromSuperview()
        connectIcon.removeFromSuperview()
        deviceCollectionView.removeFromSuperview()
        stateLabel.removeFromSuperview()
        noPermissionsBtn.removeFromSuperview()
    }
}

extension SceneCell : UICollectionViewDelegate, UICollectionViewDataSource{
    //cell 数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentSceneModel?.items.count ?? 0
    }
    //cell 具体内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SceneCollectDeviceCell.reusableIdentifier, for: indexPath) as! SceneCollectDeviceCell
        cell.currentModel = currentSceneModel?.items[indexPath.item]
        return cell
    }
    
    
}
