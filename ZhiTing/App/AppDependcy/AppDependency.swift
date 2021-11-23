//
//  AppDependcy.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/22.
//
import Moya
import Foundation
import IQKeyboardManagerSwift
import Kingfisher
import Toast_Swift
import Combine
import RealmSwift
import Alamofire


struct AppDependency {
    let websocket: ZTWebSocket
    let apiService: MoyaProvider<ApiService>
    var tabbarController: TabbarController
    let openUrlHandler: OpenUrlHandler
    lazy var cancellables = [AnyCancellable]()
}

fileprivate let requestClosure = { (endpoint: Endpoint, closure: (Result<URLRequest, MoyaError>) -> Void)  -> Void in
    do {
        var  urlRequest = try endpoint.urlRequest()
        urlRequest.timeoutInterval = 15
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlRequest.httpShouldHandleCookies = true
        closure(.success(urlRequest))
    } catch MoyaError.requestMapping(let url) {
        closure(.failure(MoyaError.requestMapping(url)))
    } catch MoyaError.parameterEncoding(let error) {
        closure(.failure(MoyaError.parameterEncoding(error)))
    } catch {
        closure(.failure(MoyaError.underlying(error, nil)))
    }
    
}


extension AppDependency {
    static func resolve() -> AppDependency {
        let websocket = ZTWebSocket()
        let apiService = MoyaProvider<ApiService>(requestClosure: requestClosure)
        let tabbarController = TabbarController()
        let openUrlHandler = OpenUrlHandler()

        return AppDependency(
            websocket: websocket,
            apiService: apiService,
            tabbarController: tabbarController,
            openUrlHandler: openUrlHandler
        )
        
    }
    
    func config() {
        // keyboard config
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        // kingfisher
        KingfisherManager.shared.downloader.downloadTimeout = 30
        KingfisherManager.shared.downloader.authenticationChallengeResponder = KFCerAuthenticationChallenge.shared
        
        // toast-swift
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.isQueueEnabled = true
        ToastManager.shared.position = .center
        ToastManager.shared.duration = 1.5
        ToastManager.shared.style.titleFont = .font(size: 14, type: .medium)

        // RealmSwift
        let config = Realm.Configuration(
            schemaVersion: 1, // 当前数据库schema version.
            migrationBlock: { migration, oldSchemaVersion in
                // 数据库迁移例子
//                if oldSchemaVersion < 0 {
//                    // The enumerateObjects(ofType:_:) method iterates over
//                    // every Person object stored in the Realm file to apply the migration
//                    migration.enumerateObjects(ofType: AreaCache.className()) { oldObject, newObject in
//                        // combine name fields into a single field
//                        let id = oldObject!["id"] as? Int ?? 0
//                        newObject!["id"] = "\(id)"
//                    }
//                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
        print("RealmPath: \(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")")
        
    }
    
    
}








