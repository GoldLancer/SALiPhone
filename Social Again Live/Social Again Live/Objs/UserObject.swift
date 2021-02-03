//
//  UserObject.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import Firebase

struct UserConstant {
    
    static let ID               = "id"
    static let NAME             = "name"
    static let COUNTRY          = "country"
    static let GENDER           = "gender"
    static let EMAIL            = "email"
    static let PHONE            = "phone"
    static let TYPE             = "accountType"
    
    static let TOKEN            = "token"
    static let AVATAR           = "avatar"
    static let NAMELOWER        = "nameLower"
    static let PASSWD           = "password"
    static let ABOUTME          = "aboutme"
    static let CATEGORY         = "category"
    static let BIRTH_YEAR       = "birthYear"
    static let BIRTH_MONTH      = "birthMonth"
    static let BIRTH_DAY        = "birthDay"

    static let CITY             = "city"
    static let STATE            = "state"
    static let ZIPCODE          = "zipcode"
    static let COVER            = "cover"
    static let ANYURL           = "anyUrl"
    static let REFFURL          = "reffUrl"
    static let STREAMID         = "streamID"
    static let COIN             = "coin"
    static let EARNED           = "earned"

    static let IS_UPGRADED      = "isUpgraded"
    static let IS_BLASTER       = "isBlaster"
    static let IS_RADIO         = "isRadio"
    static let IS_PULSE         = "isPulse"
    static let IS_SPONSOR       = "isSponsor"
    static let IS_BEGINNER      = "isBeginner"
    static let IS_VERIFIED      = "isVerified"

    static let LEVEL            = "level"
    static let UPGRADED_TIME    = "upgraded_time"
    static let LATEST_LOGIN     = "latest_login"
    static let BOUGTH_TIME      = "boughtTimes"
    static let BLASTER_COUNT    = "blasterCount"
    static let BLASTER_MONTH    = "blasterMonth"
    
    static let FOLLOWINGS       = "followings"
    static let FOLLOWERS        = "followers"
    static let LIKES            = "likes"
    static let POSTS            = "posts"
    static let BLASTERS         = "blasters"
    static let TRANSACTIONS     = "transactions"
    
    static let CLICKABLE_IMAGE_URL = "clickableImgURL"
    static let CLICKABLE_URL    = "clickableURL"
}

class UserObject: BaseUserObject {

    var token: String       = ""
    var avatar: String      = ""
    var nameLower: String   = ""
    var password: String    = ""
    var aboutme: String     = ""
    var category: String    = "Music"
    var birthYear: Int      = 0
    var birthMonth: Int     = 1
    var birthDay: Int       = 1

    var city: String        = ""
    var state: String       = ""
    var zipcode: String     = ""
    var isUpgraded: Bool    = false
    var cover: String       = ""
    var anyUrl: String      = ""
    var reffUrl: String     = ""
    var streamID: String    = ""
    var coin: Int           = 10
    var earned: Double      = 0
    
    var clickableImgURL: String = "";
    var clickableURL: String    = "";

    var isBlaster: Bool     = false
    var isRadio: Bool       = false
    var isPulse: Bool       = false
    var isSponsor: Bool     = false
    var isBeginner: Bool    = true

    var level: Int              = 0
    var upgraded_time: UInt64   = 0
    var latest_login: UInt64    = 0
    var boughtTimes: UInt64     = 0
    var blasterCount: Int   = 5
    var blasterMonth: Int   = 0
    var isVerified: Bool    = false
    
    var followings: [BaseUserObject] = []
    var followers:  [BaseUserObject] = []
    var likes:      [BaseUserObject] = []
    var posts:      [BaseFeedObject] = []
    var blasters:   [BlasterObject]  = []
    var transactions: [TransObject]  = []
    
