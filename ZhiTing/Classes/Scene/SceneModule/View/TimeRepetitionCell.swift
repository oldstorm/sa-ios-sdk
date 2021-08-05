//
//  TimeRepetitionCell.swift
//  ZhiTing
//
//  Created by mac on 2021/4/16.
//

import UIKit

class TimeRepetitionCell: UITableViewCell,ReusableView {

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
                repetition.text = timeModel.repetitionResult
                setupViews()
            }
    }
    
    
    lazy var title = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "重复".localizedString
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
    }
    
    lazy var repetition = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.textColor = .custom(.gray_94a5be)
        $0.text = "每天".localizedString
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
    }

    
    lazy var arrowIcon = UIImageView().then {
        $0.image = .assets(.right_arrow_gray)
    }
    
    
    
    func setupViews() {
        contentView.addSubview(title)
        contentView.addSubview(repetition)
        contentView.addSubview(arrowIcon)
        
        title.snp.makeConstraints {
            $0.left.equalTo(ZTScaleValue(20.0))
            $0.centerY.equalToSuperview()
            $0.height.equalTo(14)
        }
        
        arrowIcon.snp.makeConstraints {
            $0.right.equalTo(-ZTScaleValue(20.0))
            $0.centerY.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(8))
            $0.height.equalTo(14)
        }
        
        repetition.snp.makeConstraints {
            $0.right.equalTo(arrowIcon.snp.left).offset(-ZTScaleValue(15))
            $0.centerY.equalToSuperview()
            $0.width.greaterThanOrEqualTo(ZTScaleValue(25))
            $0.left.greaterThanOrEqualTo(title.snp.right)
            $0.height.equalTo(14)
        }
    }


}
