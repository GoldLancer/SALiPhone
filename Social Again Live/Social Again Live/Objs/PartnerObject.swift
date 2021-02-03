//
//  PartnerObject.swift
//  Social Again Live
//
//  Created by Anton Yagov on 29.01.2021.
//

import UIKit

struct PartnerConstant {
    static let OWNER_ID         = "ownerId"
    static let OWNER_NAME       = "ownerName"
    static let OWNER_TOKEN      = "ownerToken"
    static let STREAM_ID        = "streamId"
    
    static let IS_ONLINE        = "isOnline"
    static let HAS_DECLINED     = "hasDeclined"
    static let HAS_REJECTED     = "hasRejected"
    static let PAUSED           = "paused"
}

class PartnerObject: NSObject {

    var ownerId: String     = ""
    var ownerName: String   = ""
    var ownerToken: String  = ""
    var streamId: String    = ""

    var isOnline            = false
    var hasDeclined         = false
    var hasRejected         = false
    var paused              = false
    
    func getObjectJsonvalue() -> [String:Any] {
        return [PartnerConstant.OWNER_ID        : self.ownerId,
                PartnerConstant.OWNER_NAME      : self.ownerName,
                PartnerConstant.OWNER_TOKEN     : self.ownerToken,
                PartnerConstant.STREAM_ID       : self.streamId,
                
                PartnerConstant.IS_ONLINE       : self.isOnline,
                PartnerConstant.HAS_DECLINED    : self.hasDeclined,
                PartnerConstant.HAS_REJECTED    : self.hasRejected,
                PartnerConstant.PAUSED          : self.paused ]
    }
    
    func initObjectWithJsonresponse(value: NSDictionary) {
        self.ownerId = value[PartnerConstant.OWNER_ID] as? String ?? ""
        self.ownerName = value[PartnerConstant.OWNER_NAME] as? String ?? ""
        self.ownerToken = value[PartnerConstant.OWNER_TOKEN] as? String ?? ""
        self.streamId = value[PartnerConstant.STREAM_ID] as? String ?? ""
        
        self.isOnline = value[PartnerConstant.IS_ONLINE] as? Bool ?? false
        self.hasDeclined = value[PartnerConstant.HAS_DECLINED] as? Bool ?? false
        self.hasRejected = value[PartnerConstant.HAS_REJECTED] as? Bool ?? false
        self.paused = value[PartnerConstant.PAUSED] as? Bool ?? false
    }    
}
