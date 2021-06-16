//
//  Image.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit
import Kingfisher

class ImageView: UIImageView {
    
    func setImage(urlString: String, placeHolder: UIImage? = nil) {
        
        guard let queryStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: queryStr)
        else {
            image = placeHolder
            return
        }
        var options = [KingfisherOptionsInfoItem]()
        /// retry
        let retry = DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(30))
        
        options.append(.cacheOriginalImage)
        options.append(.retryStrategy(retry))
        
        kf.setImage(with: url,placeholder: placeHolder, options: options)

    
    }
}
