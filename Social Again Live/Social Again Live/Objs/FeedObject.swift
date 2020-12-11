//
//  FeedObject.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import Firebase

struct FeedConstant {
    
    static let ID               = "postId"
    static let TITLE            = "title"
    static let DESCRIPTION      = "description"
    static let POST_URL         = "postUrl"
    static let THUMB_URL        = "thumbUrl"
    static let OWNER_URL        = "ownerUrl"
    static let OWNER_ID         = "ownerId"
    static let CAN_SHARED       = "canShared"
    static let TYPE             = "type"
    static let LIKES            = "likes"
    static let COMMENTS         = "comments"
    static let VIEWS            = "views"    
}

class FeedObject: BaseFeedObject {
    
    var title: String           = ""
    var descriptions: String    = ""
    var postUrl: String         = ""
    var thumbUrl: String        = ""
    var ownerUrl: String        = ""
    var ownerId: String         = ""
    var canShared: Bool         = false
    
    var type: PostType          = .IMAGE
    var likes: [[String: NSDictionary]]     = []
    var comments: [[String: NSDictionary]]  = []
    var views: [[String: String]]           = []
    
    override func uploadObjectToFirebase(_ dbUrl: String = POST_DB_NAME) {
        let leadRef = Database.database().reference().child(dbUrl).child(self.postId)
        leadRef.updateChildValues([ FeedConstant.ID             : self.postId,
                                    FeedConstant.TITLE          : self.title,
                                    FeedConstant.DESCRIPTION    : self.descriptions,
                                    FeedConstant.POST_URL       : self.postUrl,
                                    FeedConstant.THUMB_URL      : self.thumbUrl,
                                    FeedConstant.OWNER_URL      : self.ownerUrl,
                                    FeedConstant.OWNER_ID       : self.ownerId,
                                    FeedConstant.CAN_SHARED     : self.canShared,
                                    FeedConstant.TYPE           : self.type.rawValue
                                    ])
    }
    
    override func initUserWithJsonresponse(value: NSDictionary) {
        self.postId = value[FeedConstant.ID] as? String ?? ""
        self.title = value[FeedConstant.TITLE] as? String ?? ""
        self.descriptions = value[FeedConstant.DESCRIPTION] as? String ?? ""
        self.postUrl = value[FeedConstant.POST_URL] as? String ?? ""
        self.thumbUrl = value[FeedConstant.THUMB_URL] as? String ?? ""
        self.ownerUrl = value[FeedConstant.OWNER_URL] as? String ?? ""
        self.ownerId = value[FeedConstant.OWNER_ID] as? String ?? ""
        self.canShared = value[FeedConstant.CAN_SHARED] as? Bool ?? false
        let type = value[FeedConstant.TYPE] as? String ?? "IMAGE"
        self.type = PostType.init(rawValue: type)!
        
        self.likes = value[FeedConstant.LIKES] as? [[String: NSDictionary]] ?? []
        self.comments = value[FeedConstant.COMMENTS] as? [[String: NSDictionary]] ?? []
        self.views = value[FeedConstant.VIEWS] as? [[String: String]] ?? []
    }

}
