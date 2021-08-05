//
//  Image.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit
import Kingfisher
import Alamofire

class ImageView: UIImageView {
    
    func setImage(urlString: String, placeHolder: UIImage? = nil) {
        contentMode = .scaleAspectFit
        
        let queryStr = urlString.urlDecoded().urlEncoded()
        
        guard let url = URL(string: queryStr) else {
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
