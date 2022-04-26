//
//  AddDeviceCell.swift
//  ZhiTing
//
//  Created by mac on 2021/4/20.
//

import UIKit

class AddDeviceCell: UITableViewCell,ReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var currentModel : Device? {
        didSet{
            guard let deviceModel = currentModel else { return }
            title.text = deviceModel.name
            if let name = deviceModel.location_name {
                place.text = name
            } else if let name = deviceModel.department_name {
                place.text = name
            } else {
                place.text = " "
            }
            
            deviceIcon.setImage(urlString: deviceModel.logo_url, placeHolder: .assets(.default_device))
            setupViews()
        }
    }
    
    //设备图标
    lazy var deviceIcon = ImageView().then {
        $0.layer.borderWidth = ZTScaleValue(0.5)
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.layer.cornerRadius = ZTScaleValue(4.0)
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.default_device)
    }
    
    //箭头icon
    lazy var arrowIcon = ImageView().then {
        $0.image = .assets(.right_arrow_gray)
    }
    
    lazy var title = Label().then {
        $0.text = "".localizedString
        $0.font = .font(size: ZTScaleValue(14.0), type: .bold)
        $0.textColor = .custom(.black_3f4663)
    }

    lazy var place = Label().then {
        $0.text = "".localizedString
        $0.font = .font(size: ZTScaleValue(12), type: .medium)
        $0.textColor = .custom(.gray_94a5be)
    }

    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }

    private func setupViews(){
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(deviceIcon)
        contentView.addSubview(title)
        contentView.addSubview(place)
        contentView.addSubview(arrowIcon)
        contentView.addSubview(line)
        
        deviceIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(ZTScaleValue(15))
            $0.width.height.equalTo(ZTScaleValue(45))
        }
        
        title.snp.makeConstraints {
            $0.top.equalTo(deviceIcon).offset(ZTScaleValue(5.5))
            $0.left.equalTo(deviceIcon.snp.right).offset(ZTScaleValue(14))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(80))
            
        }
        
        place.snp.makeConstraints {
            $0.bottom.equalTo(deviceIcon).offset(-ZTScaleValue(3))
            $0.left.equalTo(deviceIcon.snp.right).offset(ZTScaleValue(14))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(50))
        }
        
        arrowIcon.snp.makeConstraints {
            $0.right.equalTo(-ZTScaleValue(15))
            $0.centerY.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(7.5))
            $0.height.equalTo(ZTScaleValue(13.5))
        }
        
        line.snp.makeConstraints {
            $0.left.equalTo(title)
            $0.right.equalTo(arrowIcon)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(0.5))
        }
        
    }
    
    override func prepareForReuse() {
        deviceIcon.removeFromSuperview()
        title.removeFromSuperview()
        place.removeFromSuperview()
        arrowIcon.removeFromSuperview()
        line.removeFromSuperview()
    }
    

}
