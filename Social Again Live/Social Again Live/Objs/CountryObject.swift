//
//  CountryObject.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import Firebase

struct CountryConstant {
    
    static let COUNTRY_NAME         = "name"
    static let COUNTRY_CODE         = "countryCode"
    static let FLAG_ID              = "flagRSId"
}

class CountryObject: NSObject {
    
    var name: String        = ""
    var countryCode: String = ""
//    var flagRSId: Int       = 0 // only for Android
    
    func initCountryWithJsonresponse(value: NSDictionary) {
        self.name = value[CountryConstant.COUNTRY_NAME] as? String ?? ""
        self.countryCode = value[CountryConstant.COUNTRY_CODE] as? String ?? ""
//        self.flagRSId = value[CountryConstant.FLAG_ID] as? Int ?? 0
    }
    
    func uploadObjectToFirebase(_ dbUrl: String = COUNTRY_DB_NAME) {
        let countryRef = Database.database().reference().child(dbUrl).child(self.name)
        countryRef.updateChildValues(getObjectJsonvalue())
    }
    
    func getObjectJsonvalue() -> [String:Any] {
        return [CountryConstant.COUNTRY_NAME        : self.name,
                CountryConstant.COUNTRY_CODE        : self.countryCode] /* ,
                CountryConstant.FLAG_ID             : self.flagRSId] */
    }
}
