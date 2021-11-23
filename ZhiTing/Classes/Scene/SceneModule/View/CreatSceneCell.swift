//
//  CreatSceneCell.swift
//  ZhiTing
//
//  Created by mac on 2021/4/12.
//

import UIKit

class CreatSceneCell: UITableViewCell, ReusableView {

    enum CreatSceneCellType {
        case noAuth
        case normal
    }

    var creatSceneCellType: CreatSceneCellType = .normal {
        didSet {
            switch creatSceneCellType {
            case .noAuth:
                title.text = "智慧中心连接失败或者无权限".localizedString
                icon.image = .assets(.icon_noAuth)
                creatSceneBtn.isHidden = true
                reconnectBtn.isHidden = false
                
            case .normal:
                title.text = "暂无场景".localizedString
                icon.image = .assets(.noScene)
                creatSceneBtn.isHidden = false
                reconnectBtn.isHidden = true
                
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    lazy var bgView = UIView().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(10.0)
        $0.layer.masksToBounds = true
    }

    lazy var icon = ImageView().then {
        $0.image = .assets(.noScene)
    }
    
    lazy var title = Label().then {
        $0.text = "".localizedString
        $0.font = .font(size: ZTScaleValue(13.0), type: .medium)
        $0.textColor = .custom(.gray_94a5be)
    }

    lazy var creatSceneBtn = Button().then {
        $0.setTitle(" ", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.titleLabel?.font = .font(size: ZTScaleValue(13.0))
        $0.layer.cornerRadius = ZTScaleValue(4.0)
        $0.layer.masksToBounds = true
    }
    
    lazy var reconnectBtn = RefreshButton(style: .reconnect).then {
        $0.isHidden = false
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func setupViews() {
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(bgView)
        bgView.addSubview(icon)
        bgView.addSubview(title)
        bgView.addSubview(creatSceneBtn)
        bgView.addSubview(reconnectBtn)

        bgView.snp.makeConstraints{
            $0.left.equalTo(ZTScaleValue(15.0))
            $0.right.equalTo(-ZTScaleValue(15.0))
            $0.top.equalToSuperview().offset(ZTScaleValue(10))
            $0.bottom.equalToSuperview().offset(ZTScaleValue(-10))
        }
        
        icon.snp.makeConstraints {
            $0.width.equalTo(ZTScaleValue(100.0))
            $0.height.equalTo(ZTScaleValue(39.0))
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ZTScaleValue(35.0))
        }

        title.snp.remakeConstraints{
            $0.height.equalTo(ZTScaleValue(13.0))
            $0.centerX.equalToSuperview()
            $0.top.equalTo(icon.snp.bottom).offset(ZTScaleValue(7))
        }

        creatSceneBtn.snp.makeConstraints{
            $0.width.equalTo(ZTScaleValue(150.0))
            $0.height.equalTo(50.0)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(title.snp.bottom).offset(ZTScaleValue(23))
            $0.bottom.equalToSuperview().offset(ZTScaleValue(-38))
        }
        
        reconnectBtn.snp.makeConstraints{
            $0.edges.equalTo(creatSceneBtn)
        }
    }
    
}
