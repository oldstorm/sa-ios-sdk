//
//  TimeSelectCell.swift
//  ZhiTing
//
//  Created by mac on 2021/4/16.
//

import UIKit

class TimeSelectCell: UITableViewCell,ReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var SelectCallback: ((_ tag: Int) -> ())?

    var currentModel : TimerModel? {
        didSet{
            guard let timeModel = currentModel else { return }
            if timeModel.isChooseTimer {
                chooseIcon.image = .assets(.selected_tick)
                starLabel.isHidden = false
                starTimeLabel.isHidden = false
                starButton.isHidden = false
                endLabel.isHidden = false
                endTimeLabel.isHidden = false
                endButton.isHidden = false
            }else{
                chooseIcon.image = .assets(.unselected_tick)
                starLabel.isHidden = true
                starTimeLabel.isHidden = true
                starButton.isHidden = true
                endLabel.isHidden = true
                endTimeLabel.isHidden = true
                endButton.isHidden = true
            }
            
                starTimeLabel.text = timeModel.starTime
                starLabel.textColor = .custom(.black_3f4663)
                starTimeLabel.textColor = .custom(.blue_2da3f6)
            
                endTimeLabel.text = timeModel.endTime
                endLabel.textColor = .custom(.black_3f4663)
                endTimeLabel.textColor = .custom(.blue_2da3f6)
            setupViews()
        }
    }
    
    
    lazy var title = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "时间段".localizedString
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
    }
    
    lazy var chooseIcon = UIImageView().then {
        $0.image = .assets(.unselected_tick)
    }
    
    lazy var starLabel = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.text = "开始".localizedString
        $0.font = .font(size: ZTScaleValue(11), type: .bold)
        $0.textAlignment = .center
    }
    
    lazy var starTimeLabel = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.text = ""
        $0.font = .font(size: ZTScaleValue(18), type: .D_bold)
        $0.textAlignment = .center
    }
    
    lazy var endLabel = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.text = "结束".localizedString
        $0.font = .font(size: ZTScaleValue(11), type: .bold)
        $0.textAlignment = .center
    }
    
    lazy var endTimeLabel = Label().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.text = ""
        $0.font = .font(size: ZTScaleValue(18), type: .D_bold)
        $0.textAlignment = .center
    }

    lazy var starButton = Button().then {
        $0.backgroundColor = .clear
        $0.tag = 1
        $0.clickCallBack = { [weak self] _ in
            self?.SelectCallback!(1)
        }
    }
    
    lazy var endButton = Button().then {
        $0.backgroundColor = .clear
        $0.tag = 2
        $0.clickCallBack = { [weak self] _ in
            self?.SelectCallback!(2)
        }
    }

    
    
    func setupViews() {
        contentView.addSubview(title)
        contentView.addSubview(chooseIcon)
        contentView.addSubview(starLabel)
        contentView.addSubview(starTimeLabel)
        contentView.addSubview(endLabel)
        contentView.addSubview(endTimeLabel)
        contentView.addSubview(starButton)
        contentView.addSubview(endButton)
        
        title.snp.makeConstraints {
            $0.top.equalTo(ZTScaleValue(18))
            $0.left.equalTo(ZTScaleValue(20.0))
            $0.height.equalTo(ZTScaleValue(20.0))
        }
        
        chooseIcon.snp.makeConstraints {
            $0.right.equalTo(-ZTScaleValue(20.0))
            $0.centerY.equalTo(title)
            $0.height.width.equalTo(ZTScaleValue(20))
        }
        
        starLabel.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(ZTScaleValue(20))
            $0.centerX.equalTo(contentView.snp.centerX).multipliedBy(0.5)
            $0.height.equalTo(ZTScaleValue(11))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(22))
        }
        
        endLabel.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(ZTScaleValue(20))
            $0.centerX.equalTo(contentView.snp.centerX).multipliedBy(1.5)
            $0.height.equalTo(ZTScaleValue(11))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(22))
        }
        
        starTimeLabel.snp.makeConstraints {
            $0.top.equalTo(starLabel.snp.bottom).offset(ZTScaleValue(7.5))
            $0.centerX.equalTo(contentView.snp.centerX).multipliedBy(0.5)
            $0.height.equalTo(ZTScaleValue(20))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(68.0))
        }
        
        endTimeLabel.snp.makeConstraints {
            $0.top.equalTo(endLabel.snp.bottom).offset(ZTScaleValue(7.5))
            $0.centerX.equalTo(contentView.snp.centerX).multipliedBy(1.5)
            $0.height.equalTo(ZTScaleValue(20))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(68.0))
        }
        
        starButton.snp.makeConstraints {
            $0.top.equalTo(starLabel).offset(-ZTScaleValue(10))
            $0.left.equalTo(starTimeLabel).offset(-ZTScaleValue(10))
            $0.right.equalTo(starTimeLabel).offset(ZTScaleValue(10))
            $0.bottom.equalTo(starTimeLabel).offset(ZTScaleValue(10))
        }
        
        endButton.snp.makeConstraints {
            $0.top.equalTo(endLabel).offset(-ZTScaleValue(10))
            $0.left.equalTo(endTimeLabel).offset(-ZTScaleValue(10))
            $0.right.equalTo(endTimeLabel).offset(ZTScaleValue(10))
            $0.bottom.equalTo(endTimeLabel).offset(ZTScaleValue(10))
        }

    }
}



