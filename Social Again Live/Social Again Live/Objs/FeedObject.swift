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
    
    var type: PostType                  = .IMAGE
    var likes: [BaseUserObject]         = []
    var comments: [FeedCommentObject]   = []
    var views: [NSDictionary]           = []
    
    // No Firebase Options
    var isShowLikes: Bool       = false
    
    override func uploadObjectToFirebase(_ dbUrl: String = POST_DB_NAME) {
        let leadRef = Database.database().reference().child(dbUrl).child(self.postId)
        leadRef.updateChildValues(self.getFeedJsonValue())
    }
    
    func getFeedJsonValue() -> [String: Any] {
        return [ FeedConstant.ID             : self.postId,
                 FeedConstant.TITLE          : self.title,
                 FeedConstant.DESCRIPTION    : self.descriptions,
                 FeedConstant.POST_URL       : self.postUrl,
                 FeedConstant.THUMB_URL      : self.thumbUrl,
                 FeedConstant.OWNER_URL      : self.ownerUrl,
                 FeedConstant.OWNER_ID       : self.ownerId,
                 FeedConstant.CAN_SHARED     : self.canShared,
                 FeedConstant.TYPE           : self.type.rawValue
                 ]
    }
    
    override func initObjectWithJsonresponse(value: NSDictionary) {
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
        
        self.likes.removeAll()
        if let dicValue = value[FeedConstant.LIKES] as? NSDictionary {
            for value in dicValue.allValues {
                if let data = value as? NSDictionary {
                    let userObj = BaseUserObject()
                    userObj.initUserWithJsonresponse(value: data)
                    self.likes.append(userObj)
                }
            }
        }
        self.comments.removeAll()
        if let dicValue = value[FeedConstant.COMMENTS] as? NSDictionary {
            for value in dicValue.allValues {
                if let data = value as? NSDictionary {
                    let fcObj = FeedCommentObject()
                    fcObj.initObjectWithJsonresponse(value: data)
                    
                    self.comments.append(fcObj)
                }
            }
        }
        self.views.removeAll()
        if let dicValue = value[FeedConstant.VIEWS] as? NSDictionary {
            for value in dicValue.allValues {
                if let data = value as? NSDictionary {
                    self.views.append(data)
                }
            }
        }
    }
    
    func getLikedValue() -> Bool {
        var isLiked = false;
        for userObj in self.likes {
            if Global.mCurrentUser!.id == userObj.id {
                isLiked = true
                break
            }
        }

        return isLiked;
    }

}
