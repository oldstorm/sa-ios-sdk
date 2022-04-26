//
//  CheckUpdateAlertView.swift
//  ZhiTing
//
//  Created by zy on 2021/10/29.
//

import UIKit

class CheckUpdateAlertView: UIView {
    
    var checkCallback: ((_ isUpdate: Bool) -> ())?
    
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.3)
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.clipsToBounds = true
    }

    lazy var logoImg = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.software_update_logo)
    }
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(20), type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.text = "检查更新".localizedString
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    lazy var subscriptLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.text = "检查到有新版本2.0.6-2054，是否更新？".localizedString
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    
    private lazy var checkBtn = CustomButton(buttonType:
                                                .centerTitleAndLoading(normalModel:
                                                                        .init(
                                                                            title: "更新".localizedString,
                                                                            titleColor: .custom(.white_ffffff),
                                                                            font: .font(size: ZTScaleValue(14), type: .bold),
                                                                            backgroundColor: .custom(.blue_2da3f6)
                                                                        )
                                                )).then {
                                                    $0.layer.cornerRadius = ZTScaleValue(25)
                                                    $0.addTarget(self, action: #selector(onClickCheck), for: .touchUpInside)
                                                }
    
    
    private lazy var cancelBtn = Button().then {
        $0.setImage(.assets(.software_update_back), for: .normal)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }

        
    }

    
    @objc private func onClickCheck() {
        checkBtn.selectedChangeView(isLoading: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else {return}
            self.checkBtn.selectedChangeView(isLoading: false)
            self.removeFromSuperview()
            self.checkCallback?(true)
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init(frame: CGRect, version: String) {
        self.init(frame: frame)
        self.subscriptLabel.text = "检查到有新版本\(version)，是否更新？"
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
        
        container.addSubview(logoImg)
        container.addSubview(titleLabel)
        
        container.addSubview(subscriptLabel)
        container.addSubview(checkBtn)
        
        cover.addSubview(cancelBtn)

        
    }

    private func setConstrains() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-ZTScaleValue(20))
            $0.width.equalTo(Screen.screenWidth - ZTScaleValue(135))
        }
        
        logoImg.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(18.5))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(136.5))
            $0.height.equalTo(ZTScaleValue(102))
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImg.snp.bottom).offset(ZTScaleValue(10.5))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        
        subscriptLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(12))
            $0.left.equalToSuperview().offset(ZTScaleValue(27))
            $0.right.equalToSuperview().offset(ZTScaleValue(-27))
        }
        
        checkBtn.snp.makeConstraints {
            $0.top.equalTo(subscriptLabel.snp.bottom).offset(ZTScaleValue(28.5))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(170))
            $0.height.equalTo(ZTScaleValue(50))
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(25.5))
        }
        
        cancelBtn.snp.makeConstraints {
            $0.top.equalTo(container.snp.bottom).offset(ZTScaleValue(38))
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(24))
        }
    }
    
    @discardableResult
    static func show(version: String, checkCallback: ((_ isUpdate: Bool) -> ())?) -> CheckUpdateAlertView {
        let updateView = CheckUpdateAlertView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight), version: version)
        updateView.checkCallback = checkCallback
        UIApplication.shared.windows.first?.addSubview(updateView)
        return updateView
    }

}
