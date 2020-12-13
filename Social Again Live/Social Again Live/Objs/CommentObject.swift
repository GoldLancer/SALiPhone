//
//  CommentObject.swift
//  Social Again Live
//
//  Created by Anton Yagov on 11.12.2020.
//

import UIKit
import Firebase

struct CommentConstant {
    
    static let USER_ID              = "userId"
    static let OWNER_NAME           = "userName"
    static let MESSAGE              = "message"
    static let USER_LEVEL           = "userLevel"
    static let SOUND_NAME           = "rawValue"
    static let RESOURCE_ID          = "resourceValue"
    static let TYPE                 = "type"
}

class CommentObject: NSObject {

    var userId: String      = ""
    var userName: String    = ""
    var message: String     = ""
    var rawValue: String    = ""
    
    var userLevel: Int      = 0
    var resourceId: Int     = 0

    var type: CommentType = .COMMENT
    
    func uploadObjectToFirebase(_ dbUrl: String) {
        let cId = Global.getCurrentTimeintervalString()
        let dbRef = Database.database().reference().child(dbUrl).child(cId)
        dbRef.updateChildValues(getJsonvalue())
    }
    
    func getJsonvalue() -> [String:Any] {
        return [CommentConstant.USER_ID     : self.userId,
                CommentConstant.OWNER_NAME  : self.userName,
                CommentConstant.MESSAGE     : self.message,
                CommentConstant.SOUND_NAME  : self.rawValue,
                
                CommentConstant.USER_LEVEL  : self.userLevel,
                CommentConstant.RESOURCE_ID : self.resourceId,
                
                CommentConstant.TYPE        : self.type.rawValue]
    }
    
    func initUserWithJsonresponse(value: NSDictionary) {
        self.userId         = value[CommentConstant.USER_ID] as? String ?? ""
        self.userName       = value[CommentConstant.OWNER_NAME] as? String ?? ""
        self.message        = value[CommentConstant.MESSAGE] as? String ?? ""
        self.rawValue       = value[CommentConstant.SOUND_NAME] as? String ?? ""
        
        self.userLevel      = value[CommentConstant.USER_LEVEL] as? Int ?? 0
        self.resourceId     = value[CommentConstant.RESOURCE_ID] as? Int ?? 0
        
        let type = value[CommentConstant.TYPE] as? String ?? ""
        self.type = CommentType.init(rawValue: type) ?? .COMMENT
    }
    
}
