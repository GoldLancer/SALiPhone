//
//  ChatObject.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import Firebase

struct ChatConstant {
    static let CHAT_ID          = "chatId"
    static let LAST_MESSAGE     = "lastMsg"
    static let USERS            = "users"
    static let MESSAGES         = "messages"
}

class ChatObject: NSObject {

    var chatId: String          = ""
    var lastMsg: MsgObj         = MsgObj()
    
    var users: [BaseUserObject] = []
    var messages: [MsgObj]      = []
    
    func uploadToFirebase(_ path: String) {
        let chatroomRef = Database.database().reference().child(MSG_DB_NAME)
        chatroomRef.child(self.chatId).updateChildValues([ChatConstant.CHAT_ID : self.chatId])
        
        for user in self.users {
            chatroomRef.child(self.chatId).child(ChatConstant.USERS).child(user.id).setValue(user.getBaseJsonvalue())
        }
        if !self.lastMsg.msgId.isEmpty {
            chatroomRef.child(self.chatId).child(ChatConstant.LAST_MESSAGE).setValue(self.lastMsg.getJsonvalue())
            chatroomRef.child(self.chatId).child(ChatConstant.MESSAGES).child(self.lastMsg.msgId).setValue(self.lastMsg.getJsonvalue())
        }
    }
    
    func initChatObjWithJsonresponse(value: NSDictionary) {
        self.chatId = value[ChatConstant.CHAT_ID] as? String ?? ""
        
        if let lastMsgData = value[ChatConstant.LAST_MESSAGE] as? NSDictionary {
            self.lastMsg.initMessageWithJsonresponse(value: lastMsgData)
        }
        
        self.users.removeAll()
        if let dicValue = value[ChatConstant.USERS] as? NSDictionary {
            for value in dicValue.allValues {
                if let data = value as? NSDictionary {
                    let userObj = BaseUserObject()
                    userObj.initUserWithJsonresponse(value: data)
                    
                    self.users.append(userObj)
                }
            }
        }
        
        self.messages.removeAll()
        if let dicValue = value[ChatConstant.MESSAGES] as? NSDictionary {
            for value in dicValue.allValues {
                if let data = value as? NSDictionary {
                    let msgObj = MsgObj()
                    msgObj.initMessageWithJsonresponse(value: data)
                    
                    self.messages.append(msgObj)
                }
            }
        }
    }
}