    override func uploadObjectToFirebase(_ dbUrl: String = USER_DB_NAME) {
        
        let userRef = Database.database().reference().child(dbUrl).child(self.id)
        userRef.updateChildValues([ UserConstant.ID             : self.id,
                                    UserConstant.NAME           : self.name,
                                    UserConstant.COUNTRY        : self.country,
                                    UserConstant.GENDER         : self.gender,
                                    UserConstant.EMAIL          : self.email,
                                    UserConstant.PHONE          : self.phone,
                                    UserConstant.TYPE           : self.accountType.rawValue,
                                    
                                    UserConstant.TOKEN          : self.token,
                                    UserConstant.AVATAR         : self.avatar,
                                    UserConstant.NAMELOWER      : self.nameLower,
                                    UserConstant.PASSWD         : self.password,
                                    UserConstant.ABOUTME        : self.aboutme,
                                    UserConstant.CATEGORY       : self.category,
                                    UserConstant.BIRTH_YEAR     : self.birthYear,
                                    UserConstant.BIRTH_MONTH    : self.birthMonth,
                                    UserConstant.BIRTH_DAY      : self.birthDay,
                                    UserConstant.CITY           : self.city,
                                    UserConstant.STATE          : self.state,
                                    UserConstant.ZIPCODE        : self.zipcode,
                                    UserConstant.IS_UPGRADED    : self.isUpgraded,
                                    UserConstant.COVER          : self.cover,
                                    UserConstant.ANYURL         : self.anyUrl,
                                    UserConstant.STREAMID       : self.streamID,
                                    UserConstant.COIN           : self.coin,
                                    UserConstant.EARNED         : self.earned,
                                    
                                    UserConstant.IS_BLASTER     : self.isBlaster,
                                    UserConstant.IS_RADIO       : self.isRadio,
                                    UserConstant.IS_PULSE       : self.isPulse,
                                    UserConstant.IS_SPONSOR     : self.isSponsor,
                                    UserConstant.IS_BEGINNER    : self.isBeginner,
                                    
                                    UserConstant.LEVEL          : self.level,
                                    UserConstant.UPGRADED_TIME  : self.upgraded_time,
                                    UserConstant.LATEST_LOGIN   : self.latest_login,
                                    UserConstant.BOUGTH_TIME    : self.boughtTimes,
                                    UserConstant.BLASTER_COUNT  : self.blasterCount,
                                    UserConstant.BLASTER_MONTH  : self.blasterMonth,
                                    UserConstant.IS_VERIFIED    : self.isVerified,
                                    
                                    UserConstant.CLICKABLE_IMAGE_URL : self.clickableImgURL,
                                    UserConstant.CLICKABLE_URL  : self.clickableURL
                                    
                                    ])
        
    }
    
