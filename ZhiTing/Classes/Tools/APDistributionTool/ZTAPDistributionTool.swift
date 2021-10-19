//
//  APDistributionTool.swift
//  ZhiTing
//
//  Created by iMac on 2021/9/7.
//

import UIKit
import CocoaAsyncSocket
import Combine
import CryptoSwift


class ZTAPDistributionTool: NSObject {

    /// 默认ip地址
    private var host = "192.168.4.1"
    /// 默认端口
    private var portNumber: UInt16 = 54322
    
    /// GCDAsyncUdpSocket
    private var udpSocket: GCDAsyncUdpSocket?
    
    /// 设备配网状态publisher
    var distributePublisher = PassthroughSubject<Bool, Never>()
    
    override init() {
        super.init()
        setupUDPSocket()
    }

    
    /// 建立UDPSocket
    /// - Parameter port: 绑定的端口号
    func setupUDPSocket() {
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: .main)
        do {
            try udpSocket?.enableReusePort(true)
            try udpSocket?.enableBroadcast(true)
            try udpSocket?.bind(toPort: portNumber)
            try udpSocket?.beginReceiving()
        } catch {
            
            print("error happens when setting up UDPSocket")
            print("\(error.localizedDescription)")
        }

    }
    
    
    
    /// 发送网络配置包
    func distributeNetwork(ssid: String, pwd: String) {
        
        
//        包头    包长    数据包    CRC校验
//        2个字节    2个字节    n个字节（n==包长）    2个字节
//        包头：（2个字节）
//        其内容固定为0x55EE
//        包长：（2个字节）
//        数据包长度n
//        数据包：（n个字节）
//        数据包格式为JSON
//        CRC校验：（2个字节）
//        CRC16，初始校验码0xffff，多项式8005
        
        
        /// header - 包头
        let headBytes: [UInt8] = [0x55, 0xEE]
        let headerData = Data(headBytes)
        
    
        /// body部分
        let bodyJSON = """
            {"method":"set_prop.sta_net","params":{"ssid":"\(ssid)","passwd":"\(pwd)"}}
            """
        
//        let bodyJSON = """
//            {"method":"get_prop.sta_net","params":{}}
//            """

        guard let bodyData = bodyJSON.data(using: .utf8) else {
            return
        }
        
        
        
        /// 包长
        let lengthBytes = withUnsafeBytes(of: Int16(bodyData.count).bigEndian) {
            Data($0)
        }
        
  
        
        
        let packageData = headerData + lengthBytes + bodyData
        
        let crc16Checksum = packageData.crc16(seed: 65535)
        
        let data = packageData + crc16Checksum
        
        
        self.udpSocket?.send(data, toHost: self.host, port: self.portNumber, withTimeout: -1, tag: 1)
            

    }
    


}

extension ZTAPDistributionTool: GCDAsyncUdpSocketDelegate {

    /// 接收到数据包
    /// - Parameters:
    ///   - sock: GCDAsyncUdpSocket
    ///   - data: 数据包
    ///   - address: 地址
    ///   - filterContext: 用于过滤的上下文
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        var addrStr: NSString? = nil
        var port: UInt16 = 0

        GCDAsyncUdpSocket.getHost(&addrStr, port: &port, fromAddress: address)
        guard let addStr = addrStr,
              let addr = addStr.components(separatedBy: ":").last,
              addr == host, // 过滤无关ip响应的数据包
              port == portNumber // 过滤无关端口响应的数据包
        else {
            return
        }
        
        print("------- data from -------")
        print("\(addr):\(port)")

        
        print("-------receive udp data-------")
        let receive = Array(data)
            .map { "0x\(String($0, radix: 16, uppercase: true))"}
            .joined(separator: ", ")
            .replacingOccurrences(of: "\"", with: "")
        
        print("\(receive)")
        
        /// 字节数组
        let dataArray = Array(data)
        /// 至少6个字节
        guard dataArray.count >= 6 else {
            return
        }
        
        /// 数据包解包
        /// -------
        /// 包头部分
        
        /// 包头：（2个字节）
        /// 其内容固定为0x55 0xEE
        if dataArray[0] != 0x55 || dataArray[1] != 0xEE {
            return
        }
        
        /// 包长：（2个字节）
        /// 包长包含整个数据包内容，包括数据前导
        let lengthData = Data(dataArray[2...3])
        /// 字节转Int16
        let int16Length = lengthData.withUnsafeBytes { ptr in
            ptr.load(as: Int16.self)
        }
        /// Int16大端字节流转Int
        let length = Int(int16Length.bigEndian)
        print("包长度: \(length)")
        guard length > 0 else {
            print("数据包长度小于0")
            return
        }
        
        /// 数据包body
        let bodyData = Data(dataArray[4..<(4 + length)])
        guard
            let jsonStr = String(data: bodyData, encoding: .utf8),
            let response = DeviceResponse.deserialize(from: jsonStr)
        else {
            print("数据包转json失败")
            return
        }
        
        if response.result.state == "connect" && response.result.ip != "0.0.0.0" { // 配网成功
            distributePublisher.send(true)
        } else { // 配网失败
            distributePublisher.send(false)
        }
        
        
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("didSend")
    }

}

extension ZTAPDistributionTool {
    class DeviceResponse: BaseModel {
        var result = DeviceResponseResult()
    }

    class DeviceResponseResult: BaseModel {
        var state = ""
        var ip = ""
    }

}
