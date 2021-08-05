//
//  HistorySecondCell.swift
//  ZhiTing
//
//  Created by mac on 2021/4/13.
//

import UIKit

class HistorySecondCell: UITableViewCell,ReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var isLastObject = false
    var isLastSection = false
    
    
    var currentModel : SceneHistoryItemModel? {
        didSet{
            guard let deviceModel = currentModel else { return }
            title.text = deviceModel.name
            place.text = deviceModel.location_name
            
            //子任务结果:1执行成功;2部分执行完成;3执行失败;4执行超时;5设备已被删除;6设备离线;7场景已被删除
            switch deviceModel.result {
            case 1:
                result.text = "执行成功"
                result.textColor = .custom(.black_3f4663)
            case 2:
                result.text = "部分执行成功"
                result.textColor = .custom(.yellow_f3a934)
            case 3:
                result.text = "执行失败"
                result.textColor = .custom(.red_fe0000)
            case 4:
                result.text = "执行超时"
                result.textColor = .custom(.red_fe0000)
            case 5:
                result.text = "设备已删除"
                result.textColor = .custom(.red_fe0000)
            case 6:
                result.text = "设备离线"
                result.textColor = .custom(.red_fe0000)
            case 7:
                result.text = "场景已删除"
                result.textColor = .custom(.red_fe0000)
            default:
                result.text = ""
            }
            setupViews()
        }
    }

    lazy var title = Label().then {
        $0.text = "".localizedString
        $0.font = .font(size: ZTScaleValue(14.0), type: .bold)
        $0.textColor = .custom(.black_3f4663)
    }
    
    lazy var result = Label().then {
        $0.text = "".localizedString
        $0.font = .font(size: ZTScaleValue(11.5), type: .regular)
        $0.textColor = .custom(.black_3f4663)
    }
    
    lazy var place = Label().then {
        $0.text = "".localizedString
        $0.font = .font(size: ZTScaleValue(11.5), type: .medium)
        $0.textColor = .custom(.gray_94a5be)
    }
    
    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var bottomLine = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews(){
        contentView.addSubview(line)
        contentView.addSubview(title)
        contentView.addSubview(result)
        contentView.addSubview(place)

        line.snp.makeConstraints{
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalTo(contentView.snp.left).offset(ZTScaleValue(30.0))
            $0.width.equalTo(ZTScaleValue(2.0))
        }
        if isLastSection {
            line.isHidden = true
        }else{
            line.isHidden = false
        }
        title.snp.makeConstraints {
            $0.top.equalTo(ZTScaleValue(15.0))
            $0.left.equalTo(line).offset(ZTScaleValue(30.0))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(30))
            $0.height.greaterThanOrEqualTo(ZTScaleValue(13))
        }
        
        result.snp.makeConstraints {
            $0.top.equalTo(title)
            $0.right.equalTo(-ZTScaleValue(30.0))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(30))
            $0.height.lessThanOrEqualTo(ZTScaleValue(11.5))
        }
        
        place.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(ZTScaleValue(7.5))
            $0.left.equalTo(title)
            $0.width.greaterThanOrEqualTo(ZTScaleValue(30))
            $0.height.lessThanOrEqualTo(ZTScaleValue(11.5))
        }
        
        if isLastObject {
            contentView.addSubview(bottomLine)
            bottomLine.snp.makeConstraints {
                $0.bottom.equalToSuperview()
                $0.left.equalTo(title)
                $0.right.equalTo(result)
                $0.height.equalTo(ZTScaleValue(0.5))
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bottomLine.removeFromSuperview()
        line.removeFromSuperview()
        title.removeFromSuperview()
        result.removeFromSuperview()
        place.removeFromSuperview()
    }

}
