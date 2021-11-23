//
//  ControlSceneCell.swift
//  ZhiTing
//
//  Created by mac on 2021/4/22.
//

import UIKit

enum ControllerSceneCellType {
    case selected
    case delay
}

class ControlSceneCell: UITableViewCell, ReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    lazy var coverView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.layer.masksToBounds = true
    }

    var cellType = ControllerSceneCellType.selected
    
    
    lazy var titleLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.lineBreakMode = .byTruncatingTail
    }
    
    lazy var valueLabel = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.gray_94a5be)
        $0.numberOfLines = 0
        $0.isHidden = false
    }
    
    lazy var SceneIcon = UIImageView().then {
        $0.image = .assets(.icon_control_scene)
        $0.layer.borderWidth = ZTScaleValue(0.5)
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.layer.cornerRadius = ZTScaleValue(4.0)
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFit
    }

    lazy var selectButton = SelectButton(type: .square).then { $0.isUserInteractionEnabled = false }
    //箭头icon
    lazy var arrowIcon = ImageView().then {
        $0.image = .assets(.right_arrow_gray)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }
    
    public func setUpViewCellWith(type: ControllerSceneCellType, title: String){
        titleLabel.text = title
        self.cellType = type
        setupViews()
        switch type {
        case .selected:
            SceneIcon.isHidden = false
            selectButton.isHidden = false
            arrowIcon.isHidden = true
        case .delay:
            SceneIcon.isHidden = true
            selectButton.isHidden = true
            arrowIcon.isHidden = false
        }
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(coverView)
        coverView.addSubview(SceneIcon)
        coverView.addSubview(titleLabel)
        coverView.addSubview(selectButton)
        coverView.addSubview(arrowIcon)
        coverView.addSubview(valueLabel)
    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(10))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(-ZTScaleValue(15))
            $0.bottom.equalToSuperview()
        }
        if cellType == .selected {
            valueLabel.isHidden = true
            SceneIcon.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(ZTScaleValue(16))
                $0.width.height.equalTo(ZTScaleValue(40))
            }
            
            titleLabel.snp.makeConstraints{
                $0.left.equalTo(SceneIcon.snp.right).offset(ZTScaleValue(14.5))
                $0.centerY.equalTo(SceneIcon)
                $0.right.equalTo(selectButton.snp.left).offset(-ZTScaleValue(10))
            }
            
            selectButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().offset(-ZTScaleValue(15))
                $0.height.width.equalTo(ZTScaleValue(18.5))
            }
        }else{
            valueLabel.isHidden = false
            titleLabel.snp.makeConstraints{
                $0.left.equalTo(ZTScaleValue(14.5))
                $0.centerY.equalToSuperview()
                $0.right.equalTo(arrowIcon.snp.left).offset(-ZTScaleValue(10))
            }
            
            valueLabel.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel.snp.centerY)
                $0.right.equalTo(arrowIcon.snp.left).offset(ZTScaleValue(-15))
                
            }
            
            arrowIcon.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().offset(-15)
                $0.width.equalTo(ZTScaleValue(7.5))
                $0.height.width.equalTo(ZTScaleValue(13.5))
            }
        }
    }

}