    override func initUserWithJsonresponse(value: NSDictionary) {
        
        super.initUserWithJsonresponse(value: value)
        
        self.token      = value[UserConstant.TOKEN]     as? String ?? ""
        self.avatar     = value[UserConstant.AVATAR]    as? String ?? ""
        self.nameLower  = value[UserConstant.NAMELOWER] as? String ?? ""
        self.password   = value[UserConstant.PASSWD]    as? String ?? ""
        self.aboutme    = value[UserConstant.ABOUTME]   as? String ?? ""
        self.category   = value[UserConstant.CATEGORY]  as? String ?? ""
        self.city       = value[UserConstant.CITY]      as? String ?? ""
        self.state      = value[UserConstant.STATE]     as? String ?? ""
        self.zipcode    = value[UserConstant.ZIPCODE]   as? String ?? ""
        self.cover      = value[UserConstant.COVER]     as? String ?? ""
        self.anyUrl     = value[UserConstant.ANYURL]    as? String ?? ""
        self.streamID   = value[UserConstant.STREAMID]  as? String ?? ""
        
        self.clickableURL    = value[UserConstant.CLICKABLE_URL]        as? String ?? ""
        self.clickableImgURL = value[UserConstant.CLICKABLE_IMAGE_URL]  as? String ?? ""
        
        self.isUpgraded = value[UserConstant.IS_UPGRADED]   as? Bool ?? false
        self.isBlaster  = value[UserConstant.IS_BLASTER]    as? Bool ?? false
        self.isRadio    = value[UserConstant.IS_RADIO]      as? Bool ?? false
        self.isPulse    = value[UserConstant.IS_PULSE]      as? Bool ?? false
        self.isSponsor  = value[UserConstant.IS_SPONSOR]    as? Bool ?? false
        self.isBeginner = value[UserConstant.IS_BEGINNER]   as? Bool ?? false
        self.isVerified = value[UserConstant.IS_VERIFIED]   as? Bool ?? false
        
        self.coin       = value[UserConstant.COIN]          as? Int ?? 10
        self.level      = value[UserConstant.LEVEL]         as? Int ?? 0
        self.birthYear  = value[UserConstant.BIRTH_YEAR]    as? Int ?? 0
        self.birthMonth = value[UserConstant.BIRTH_MONTH]   as? Int ?? 0
        self.birthDay   = value[UserConstant.BIRTH_DAY]     as? Int ?? 0
        self.earned     = value[UserConstant.EARNED]        as? Double ?? 0
        
        self.blasterCount   = value[UserConstant.BLASTER_COUNT]   as? Int ?? 0
        self.blasterMonth   = value[UserConstant.BLASTER_MONTH]   as? Int ?? 0
        self.latest_login   = value[UserConstant.LATEST_LOGIN]    as? UInt64 ?? 0
        self.boughtTimes    = value[UserConstant.BOUGTH_TIME]     as? UInt64 ?? 0
        self.upgraded_time  = value[UserConstant.UPGRADED_TIME]   as? UInt64 ?? 0
        
        self.followers.removeAll()
        if let dicValue = value[UserConstant.FOLLOWERS] as? NSDictionary {
            for value in dicValue.allValues {
                if let data = value as? NSDictionary {
                    let userObj = BaseUserObject()
                    userObj.initUserWithJsonresponse(value: data)
                    
                    self.followers.append(userObj)
                }
            }
        }
        self.followings.removeAll()
        if let dicValue = value[UserConstant.FOLLOWINGS] as? NSDictionary {
            for value in dicValue.allValues {
                if let data = value as? NSDictionary {
                    let userObj = BaseUserObject()
                    userObj.initUserWithJsonresponse(value: data)
                    
                    self.followings.append(userObj)
                }
            }
        }
        self.likes.removeAll()
        if let dicValue = value[UserConstant.LIKES] as? NSDictionary {
            for value in dicValue.allValues {
                if let data = value as? NSDictionary {
                    let userObj = BaseUserObject()
                    userObj.initUserWithJsonresponse(value: data)
                    
                    self.likes.append(userObj)
                }
            }
        }
        self.posts.removeAll()
        if let dicValue = value[UserConstant.POSTS] as? NSDictionary {
            for value in dicValue.allValues {
                if let data = value as? NSDictionary {
                    let postObj = BaseFeedObject()
                    postObj.initObjectWithJsonresponse(value: data)
                    
                    self.posts.append(postObj)
                }
            }
        }
    }
    
    func copyBaseUserObject() -> BaseUserObject {
        let userObj = BaseUserObject()
        userObj.id          = self.id
        userObj.accountType = self.accountType
        userObj.country     = self.country
        userObj.email       = self.email
        userObj.gender      = self.gender
        userObj.name        = self.name
        userObj.phone       = self.phone
        
        return userObj
    }
    
    func copyBaseValues(_ baseObj: BaseUserObject) {
        self.id             = baseObj.id
        self.accountType    = baseObj.accountType
        self.country        = baseObj.country
        self.email          = baseObj.email
        self.gender         = baseObj.gender
        self.name           = baseObj.name
        self.phone          = baseObj.phone
    }
}
