//
//  MsgObj.swift
//  Social Again Live
//
//  Created by Anton Yagov on 14.01.2021.
//

import UIKit

struct MsgConstant {
    static let MSG_ID           = "msgId"
    static let SENDER_ID        = "senderId"
    static let RECEIVER_ID      = "receiverId"
    static let MESSAGE          = "message"
    static let PICTURE_URL      = "pictureUrl"
    static let AUDIO_URL        = "audioUrl"
    static let AUDIO_LOCAL_URL  = "audioLocalUrl"
    static let VIDEO_URL        = "videoUrl"
    static let VIDEO_LOCAL_URL  = "videoLocalUrl"
    static let METADATA         = "metadata"
    static let BLASTER_TITLE    = "blasterTitle"
    static let BLASTER_IMAGE    = "blasterImg"
    static let BLASTER_YOUTUBE  = "blasterYoutube"
    static let AUDIO_DURATION   = "audioDuration"
    static let MESSAGE_TIME     = "msgTime"
    static let TYPE             = "type"
}

class MsgObj: NSObject {

    var msgId: String           = ""
    var senderId: String        = ""
    var receiverId: String      = ""
    var message: String         = ""
    var pictureUrl: String      = ""
    var audioUrl: String        = ""
    var audioLocalUrl: String   = ""
    var videoUrl: String        = ""
    var videoLocalUrl: String   = ""
    var metadata: String        = ""
    var blasterTitle: String    = ""
    var blasterImg: String      = ""
    var blasterYoutube: String  = ""
    var audioDuration: Int      = 0
    var msgTime: UInt64         = 0

    var type: MsgType           = .TEXT
    
    func getJsonvalue() -> [String:Any] {
        return [MsgConstant.MSG_ID          : self.msgId,
                MsgConstant.SENDER_ID       : self.senderId,
                MsgConstant.RECEIVER_ID     : self.receiverId,
                MsgConstant.MESSAGE         : self.message,
                MsgConstant.PICTURE_URL     : self.pictureUrl,
                MsgConstant.AUDIO_URL       : self.audioUrl,
                MsgConstant.AUDIO_LOCAL_URL : self.audioLocalUrl,
                MsgConstant.VIDEO_URL       : self.videoUrl,
                MsgConstant.VIDEO_LOCAL_URL : self.videoLocalUrl,
                MsgConstant.METADATA        : self.metadata,
                MsgConstant.BLASTER_TITLE   : self.blasterTitle,
                MsgConstant.BLASTER_IMAGE   : self.blasterImg,
                MsgConstant.BLASTER_YOUTUBE : self.blasterYoutube,
                MsgConstant.AUDIO_DURATION  : self.audioDuration,
                MsgConstant.MESSAGE_TIME    : self.msgTime,
                
                MsgConstant.TYPE            : self.type.rawValue]
    }
    
    func initMessageWithJsonresponse(value: NSDictionary) {
        self.msgId = value[MsgConstant.MSG_ID] as? String ?? ""
        self.senderId = value[MsgConstant.SENDER_ID] as? String ?? ""
        self.receiverId = value[MsgConstant.RECEIVER_ID] as? String ?? ""
        self.message = value[MsgConstant.MESSAGE] as? String ?? ""
        self.pictureUrl = value[MsgConstant.PICTURE_URL] as? String ?? ""
        self.audioUrl = value[MsgConstant.AUDIO_URL] as? String ?? ""
        self.audioLocalUrl = value[MsgConstant.AUDIO_LOCAL_URL] as? String ?? ""
        self.videoUrl = value[MsgConstant.VIDEO_URL] as? String ?? ""
        self.videoLocalUrl = value[MsgConstant.VIDEO_LOCAL_URL] as? String ?? ""
        self.metadata = value[MsgConstant.METADATA] as? String ?? ""
        self.blasterTitle = value[MsgConstant.BLASTER_TITLE] as? String ?? ""
        self.blasterImg = value[MsgConstant.BLASTER_IMAGE] as? String ?? ""
        self.blasterYoutube = value[MsgConstant.BLASTER_YOUTUBE] as? String ?? ""
        
        self.audioDuration = value[MsgConstant.AUDIO_DURATION] as? Int ?? 0
        self.msgTime = value[MsgConstant.MESSAGE_TIME] as? UInt64 ?? 0
        
        let type = value[MsgConstant.TYPE] as? String ?? ""
        self.type = MsgType.init(rawValue: type) ?? .TEXT
    }
}
