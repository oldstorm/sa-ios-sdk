//
//  AESTool.swift
//  macosSwiftUI
//
//  Created by iMac on 2021/8/19.
//

import Foundation
import CryptoSwift

struct UDPAesUtil {
    
    /// 通过本地key解密数据获取设备token
    /// - Parameters:
    ///   - data: 需要解密的数据
    ///   - key: 解密的key
    /// - Returns: 解密后的token数据
    static func decryptToken(_ data: Data, key: String) -> String? {
        let decryptKey =  key.md5()

        let decryptKeyData = decryptKey.hexaBytes

        let ivData = (decryptKeyData +  key.bytes).md5()

        
        do {
            let aes = try AES(key: decryptKeyData, blockMode: CBC(iv: ivData), padding: .pkcs7)
            let decryptedBytes = try aes.decrypt(data.bytes)
            return Data(decryptedBytes).toHexString()
        } catch {
            print("failed to decrypt")

            return nil
        }
        
    }
    
    /// 通过token解密设备响应的body
    /// - Parameters:
    ///   - data: 加密后的数据
    ///   - token: 设备token
    /// - Returns: 解密后的token
    static func decrypt(_ data: Data, by token: String) -> Data? {

        let decryptKeyData = token.hexaData.md5()

        let ivData = (decryptKeyData +  token.hexaBytes).md5()

        
        do {
            let aes = try AES(key: decryptKeyData.bytes, blockMode: CBC(iv: ivData.bytes), padding: .pkcs7)
            let decryptedBytes = try aes.decrypt(data.bytes)
            return Data(decryptedBytes)
        } catch {
            print("failed to decrypt")

            return nil
        }
        
    }

    
    /// 通过设备token加密数据
    /// - Parameters:
    ///   - data: 未加密的数据
    ///   - token: 设备token
    /// - Returns: 加密后的数据
    static func encrypt(_ data: Data, by token: String) -> Data? {

        let encryptKeyData = token.hexaData.md5()

        let ivData = (encryptKeyData +  token.hexaBytes).md5()
        
        do {
            let aes = try AES(key: encryptKeyData.bytes, blockMode: CBC(iv: ivData.bytes), padding: .pkcs7)
            let encryptedBytes = try aes.encrypt(data.bytes)
            return Data(encryptedBytes)
        } catch {
            print("failed to encrypt")
            return nil
        }
    }

}


extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}
