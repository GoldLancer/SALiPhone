//
//  RequestObject.swift
//  Social Again Live
//
//  Created by Anton Yagov on 23.02.2021.
//

import UIKit
import Firebase

struct RequestConstant {
    static let REQUEST_ID           = "id"
    static let TITLE                = "title"
    static let DESCRIPTION          = "description"
    static let REQUEST_TYPE         = "type"
    
    static let REQUESTER_ID         = "requesterId"
    static let REQUESTER_NAME       = "requesterName"
    static let REQUESTER_EMAIL      = "requesterEmail"
    static let REQUESTER_PHONE      = "requesterPhone"
    
    static let COIN_AMOUNT          = "redeem_coin_amount"
    static let PAYMENT_METHOD       = "paymentMethod"
    static let PAYMENT_EMAIL        = "paymentEmail"
    static let HAS_RESOLVED         = "hasResolved"
}

class RequestObject: NSObject {

    var id: String = ""
    var title: String = ""
    var descr: String = ""
    var type: RequestType = RequestType.OTHER

    var requesterId: String = ""
    var requesterName: String = ""
    var requesterPhone: String = ""
    var requesterEmail: String = ""

    var redeem_coin_amount: Int = 0
    var paymentMethod: PaymentType = PaymentType.PAYPAL
    var paymentEmail: String = ""
    var hasResolved: Bool = false
    
    func uploadObjectToFirebase(_ dbRef: DatabaseReference) {
        let cId = Global.getCurrentTimeintervalString()
        dbRef.child(cId).updateChildValues(getJsonvalue())
    }
    
    func getJsonvalue() -> [String:Any] {
        return [RequestConstant.REQUEST_ID      : self.id,
                RequestConstant.TITLE           : self.title,
                RequestConstant.DESCRIPTION     : self.descr,
                RequestConstant.REQUEST_TYPE    : self.type.rawValue,
                
                RequestConstant.REQUESTER_ID    : self.requesterId,
                RequestConstant.REQUESTER_NAME  : self.requesterName,
                RequestConstant.REQUESTER_EMAIL : self.requesterEmail,
                RequestConstant.REQUESTER_PHONE : self.requesterPhone,
                
                RequestConstant.COIN_AMOUNT     : self.redeem_coin_amount,
                RequestConstant.PAYMENT_METHOD  : self.paymentMethod.rawValue,
                RequestConstant.PAYMENT_EMAIL   : self.paymentEmail,
                RequestConstant.HAS_RESOLVED    : self.hasResolved ]
    }
    
    func initObjectWithJsonresponse(value: NSDictionary) {
        self.id             = value[RequestConstant.REQUEST_ID] as? String ?? ""
        self.title          = value[RequestConstant.TITLE] as? String ?? ""
        self.descr          = value[RequestConstant.DESCRIPTION] as? String ?? ""

        self.requesterId    = value[RequestConstant.REQUESTER_ID] as? String ?? ""
        self.requesterName  = value[RequestConstant.REQUESTER_NAME] as? String ?? ""
        self.requesterPhone = value[RequestConstant.REQUESTER_PHONE] as? String ?? ""
        self.requesterEmail = value[RequestConstant.REQUESTER_EMAIL] as? String ?? ""
        
        self.redeem_coin_amount = value[RequestConstant.COIN_AMOUNT] as? Int ?? 0
        self.paymentEmail   = value[RequestConstant.PAYMENT_EMAIL] as? String ?? ""
        self.hasResolved    = value[RequestConstant.HAS_RESOLVED] as? Bool ?? false
        
        let rtype = value[RequestConstant.REQUEST_TYPE] as? String ?? ""
        self.type = RequestType.init(rawValue: rtype) ?? .OTHER
        
        let ptype = value[RequestConstant.PAYMENT_METHOD] as? String ?? ""
        self.paymentMethod = PaymentType.init(rawValue: ptype) ?? .PAYPAL
    }
}
