//
//  StreamObject.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import Firebase

struct StreamConstant {
    
    static let ID                   = "streamId"
    static let OWNER                = "owner"
    static let TITLE                = "videoTitle"
    static let THUMBURL             = "videoThumbnail"
    static let COUNTRY              = "country"
    static let CREATED              = "created"
    static let CATEGORY             = "category"
    static let ABOUT_URL            = "aboutUrl"
    
    static let TUCOINS              = "tuCoins"
    static let WATCHERS             = "watchers"
    
    static let IS_GHOST             = "isGhost"
    static let IS_ONLINE            = "isOnline"
    static let IS_PAUSED            = "paused"
    
    static let COMMENTS             = "comments"
    static let JOINERS              = "joiners"
}

class StreamObject: NSObject {
    
    var owner: BaseUserObject   = BaseUserObject()
    var streamId: String        = ""
    var videoTitle: String      = ""
    var videoThumbnail: String  = ""
    var country: String         = ""
    var created: String         = ""
    var category: String        = ""
    var aboutUrl: String        = ""
    
    var tuCoins: Int            = 0
    var watchers: Int           = 0
    
    var isGhost: Bool           = false
    var isOnline: Bool          = false
    var paused: Bool            = false
    
    var comments: [CommentObject] = []
    var joiners: [BaseUserObject] = []
    
    
    func uploadObjectToFirebase(_ dbUrl: String = VIDEO_DB_NAME) {
        let streamRef = Database.database().reference().child(dbUrl).child(self.streamId)
        streamRef.updateChildValues([ StreamConstant.ID        : self.streamId,
                                      StreamConstant.TITLE     : self.videoTitle,
                                      StreamConstant.THUMBURL  : self.videoThumbnail,
                                      StreamConstant.COUNTRY   : self.country,
                                      StreamConstant.CREATED   : self.created,
                                      StreamConstant.CATEGORY  : self.category,
                                      StreamConstant.ABOUT_URL : self.aboutUrl,
                                      
                                      StreamConstant.TUCOINS   : self.tuCoins,
                                      StreamConstant.WATCHERS  : self.watchers,
                                      
                                      StreamConstant.IS_GHOST  : self.isGhost,
                                      StreamConstant.IS_ONLINE : self.isOnline,
                                      StreamConstant.IS_PAUSED : self.paused,
                                      
                                      StreamConstant.OWNER     : self.owner.getJsonvalue()
                                    ])
    }
    
    func initUserWithJsonresponse(value: NSDictionary) {
        self.streamId       = value[StreamConstant.ID] as? String ?? ""
        self.videoTitle     = value[StreamConstant.TITLE] as? String ?? ""
        self.videoThumbnail = value[StreamConstant.THUMBURL] as? String ?? ""
        self.country        = value[StreamConstant.COUNTRY] as? String ?? ""
        self.created        = value[StreamConstant.CREATED] as? String ?? ""
        self.category       = value[StreamConstant.CATEGORY] as? String ?? ""
        self.aboutUrl       = value[StreamConstant.ABOUT_URL] as? String ?? ""
        
        self.tuCoins        = value[StreamConstant.TUCOINS] as? Int ?? 0
        self.watchers       = value[StreamConstant.WATCHERS] as? Int ?? 0
        
        self.isGhost        = value[StreamConstant.IS_GHOST] as? Bool ?? false
        self.isOnline       = value[StreamConstant.IS_ONLINE] as? Bool ?? false
        self.paused         = value[StreamConstant.IS_PAUSED] as? Bool ?? false
        
        if let ownerData = value[StreamConstant.OWNER] as? NSDictionary {
            self.owner.initUserWithJsonresponse(value: ownerData)
        }
        
        self.comments.removeAll()
        if let commentArray = value[StreamConstant.COMMENTS] as? [NSDictionary] {
            for cData in commentArray {
                
            }
        }
        
        self.joiners.removeAll()
        if let joinerArray = value[StreamConstant.JOINERS] as? [NSDictionary] {
            for jData in joinerArray {
                
            }
        }
        
    }
}
