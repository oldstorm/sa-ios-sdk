//
//  BaseModel.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/3.
//

import Foundation

class BaseModel: HandyJSON {
    required init() {}
    
    func toData() -> Data? {
        let jsonString = self.toJSONString()
        let data = jsonString?.data(using: .utf8)
        return data
    }
}


class isSuccessModel: BaseModel {
    var success = true
}
