//
//  SceneCollectDeviceCell.swift
//  ZhiTing
//
//  Created by zy on 2021/4/12.
//

import UIKit

class SceneCollectDeviceCell: UICollectionViewCell,ReusableView {
    
    //图标
    lazy var iconView = ImageView().then {
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
    
    var currentModel : SceneItemModel? {
        didSet{
            guard let model = currentModel else {
                return
            }
            if model.logo_url == "" {
                if model.type == 1 {
                    iconView.image = .assets(.default_device)
                }else{
                    iconView.image = .assets(.icon_control_scene)
                }
            }else{
                iconView.setImage(urlString: model.logo_url, placeHolder: .assets(.default_device))
            }
            
            if model.status == 1 {
                stateLabel.isHidden = true
            }else{
                stateLabel.isHidden = false
                switch model.status {
                case 2://已删除
                    stateLabel.text = "已删除"
                case 3://离线
                    stateLabel.text = "离线"
                default:
                    stateLabel.isHidden = true
                    iconView.image = .assets(.icon_control_scene)

                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        iconView.image = nil
        stateLabel.isHidden = true
    }
}

extension SceneCollectDeviceCell{
    func setupViews() {
        contentView.addSubview(iconView)
        iconView.addSubview(stateLabel)
    }
    
    func setConstrains(){
        iconView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        
        stateLabel.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(15.0))
        }
        
    }
}
