//
//  UDPDevice.swift
//  macosSwiftUI
//
//  Created by iMac on 2021/8/18.
//

import Foundation

extension UDPDeviceTool {
    /// 通过UDP发现的设备
    class UDPDevice {
        /// 设备id(设备mac地址)
        let id: String
        
        /// 设备地址
        let host: String
        
        /// 设备端口
        let port: UInt16
        
        /// 客户端随机生成的16字节 用于AES解密设备token的key
        var key: String?
        
        /// 设备token
        var token: String?

        /// 设备信息
        var info: UDPDeviceInfo?
        
        init(id: String, host: String, port: UInt16) {
            self.id = id
            self.host = host
            self.port = port
        }

    }

    /// UDP设备信息
    class UDPDeviceInfo: BaseModel {
        /// 设备类型
        var model = ""
        
        /// 令牌组成：wifiMAC地址（6字节）+ 蓝牙MAC地址（6字节）+ 随机码（4字节)
        var token: String?
        
        /// 硬件版本
        var hw_ver: String?
        
        /// 软件版本
        var sw_ver: String?
        
        /// sa id
        var sa_id: String?
        
        /// sa端口号
        var port: String?

    }
    
    /// UDP设置服务器信息结果
    class UDPDeviceServerResult: BaseModel {
        /// 设备连接的服务器
        var server: String?
        
        /// 设备连接的服务器端口
        var port: Int?
        
        /// 设备连接的家庭id
        var area_id: String?
        
        /// 设备accessToken
        var access_token: String?
    }
    
    /// UDP响应
    class UDPDeviceResponse<T: BaseModel>: BaseModel {
        /// 数据包id
        var id: Int?
        
        /// 响应结果
        var result: T?
    }

}
