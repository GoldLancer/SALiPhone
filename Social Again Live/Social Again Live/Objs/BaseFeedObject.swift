//
//  BaseFeedObject.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import Firebase

class BaseFeedObject: NSObject {
    
    var postId: String      = ""
    
    func uploadObjectToFirebase(_ dbUrl: String = POST_DB_NAME) {
        let leadRef = Database.database().reference().child(dbUrl).child(self.postId)
        leadRef.updateChildValues(self.getJsonValue())
    }
    
    func getJsonValue() -> [String: Any] {
        return [FeedConstant.ID : self.postId]
    }
    
    func initObjectWithJsonresponse(value: NSDictionary) {
        self.postId = value[FeedConstant.ID] as? String ?? ""
    }
    
}
