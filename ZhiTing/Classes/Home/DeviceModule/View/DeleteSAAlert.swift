//
//  DeleteSAAlert.swift
//  ZhiTing
//
//  Created by iMac on 2022/1/18.
//
import AttributedString
import UIKit

class DeleteSAAlert: UIView {
    var sureCallback: ((_ is_migration_sa: Bool, _ is_del_cloud_disk: Bool) -> ())?
    
    var cancelCallback: (() -> ())?
    
    var loginClick: (() -> ())?
    
    var isSureBtnLoading = false {
        didSet {
            sureBtn.selectedChangeView(isLoading: isSureBtnLoading)
        }
    }
    
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.3)
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.clipsToBounds = true
    }

    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private lazy var chooseButton = Button().then {
        $0.setImage(.assets(.unselected_tick), for: .normal)
        $0.setImage(.assets(.selected_tick_red), for: .selected)
        $0.addTarget(self, action: #selector(chooseButtonOnPress), for: .touchUpInside)
    }
    
    private lazy var chooseLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textAlignment = .left
        $0.textColor = .custom(.red_fe0000)
        $0.numberOfLines = 0
        $0.text = "同时创建云端家庭".localizedString
        $0.lineBreakMode = .byWordWrapping
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(chooseButtonOnPress)))
    }
    
    private lazy var chooseButton2 = Button().then {
        $0.setImage(.assets(.unselected_tick), for: .normal)
        $0.setImage(.assets(.selected_tick_red), for: .selected)
        $0.addTarget(self, action: #selector(chooseButtonOnPress2), for: .touchUpInside)
    }
    
    private lazy var chooseLabel2 = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textAlignment = .left
        $0.textColor = .custom(.red_fe0000)
        $0.text = "同时删除智汀云盘存储的文件".localizedString
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(chooseButtonOnPress2)))
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    @objc private func chooseButtonOnPress(){
        chooseButton.isSelected = !chooseButton.isSelected
    }
    
    @objc private func chooseButtonOnPress2(){
        chooseButton2.isSelected = !chooseButton2.isSelected
    }
    
    private lazy var sureBtn = CustomButton(buttonType:
                                                .centerTitleAndLoading(normalModel:
                                                                        .init(
                                                                            title: "确定".localizedString,
                                                                            titleColor: .custom(.blue_2da3f6),
                                                                            font: .font(size: ZTScaleValue(14), type: .bold),
                                                                            backgroundColor: .custom(.white_ffffff)
                                                                        )
                                                )).then {
                                                    $0.layer.borderWidth = 0.5
                                                    $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
                                                    $0.addTarget(self, action: #selector(onClickSure), for: .touchUpInside)
                                                }
    
    private lazy var cancelBtn = Button().then {
        $0.setTitle("取消".localizedString, for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.layer.borderWidth = ZTScaleValue(0.5)
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.cancelCallback?()
            self?.removeFromSuperview()
        }

        
    }

    @objc private func onClickSure() {
        sureCallback?(chooseButton.isSelected, chooseButton2.isSelected)
        removeFromSuperview()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init(frame: CGRect, attributedString: NSAttributedString,chooseString: String) {
        self.init(frame: frame)
        self.tipsLabel.attributedText = attributedString
        self.chooseLabel.text = chooseString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        container.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform.identity
        })
            
        
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        },completion: { isFinished in
            if isFinished {
                super.removeFromSuperview()
            }
            
        })
        
    }
    
    private func setupViews() {
        addSubview(cover)
        addSubview(container)
        container.addSubview(tipsLabel)
        container.addSubview(chooseButton)
        container.addSubview(chooseLabel)
        container.addSubview(chooseButton2)
        container.addSubview(chooseLabel2)
        container.addSubview(line)
        container.addSubview(sureBtn)
        container.addSubview(cancelBtn)
        
    }

    private func setConstrains() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - ZTScaleValue(75))
        }
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        chooseButton.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(30)
            $0.left.equalTo(ZTScaleValue(23.5))
            $0.width.height.equalTo(23)
        }
        
        chooseLabel.snp.makeConstraints {
            $0.left.equalTo(chooseButton.snp.right).offset(ZTScaleValue(8.5))
            $0.top.equalTo(chooseButton)
            $0.right.equalTo(-ZTScaleValue(23.5))
        }
        
        chooseButton2.snp.makeConstraints {
            $0.top.equalTo(chooseLabel.snp.bottom).offset(10)
            $0.left.equalTo(ZTScaleValue(23.5))
            $0.width.height.equalTo(23)
        }
        
        chooseLabel2.snp.makeConstraints {
            $0.left.equalTo(chooseButton2.snp.right).offset(ZTScaleValue(8.5))
            $0.top.equalTo(chooseButton2)
            $0.right.equalTo(-ZTScaleValue(23.5))
        }
        
        line.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.top.equalTo(chooseLabel2.snp.bottom).offset(30)
        }
        
        sureBtn.snp.makeConstraints {
            $0.height.equalTo(ZTScaleValue(50))
            $0.right.equalToSuperview()
            $0.top.equalTo(line.snp.bottom)
            $0.width.equalTo((Screen.screenWidth - ZTScaleValue(75)) / 2)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.height.equalTo(ZTScaleValue(50))
            $0.left.equalToSuperview()
            $0.top.equalTo(line.snp.bottom)
            $0.width.equalTo((Screen.screenWidth - ZTScaleValue(75)) / 2)
            $0.bottom.equalToSuperview()
        }
    }
    
    func setupDetail(isBindCloud: Bool, area: Area) {
        var attrStr = ASAttributedString("")
        let tipStr: ASAttributedString = .init(
            string: "提示\n\n".localizedString,
            with: [
                .font(.font(size: 16, type: .bold)),
                .foreground(.custom(.black_333333)),
                .paragraph(.alignment(.center))
            ])
        
        let areaType: String
        let deleteStr: String
        switch area.areaType {
        case .company:
            areaType = "公司".localizedString
            deleteStr = "解散".localizedString
        case .family:
            areaType = "家庭".localizedString
            deleteStr = "删除".localizedString
        }

        let detailStr: ASAttributedString = .init(
            string: "删除智慧中心将同时\(deleteStr.localizedString)\(areaType)“\(area.name)”，是否删除？\n",
            with: [
                .font(.font(size: 14, type: .bold)),
                .foreground(.custom(.black_333333)),
                .paragraph(.alignment(.left), .lineSpacing(5))
            ])
        
        attrStr += tipStr
        attrStr += detailStr
        
        if isBindCloud {
            let descriptionStr: ASAttributedString = .init(
                string: "你可以选择创建云端\(areaType)进行信息同步，同步的信息有：\n美汇智居设备、场景、\(area.areaType == .family ? "房间" : "部门")、角色和成员信息\n",
                with: [
                    .font(.font(size: 14, type: .regular)),
                    .foreground(.custom(.black_333333)),
                    .paragraph(.alignment(.left), .lineSpacing(5))
                ])
            
            let description2Str: ASAttributedString = .init(
                string: "\n*信息同步时请保证智慧中心的网络状态正常，避免网络异常导致信息丢失",
                with: [
                    .font(.font(size: 14, type: .regular)),
                    .foreground(.custom(.gray_94a5be)),
                    .paragraph(.alignment(.left), .lineSpacing(5))
                ])
            
            attrStr += descriptionStr
            attrStr += description2Str
            
        } else {
            let descriptionStr: ASAttributedString = .init(
                string: "登录后可同步\(areaType)信息到云端",
                with: [
                    .font(.font(size: 14, type: .regular)),
                    .foreground(.custom(.black_333333)),
                    .paragraph(.alignment(.left), .lineSpacing(5))
                ])
            
            let loginStr: ASAttributedString = .init(
                string: "去登录".localizedString,
                .font(.font(size: 14, type: .bold)),
                .foreground(.custom(.blue_427aed)),
                .action { [weak self] in
                    self?.loginClick?()
                    
                })
            
            attrStr += descriptionStr
            attrStr += loginStr
            
            chooseButton2.snp.remakeConstraints {
                $0.top.equalTo(tipsLabel.snp.bottom).offset(30)
                $0.left.equalTo(ZTScaleValue(23.5))
                $0.width.height.equalTo(ZTScaleValue(18.5))
            }

            chooseLabel.isHidden = true
            chooseButton.isHidden = true
            
        }
         
        chooseLabel2.isHidden = !(area.extensions?.contains("wangpan") ?? false)
        chooseButton2.isHidden = !(area.extensions?.contains("wangpan") ?? false)
        
        if chooseLabel2.isHidden {
            line.snp.makeConstraints {
                $0.left.right.equalToSuperview()
                $0.height.equalTo(0.5)
                $0.top.equalTo(chooseLabel.snp.bottom).offset(30)
            }
        }
        
        if chooseLabel.isHidden && chooseLabel2.isHidden {
            line.snp.makeConstraints {
                $0.left.right.equalToSuperview()
                $0.height.equalTo(0.5)
                $0.top.equalTo(tipsLabel.snp.bottom).offset(30)
            }
        }
        
        tipsLabel.attributed.text = attrStr


    }
    
    @discardableResult
    static func show(area: Area, isBindCloud: Bool, sureCallback: ((Bool, Bool) -> ())?, loginClick: (() -> ())? = nil) -> DeleteSAAlert {
        let tipsView = DeleteSAAlert(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        tipsView.sureCallback = sureCallback
        tipsView.loginClick = loginClick
        tipsView.setupDetail(isBindCloud: isBindCloud, area: area)
        UIApplication.shared.windows.first?.addSubview(tipsView)
        return tipsView
    }
    
    

}
