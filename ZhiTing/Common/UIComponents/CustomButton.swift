//
//  CustomButton.swift
//  ZhiTing
//
//  Created by mac on 2021/5/8.
//

import UIKit

enum CustomButtonType {
    case centerTitleAndLoading(normalModel: customButtonStruct)
    case switchAndLoading
    case leftLoadingRightTitle(normalModel: customButtonStruct, lodingModel: customButtonStruct)
}

struct customButtonStruct {
    let title: String
    let titleColor: UIColor
    let font: UIFont
    let bagroundColor: UIColor
}


class customButtonModel: NSObject {
    var title = ""
    var font = UIFont()
    var bagroundColor = UIColor()
}

class CustomButton: UIButton {

    var currentType = CustomButtonType.centerTitleAndLoading(normalModel: .init(title: "", titleColor: .black, font: .systemFont(ofSize: .zero), bagroundColor: .white))
    var switchIsOn = false
    var nomalStruct = customButtonStruct(title: "", titleColor: .cyan, font: .systemFont(ofSize: .zero), bagroundColor: .cyan)
    var LoadingStruct = customButtonStruct(title: "", titleColor: .cyan, font: .systemFont(ofSize: .zero), bagroundColor: .cyan)

    
    lazy var title = UILabel().then{
        $0.backgroundColor = .clear
        $0.textAlignment = .center
    }
    
    var activityIndicator = UIActivityIndicatorView().then{
        $0.style = .medium
    }
    lazy var switchBg = UIView().then{
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = ZTScaleValue(9)
        $0.layer.masksToBounds = true
        $0.isUserInteractionEnabled = false
    }
    lazy var switchSlider = UIView().then{
        $0.backgroundColor = .white
        $0.layer.cornerRadius = ZTScaleValue(7)
        $0.layer.masksToBounds = true
        $0.isUserInteractionEnabled = false
    }

    func ZTScaleValue(_ value:CGFloat) -> CGFloat{
        return value * UIScreen.main.bounds.width / 375.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(buttonType: CustomButtonType) {
        super.init(frame: .zero)
        currentType = buttonType
        switch buttonType {
        case .centerTitleAndLoading(let normalModel):
            nomalStruct = normalModel
            setUpCenterTitleAndLodingView()
        case .switchAndLoading:
            setUpSwitchAndLoadingView()
        case .leftLoadingRightTitle(let normalModel, let lodingModel):
            nomalStruct = normalModel
            LoadingStruct = lodingModel
            setUpLeftLoadingRightTitleView()
        }
    }
    
    func selectedChangeView(isLoading:Bool){
        if isLoading {
            switch currentType {
            case .centerTitleAndLoading:
                setupCenterTitleAndLoadingViewWhenLoading()
            case .switchAndLoading:
                setUpSwitchAndLoadingViewWhenLoading()
            case .leftLoadingRightTitle:
                setUpLeftLoadingRightTitleViewWhenLoding()
            }
        }else{
            switch currentType {
            case .centerTitleAndLoading:
                setUpCenterTitleAndLodingView()
            case .switchAndLoading:
                setUpSwitchAndLoadingView()
            case .leftLoadingRightTitle:
                setUpLeftLoadingRightTitleView()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension CustomButton{
    private func setUpCenterTitleAndLodingView(){
        activityIndicator.removeFromSuperview()
        self.addSubview(title)
        title.text = nomalStruct.title
        title.textColor = nomalStruct.titleColor
        self.backgroundColor = nomalStruct.bagroundColor
        title.font = nomalStruct.font
        title.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupCenterTitleAndLoadingViewWhenLoading(){
        title.removeFromSuperview()
        self.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        activityIndicator.startAnimating()
    }
    
    private func setUpSwitchAndLoadingView(){
        activityIndicator.removeFromSuperview()
        self.addSubview(switchBg)
        switchBg.addSubview(switchSlider)
        switchBg.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        switchSlider.snp.removeConstraints()
        if !switchIsOn {
            switchBg.backgroundColor = .custom(.gray_cfd6e0)
            switchSlider.snp.makeConstraints{
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(ZTScaleValue(2))
                $0.width.height.equalTo(ZTScaleValue(14))
            }
        }else{
            switchBg.backgroundColor = .custom(.blue_2da3f6)
            switchSlider.snp.makeConstraints{
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().offset(-ZTScaleValue(2))
                $0.width.height.equalTo(ZTScaleValue(14))
            }
        }
    }
    
    private func setUpSwitchAndLoadingViewWhenLoading(){
        switchSlider.addSubview(activityIndicator)
        switchSlider.snp.removeConstraints()
        if !switchIsOn {
            switchBg.backgroundColor = .custom(.gray_cfd6e0)
            switchSlider.snp.makeConstraints{
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(ZTScaleValue(2))
                $0.width.height.equalTo(ZTScaleValue(14))
            }
        }else{
            switchBg.backgroundColor = .custom(.blue_2da3f6)
            switchSlider.snp.makeConstraints{
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().offset(-ZTScaleValue(2))
                $0.width.height.equalTo(ZTScaleValue(14))
            }
        }
        activityIndicator.snp.makeConstraints{
            $0.center.equalToSuperview()
            $0.width.height.equalToSuperview()
        }
        activityIndicator.startAnimating()
    }

    
    private func setUpLeftLoadingRightTitleView(){
        activityIndicator.removeFromSuperview()
        self.addSubview(title)
        title.text = nomalStruct.title
        title.textColor = nomalStruct.titleColor
        self.backgroundColor = nomalStruct.bagroundColor
        title.font = nomalStruct.font
        
        title.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

    }
    
    private func setUpLeftLoadingRightTitleViewWhenLoding(){
        self.addSubview(activityIndicator)
        title.text = LoadingStruct.title
        title.textColor = LoadingStruct.titleColor
        self.backgroundColor = LoadingStruct.bagroundColor
        title.font = LoadingStruct.font
        
        title.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.right.equalTo(title.snp.left).offset(-ZTScaleValue(5))
        }
        activityIndicator.startAnimating()
    }

}
