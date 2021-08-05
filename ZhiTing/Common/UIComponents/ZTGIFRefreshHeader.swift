//
//  ZTGIFRefreshHeader.swift
//  ZhiTing
//
//  Created by mac on 2021/4/29.
//

import UIKit

class ZTGIFRefreshHeader: MJRefreshHeader {

    private var logoImgView = UIImageView()
    
    private var gifDuration = 0.0
    
    private var imgs = [UIImage]()

    //在这里做一些初始化配置（比如添加子控件）
    override func prepare() {
        super.prepare()
        self.mj_h = ZTScaleValue(50)
        let path = Bundle.main.path(forResource: "loding", ofType: "gif")
        let data = NSData(contentsOfFile: path!)
        imgs = praseGIFDataToImageArray(data: data!)
        logoImgView.image = imgs.first
        logoImgView.animationImages = imgs
        self.addSubview(logoImgView)
    }
    
    //在这里设置子控件的位置和尺寸
    override func placeSubviews() {
        super.placeSubviews()
        
        logoImgView.snp.makeConstraints {
            $0.bottom.equalTo(-ZTScaleValue(5))
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(30))
        }
    }
    
    //监听控件的刷新状态
    override var state: MJRefreshState{
        didSet
        {
            switch (state) {
            case .idle:
                logoImgView.stopAnimating()
                break
            case .pulling:
                logoImgView.startAnimating()
                break
            case .refreshing:
                logoImgView.startAnimating()
                break
            case .willRefresh:
                logoImgView.startAnimating()
                break
            case .noMoreData:
                logoImgView.stopAnimating()
                break
            default:
                break
            }
        }
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()
        logoImgView.startAnimating()
    }
    
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
