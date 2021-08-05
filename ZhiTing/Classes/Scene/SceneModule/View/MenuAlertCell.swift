//
//  MenuAlertCell.swift
//  ZhiTing
//
//  Created by mac on 2021/4/20.
//

import UIKit

class MenuAlertCell: UITableViewCell,ReusableView {

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
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var title = Label().then {
        $0.text = "".localizedString
        $0.font = .font(size: ZTScaleValue(14.0), type: .medium)
        $0.textColor = .custom(.black_3f4663)
    }
    //选中icon
    lazy var selectedIcon = ImageView().then {
        $0.image = .assets(.selected_tick)
    }

    
    private func setupViews() {
        contentView.addSubview(title)
        contentView.addSubview(selectedIcon)
    }
    
    public func setSelectedState(isSelcted: Bool){
        if isSelcted {
            title.textColor = .custom(.blue_2da3f6)
            selectedIcon.isHidden = false
        }else{
            title.textColor = .custom(.black_3f4663)
            selectedIcon.isHidden = true
        }


    }
    
    private func setupConstraints() {
        title.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(ZTScaleValue(17))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(26.5))
            $0.height.equalTo(ZTScaleValue(13))
        }
        
        selectedIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-ZTScaleValue(15))
            $0.height.width.equalTo(ZTScaleValue(18.5))
        }
    }
    
    override func prepareForReuse() {
        title.text = ""
        selectedIcon.isHidden = true
    }
}
