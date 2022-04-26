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
    
    /// 设置网络图片
    /// - Parameters:
    ///   - urlString: 图片url
    ///   - placeHolder: 占位图
    ///   - successCallback: 成功后回调的图片
    func setImage(urlString: String, placeHolder: UIImage? = nil, successCallback: ((KFCrossPlatformImage) -> Void)? = nil) {
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
        
        kf.setImage(with: url, placeholder: placeHolder, options: options) { result in
            if case let .success(value) = result {
                successCallback?(value.image)
            }
        }
    
    }
}

/// kingfisher 图片加载证书信任
class KFCerAuthenticationChallenge: AuthenticationChallengeResponsible {
    static let shared = KFCerAuthenticationChallenge()
    
    public func downloader(
        _ downloader: ImageDownloader,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            challenge.sender?.use(credential, for: challenge)
            // 证书校验通过
            completionHandler(.useCredential, credential)
            return
        }

        completionHandler(.performDefaultHandling, nil)
    }

    public func downloader(
        _ downloader: ImageDownloader,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            challenge.sender?.use(credential, for: challenge)
            // 证书校验通过
            completionHandler(.useCredential, credential)
            return
        }
        
        completionHandler(.performDefaultHandling, nil)
    }
}
