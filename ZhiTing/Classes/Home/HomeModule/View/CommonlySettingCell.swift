//
//  CommonlySettingCell.swift
//  ZhiTing
//
//  Created by zy on 2022/4/6.
//

import UIKit

class CommonlySettingCell: UITableViewCell, ReusableView {

    var executiveCallback: (() -> ())?
    
    lazy var iconImgView = ImageView().then {
        $0.image = .assets(.app_logo)
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
        $0.setImage(.assets(.add_fail), for: .normal)
        $0.isEnhanceClick = true
        $0.clickCallBack = { [weak self] _ in
            self?.executiveCallback?()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        contentView.addSubview(iconImgView)
        contentView.addSubview(title)
        contentView.addSubview(executiveBtn)
        
        iconImgView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(ZTScaleValue(14))
            $0.width.height.equalTo(ZTScaleValue(45))
        }
        
        title.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(iconImgView.snp.right).offset(ZTScaleValue(15))
            $0.width.lessThanOrEqualTo(ZTScaleValue(200))
        }
        
        executiveBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(-ZTScaleValue(14))
            $0.width.height.equalTo(ZTScaleValue(20))
        }
    }
}
