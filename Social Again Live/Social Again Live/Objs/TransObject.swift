//
//  TransObject.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit

struct TransConstant {
    static let TRANS_ID         = "transactionID"
    static let PRODUCT_ID       = "productId"
    static let STARTED_AT       = "startTime"
    static let TYPE             = "type"
    static let STATUS           = "status"
    static let PRICE            = "price"
}


class TransObject: NSObject {
    
    var transactionID: String   = ""
    var productId: String       = ""
    
    var startTime: UInt64       = 0
    var type: TransactionType   = .INAPP
    
    var status: String          = ""
    var price: Double           = 0.0
    
    func initObjectFromJSON(_ jsonData: NSDictionary) {
        self.transactionID  = jsonData[TransConstant.TRANS_ID] as? String ?? ""
        self.productId      = jsonData[TransConstant.PRODUCT_ID] as? String ?? ""
        
        self.startTime      = jsonData[TransConstant.STARTED_AT] as? UInt64 ?? 0
        let transType = jsonData[TransConstant.TYPE] as? String ?? ""
        self.type           = TransactionType.init(rawValue: transType) ?? .INAPP
        
        self.status         = jsonData[TransConstant.STATUS] as? String ?? ""
        self.price          = jsonData[TransConstant.PRICE] as? Double ?? 0.0
    }
    
    func getJsonValueOfObject() -> [String:Any] {
        return [TransConstant.TRANS_ID      : self.transactionID,
                TransConstant.PRODUCT_ID    : self.productId,
                TransConstant.STARTED_AT    : self.startTime,
                TransConstant.TYPE          : self.type.rawValue,
                TransConstant.STATUS        : self.status,
                TransConstant.PRICE         : self.price]
    }
}
