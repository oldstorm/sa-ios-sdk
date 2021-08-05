//
//  TimeAllDayCell.swift
//  ZhiTing
//
//  Created by mac on 2021/4/16.
//

import UIKit

class TimeAllDayCell: UITableViewCell,ReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var currentModel : TimerModel? {
        didSet{
            guard let timeModel = currentModel else { return }
            if timeModel.isChooseAllDay {
                chooseIcon.image = .assets(.selected_tick)
            }else{
                chooseIcon.image = .assets(.unselected_tick)
            }
            setupViews()
        }
    }
    
    
    lazy var title = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "全天".localizedString
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
    }
    
    lazy var chooseIcon = UIImageView().then {
        $0.image = .assets(.unselected_tick)
    }
    
    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    func setupViews() {
        contentView.addSubview(title)
        contentView.addSubview(chooseIcon)
        contentView.addSubview(line)
        
        title.snp.makeConstraints {
            $0.left.equalTo(ZTScaleValue(20.0))
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20.0)
        }
        
        chooseIcon.snp.makeConstraints {
            $0.right.equalTo(-ZTScaleValue(20.0))
            $0.centerY.equalTo(title)
            $0.height.width.equalTo(ZTScaleValue(20))
        }
        
        line.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.width.equalTo(ZTScaleValue(0.5))
        }
    }
}
