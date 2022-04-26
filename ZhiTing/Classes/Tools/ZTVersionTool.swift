//
//  ZTVersionTool.swift
//  ZhiTing
//
//  Created by iMac on 2022/2/28.
//

import Foundation

struct ZTVersionTool {
    //比较版本号大小
    static func compareVersionIsNewBigger(nowVersion: String, newVersion: String) -> Bool {
        let version1 = nowVersion.split(separator: ".").map({String($0)})
        let version2 = newVersion.split(separator: ".").map({String($0)})
        
        var n1 = 0, n2 = 0
        
        while n1 < version1.count || n2 < version2.count {
            var count1 = 0
            if n1 < version1.count {
                count1 = Int(version1[n1])!
            }
            
            var count2 = 0
            if n2 < version2.count {
                count2 = Int(version2[n2])!
            }
            
            if count1 > count2 {
                return false
            }
            
            if count1 < count2 {
                return true
            }
            
            n1 += 1
            n2 += 1
        }
        
        return false
    }
    
}
