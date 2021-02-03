//
//  BaseUserObject.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import Firebase

class BaseUserObject: NSObject {
    
    var id: String          = ""
    var name: String        = ""
    var country: String     = ""
    var gender: String      = ""
    var email: String       = ""
    var phone: String       = ""

    var accountType: AccountType = .EMAIL
    
    func uploadObjectToFirebase(_ dbUrl: String = USER_DB_NAME) {
        let leadRef = Database.database().reference().child(dbUrl).child(self.id)
        leadRef.updateChildValues(getBaseJsonvalue())
    }
    
    func getBaseJsonvalue() -> [String:Any] {
        return [UserConstant.ID        : self.id,
                UserConstant.NAME      : self.name,
                UserConstant.COUNTRY   : self.country,
                UserConstant.GENDER    : self.gender,
                UserConstant.EMAIL     : self.email,
                UserConstant.PHONE     : self.phone,
                UserConstant.TYPE      : self.accountType.rawValue]
    }
    
    func initUserWithJsonresponse(value: NSDictionary) {
        self.id = value[UserConstant.ID] as? String ?? ""
        self.name = value[UserConstant.NAME] as? String ?? ""
        self.country = value[UserConstant.COUNTRY] as? String ?? ""
        self.gender = value[UserConstant.GENDER] as? String ?? ""
        self.email = value[UserConstant.EMAIL] as? String ?? ""
        self.phone = value[UserConstant.PHONE] as? String ?? ""
        let type = value[UserConstant.TYPE] as? String ?? ""
        self.accountType = AccountType.init(rawValue: type) ?? .GMAIL
    }
}
