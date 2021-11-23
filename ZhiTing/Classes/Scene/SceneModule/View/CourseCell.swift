//
//  CourseCell.swift
//  ZhiTing
//
//  Created by mac on 2021/4/12.
//

import UIKit

class CourseCell: UITableViewCell, ReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        $0.image = .assets(.course_bg)
    }
    
    lazy var title = Label().then {
        $0.text = "教你快速入门职能场景".localizedString
        $0.font = .font(size: ZTScaleValue(13.5), type: .medium)
        $0.textColor = .custom(.black_3f4663)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(bgView)
        bgView.addSubview(icon)
        bgView.addSubview(title)
        
        bgView.snp.makeConstraints{
            $0.left.equalTo(ZTScaleValue(15.0))
            $0.right.equalTo(-ZTScaleValue(15.0))
            $0.height.equalToSuperview()
        }
        
        icon.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().offset(-ZTScaleValue(39.5))
            $0.centerX.equalToSuperview()
        }

        title.snp.remakeConstraints{
            $0.width.equalToSuperview().offset(-ZTScaleValue(39.5))
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(39.5))
        }

    }
}
