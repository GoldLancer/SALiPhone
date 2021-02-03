//
//  FeedCommentObject.swift
//  Social Again Live
//
//  Created by Anton Yagov on 16.12.2020.
//

import UIKit
import Firebase

struct FeedCommentConstant {
    
    static let COMMENT_ID           = "commentId"
    static let POST_ID              = "postId"
    static let COMMENTER_ID         = "commenterId"
    static let COMMENTER_NAME       = "commenterName"
    static let COMMENT              = "comment"
}

class FeedCommentObject: NSObject {

    var commentId: String       = "";
    var postId: String          = "";
    var commenterId: String     = "";
    var commenterName: String   = "";
    var comment: String         = "";
    
    func uploadObjectToFirebase(_ dbUrl: String) {
        let dbRef = Database.database().reference().child(dbUrl).child(self.commentId)
        dbRef.updateChildValues(getJsonvalue())
    }
    
    func getJsonvalue() -> [String:Any] {
        return [FeedCommentConstant.COMMENT_ID      : self.commentId,
                FeedCommentConstant.POST_ID         : self.postId,
                FeedCommentConstant.COMMENTER_ID    : self.commenterId,
                FeedCommentConstant.COMMENTER_NAME  : self.commenterName,
                FeedCommentConstant.COMMENT         : self.comment]
    }
    
    func initObjectWithJsonresponse(value: NSDictionary) {
        self.commentId      = value[FeedCommentConstant.COMMENT_ID] as? String ?? ""
        self.postId         = value[FeedCommentConstant.POST_ID] as? String ?? ""
        self.commenterId    = value[FeedCommentConstant.COMMENTER_ID] as? String ?? ""
        self.commenterName  = value[FeedCommentConstant.COMMENTER_NAME] as? String ?? ""
        self.comment        = value[FeedCommentConstant.COMMENT] as? String ?? ""
    }
}
