//
//  LodingView.swift
//  ZhiTing
//
//  Created by zy on 2021/4/30.
//

import UIKit

class LodingView: UIView {

    private var gifDuration = 0.0
    
    private var imgs = [UIImage]()
    
    lazy var logoImgView = UIImageView().then {
        
        let path = Bundle.main.path(forResource: "loding", ofType: "gif")
        let data = NSData(contentsOfFile: path!)
        imgs = praseGIFDataToImageArray(data: data!)
        $0.image = imgs.first
        $0.animationImages = imgs
    }
    
    lazy var lodingTitle = UILabel().then{
        $0.text = "Loading..."
        $0.font = .font(size: ZTScaleValue(14), type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.backgroundColor = .clear
    }

    lazy var containerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    lazy var bgView = UIView().then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.layer.masksToBounds = true
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.addSubview(bgView)
        bgView.addSubview(logoImgView)
        bgView.addSubview(lodingTitle)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bgView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(140))
        }
        
        logoImgView.snp.makeConstraints {
            $0.top.equalTo(ZTScaleValue(30))
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(60))
        }
        
        lodingTitle.snp.makeConstraints {
            $0.centerX.equalTo(logoImgView)
            $0.bottom.equalTo(-ZTScaleValue(20))
        }
    }
    
    func show(){
        self.logoImgView.startAnimating()
    }
    
    func hide(){
        self.logoImgView.stopAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension LodingView {
    private func praseGIFDataToImageArray(data:CFData) -> [UIImage]{
        
        guard let imageSource = CGImageSourceCreateWithData(data, nil) else {
                    return []
                }
        // 获取gif帧数
        let frameCount = CGImageSourceGetCount(imageSource)
        var images = [UIImage]()

        for i in 0 ..< frameCount {
            // 获取对应帧的 CGImage
            guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else {
                return []
            }
            if frameCount == 1 {
                // 单帧
                gifDuration = Double.infinity
            } else{
                // gif 动画
                // 获取到 gif每帧时间间隔
                guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) , let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
                      let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) else
                {
                    return []
                }
        //                print(frameDuration)
                gifDuration += frameDuration.doubleValue
                // 获取帧的img
                let  image = UIImage(cgImage: imageRef , scale: UIScreen.main.scale , orientation: UIImage.Orientation.up)
                // 添加到数组
                images.append(image)
            }
        }
        return images
    }

}
