//
//  Global.swift
//  Pulse Attendance
//
//  Created by Anton Yagov on 10/22/20.
//  Copyright © 2020 Goldlancer. All rights reserved.
//

import UIKit
import PKHUD
import Firebase
import Alamofire

class Global: NSObject {
    /**
    ** Static Global Values **
     */
    
    static var deviceToken: String?             = nil
    
    static var allPostObjs: [FeedObject]        = []
    static var pulsePostObjs: [FeedObject]      = []
    
    static var allStreamObj: [StreamObject]     = []
    static var filterStreamObjs: [StreamObject] = []
    static var mySteamersObjs: [StreamObject]   = []
    
    static var chatObjs: [ChatObject]           = []
    
    static var coinObjs: [CoinObject]           = []
    
    static var myPostObjs: [FeedObject]         = []
    static var followPostObjs: [FeedObject]     = []
    
    static var followingObjs: [BaseUserObject]  = []
    static var followerObjs: [BaseUserObject]   = []
    static var countryObjs: [CountryObject]     = []
    static var notiObjs: [NotiObject]           = []

    static var mCurrentUser: UserObject?        = nil
    static var mCurrentStream: StreamObject?    = nil
    static var mChatObj: ChatObject?            = nil
    static var mForwardObj: FeedObject?         = nil
    static var sentList: [String]               = []
    
    // Setting values
    static var isSettingLikedOrCommented        = false;
    static var isSettingNotiWhenChat            = true;
    static var isSettingNotiInappSound          = true;
    static var isSettingNotiInappVibration      = false;
    static var isSettingNotiLiveBroadcast       = true;

    static var isLoadedStartActivity            = false;
//    static var MainMenuActivity mainMenuActivity = null;
//    static var ChatdetailActivity chatingActivity = null;

    static var monthlyPot                       = 0
    static var likeCount                        = 0
    
    static var ytVideoIndex                     = 0
    
    static let userRef     = Database.database().reference().child(USER_DB_NAME)
    static let postRef     = Database.database().reference().child(POST_DB_NAME)
    static let chatRef     = Database.database().reference().child(MSG_DB_NAME)
    static let videoRef    = Database.database().reference().child(VIDEO_DB_NAME)
    
    // IAP
    static var hasPurchased: Bool = false
    
    // MARK: ALERTVIEW
    class func alertWithText(errorText: String?,
                             title: String                        = "Error",
                             cancelTitle: String                  = "OK",
                             cancelAction: (() -> Void)?          = nil,
                             otherButtonTitle: String?            = nil,
                             otherButtonStyle: UIAlertAction.Style = .default,
                             otherButtonAction: (() -> Void)?     = nil) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: errorText, preferredStyle: .alert)
        
        let handler = cancelAction == nil ? { () -> Void in } : cancelAction
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (alertAction: UIAlertAction!) in handler!() })
        alertController.addAction(cancelAction)
        
        if otherButtonTitle != nil && !otherButtonTitle!.isEmpty &&
            otherButtonAction != nil {
            let otherAction = UIAlertAction(title: otherButtonTitle!, style: otherButtonStyle, handler: { (alertAction: UIAlertAction!) in otherButtonAction!() })
            alertController.addAction(otherAction)
        }
        
        return alertController
    }
    
    class func getChatRoomId(_ otherId: String) -> String {

        if otherId == ADMIN_ID {
            return "\(ADMIN_ID)-\(Global.mCurrentUser!.id)"
        }
        
        var ids: [String] = [Global.mCurrentUser!.id, otherId]
        ids.sort(by: { $0 < $1 })
        
        return "\(ids[0])-\(ids[1])";
    }
    
    class func registerNewPost(_ pObj: FeedObject) {

        let myPost = BaseFeedObject()
        myPost.postId = pObj.postId
        pObj.canShared = Global.mCurrentUser!.isPulse && Global.mCurrentUser!.isUpgraded

        let userRef       = Database.database().reference().child(USER_DB_NAME)
        let postRef       = Database.database().reference().child(POST_DB_NAME)
        userRef.child(Global.mCurrentUser!.id).child(UserConstant.POSTS).child(pObj.postId).setValue(myPost.getJsonValue());
        postRef.child(pObj.postId).setValue(pObj.getFeedJsonValue());

        // Send Push
        /*
        FcmNotificationBuilder.initialize()
                .message("New Post")
                .messageType(MsgType.TEXT)
                .username(GlobalManager.mUserObj.name)
                .senderid(GlobalManager.mUserObj.id)
                .receiverid("ALL")
                .sendingTime(GlobalManager.getCurrentTimeintervalLong())
                .receiverFirebaseToken(GlobalManager.mUserObj.id)
                .send(); */
    }
    
    // MARK: Storage File Name
    class func getVideoStorageRefUrl(_ filename: String) -> String {
        let refUrl = "\(STORAGE_VIDEO_NAME)post_\(filename)_video.mp4"
        return refUrl
    }

    class func getThumbStorageRefUrl(_ filename: String) -> String {
        let refUrl = "\(STORAGE_VIDEO_NAME)post_\(filename)_thumb.jpg"
        return refUrl
    }

    class func getPictureStorageRefUrl(_ filename: String) -> String {
        let refUrl = "\(STORAGE_IMAGE_NAME)post_\(filename)_picture.jpg"
        return refUrl
    }

    class func getBlasterPictureStorageRefUrl(_ filename: String) -> String {
        let refUrl = "\(STORAGE_BLAST_IMAGE_NAME)blaster_\(filename)_picture.jpg"
        return refUrl
    }
    
    // MARK: Time&Date
    class func getCurrentTimeintervalString() -> String {
        return "\(getCurrentTimeintervalUint())"
    }
    
    class func getCurrentTimeintervalUint() -> UInt64 {
        let timestamp = NSDate().timeIntervalSince1970
        return UInt64(timestamp*1000)
    }
    
    class func getPurchseDateTimeFromTimeMillis(_ time: UInt64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time/1000))
        return date.getDateString()
    }

    class func getPurchseEndDateTimeFromTimeMillis(_ time: UInt64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time/1000))
        return date.addMonth(n: 1).getDateString()
    }
    
    class func getMessageSendTime(_ time: UInt64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time/1000))
        return date.getChatTimeString()
    }
    
    class func getStringOfBirth(year: Int, month: Int, day: Int) -> String {
        if year == 0 {
            return ""
        }
        if month > 11 {
            return ""
        }
        if day > 31 || day == 0 {
            return ""
        }

        let birth = "\(MONTH_NAME[month]) \(day), \(year)"
        return birth;
    }    
    
    // MARK: Save USERDEFAULT
    class func saveUserDefaultValue(key: String, value: Any) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    // MARK: String Operations
    class func isValidEmail(_ email: String) -> Bool {
        if email.isEmpty {
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    class func getEncryptedEmail(_ email: String) -> String {
        let start = String.Index(utf16Offset: 2, in: email)
        let end = String.Index(utf16Offset: 7, in: email)
        let substring = String(email[start..<end])
        
        return email.replacingOccurrences(of: substring, with: "*****")
    }
    
    // MARK: MAILGUN API - Sending a Verification CODE
    class func getJsonResponseFromMailgun(_ url: String, params: [String: Any] = [:], method: HTTPMethod = .get, encoding: ParameterEncoding = URLEncoding.default, completion: @escaping (Any?, Error?) -> ()) {
        
        if let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            let apiHeader: HTTPHeaders = ["Authorization" : MAILGUN_API_AUTH]
            Alamofire.request(encoded,
                                  method: method,
                                  parameters: params,
                                  encoding: encoding,
                headers: apiHeader)
                .responseJSON { (response) in
                    
                    switch response.result {
                    case .success(let value):
                        completion(value, nil)
                    case .failure(let error):
                        completion(nil, error)
                    }
            }
        }
    }
    
    // MARK: Delete Stream files from Ant Media Server
    class func deleteOldStreamFiles() {
        let params = [  "type" : "delete_file",
                        "name" : Global.mCurrentUser!.streamID ]
        getJsonResponseFromMailgun(STREAM_API_URL, params: params) { (value, error) in
            
        }
    }
    
    // MARK: Create Stream Channel
    class func createStreamChannel( completionHandler: @escaping (Any?, Error?) -> ()) {
        
        let params = [  "type" : "create_stream",
                        "name" : Global.mCurrentUser!.name ]
        getJsonResponseFromURL(STREAM_API_URL, params: params, completion: completionHandler)
    }
    
    class func getJsonResponseFromURL(_ url: String, params: [String: Any] = [:], method: HTTPMethod = .get, encoding: ParameterEncoding = URLEncoding.default, completion: @escaping (Any?, Error?) -> ()) {
        
        let apiHeader: HTTPHeaders = ["Authorization" : "Basic YXBpOjZhYzE1YzQxY2RjMmMwYjM5MDRmNmFiMzgwOGUwZmNhLTliMWJmNWQzLTBlZDUxYTNl"]
        Alamofire.request(url,
                              method: method,
                              parameters: params,
                              encoding: encoding,
            headers: apiHeader)
            .responseJSON { (response) in
                
                switch response.result {
                case .success(let value):
                    completion(value, nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    class func sendVerificationCode(_ code: String, email: String, completionHandler: @escaping (Any?, Error?) -> ()) {
        
        let title = "SAL Verification Code"
        let mailBody = "<p>Hello, \(Global.mCurrentUser!.name)</p><br></br><p>Your code is: <strong>\(code)</strong></p><br></br><p>SAL Support Team</p>"
        let url = "\(MAILGUN_API_URL)&to=\(email)&subject=\(title)&html=\(mailBody)"
        getJsonResponseFromMailgun(url, method:.post, completion: completionHandler)
    }
    
    class func getVerificationCode() -> String {
        let randomInt = Int.random(in: 100000..<999999)
        
        return "\(randomInt)"
    }
    
    // MARK: GOTO TARGET VIEW
    class func goMainView() {
        
        Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.EMAIL).setValue(Global.mCurrentUser!.email)
        Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.IS_VERIFIED).setValue(true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateInitialViewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = mainVC
    }
    
    class func signoutWithUI() {
        
        let storyboard = UIStoryboard(name: "Register", bundle: nil)
        let loginVC = storyboard.instantiateInitialViewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = loginVC
    }
    
    // MARK: Firebase Data Control
    class func alreadyFollowed(_ userId: String) -> Bool {

        for obj in Global.followerObjs {
            if obj.id == userId {
                return true;
            }
        }

        return false;
    }
    
    // MARK: GET PROFILE PROPERTY
    class func getProfileUrlByID(_ uId: String, completion: @escaping (String) -> ()) {
        let userRef = Database.database().reference().child(USER_DB_NAME)
        userRef.child(uId).child(UserConstant.AVATAR).observeSingleEvent(of: .value) { (snapshot) in
            let profileUrl = snapshot.value as? String ?? ""
            completion(profileUrl)
        }
    }
    
    class func getProfileTokenByID(_ uId: String, completion: @escaping (String) -> ()) {
        let userRef = Database.database().reference().child(USER_DB_NAME)
        userRef.child(uId).child(UserConstant.TOKEN).observeSingleEvent(of: .value) { (snapshot) in
            let deviceToken = snapshot.value as? String ?? ""
            completion(deviceToken)
        }
    }
    
    class func getProfileNameByID(_ uId: String, completion: @escaping (String) -> ()) {
        let userRef = Database.database().reference().child(USER_DB_NAME)
        userRef.child(uId).child(UserConstant.NAME).observeSingleEvent(of: .value) { (snapshot) in
            let profileName = snapshot.value as? String ?? ""
            completion(profileName)
        }
    }
    
    // Get Number of user's coin by ID
    class func getUserCoinByID(_ userId: String, completion: @escaping (Int) -> ()) {
        let userRef = Database.database().reference().child(USER_DB_NAME)
        userRef.child(userId).child(UserConstant.COIN).observeSingleEvent(of: .value) { (snapshot) in
            let coin = snapshot.value as? Int ?? 0
            completion(coin)
        }
    }
    
    // Add Pot
    class func upgradeMonthlyPot() {
        let dbRef = Database.database().reference().child(MONTHLY_POT_DB_NAME)
        dbRef.observeSingleEvent(of: .value) { (snapshot) in
            let pot = snapshot.value as? Int ?? 0

            Global.monthlyPot = pot + 100
            dbRef.setValue(Global.monthlyPot)
        }
    }
    
    class func upgradeMyPosts() {
        let canShared = Global.mCurrentUser!.isPulse && Global.mCurrentUser!.isUpgraded
        
        for postObj in Global.myPostObjs {
            postObj.canShared = canShared
            Global.postRef.child(postObj.postId).child(FeedConstant.CAN_SHARED).setValue(canShared)
        }
    }
    
    class func followUser(_ userId: String) -> Bool {
       let isFollowed = alreadyFollowed(userId)

        let userRef = Database.database().reference().child(USER_DB_NAME);

        if isFollowed {
            Messaging.messaging().unsubscribe(fromTopic: "/topics/\(userId)")

            userRef.child(userId).child(UserConstant.FOLLOWINGS).child(Global.mCurrentUser!.id).removeValue()
            userRef.child(Global.mCurrentUser!.id).child(UserConstant.FOLLOWERS).child(userId).removeValue()

        } else {
            Messaging.messaging().subscribe(toTopic: "/topics/\(userId)");

            let userObj = BaseUserObject()
            userObj.id = userId;

            userRef.child(userId).child(UserConstant.FOLLOWINGS).child(Global.mCurrentUser!.id).updateChildValues( Global.mCurrentUser!.getBaseJsonvalue())
            userRef.child(Global.mCurrentUser!.id).child(UserConstant.FOLLOWERS).child(userId).setValue(userObj.getBaseJsonvalue());

            // MARK: SEND PUSH
            /*
            GlobalManager.getUserTokenByID(userId, new GlobalInterface.UserTokenInterface() {
                @Override
                public void getUserToken(String token) {
                    FcmNotificationBuilder.initialize()
                            .message("Follow")
                            .messageType(MsgType.FOLLOW)
                            .username(GlobalManager.mUserObj.name)
                            .senderid(GlobalManager.mUserObj.id)
                            .receiverid(userId)
                            .sendingTime(GlobalManager.getCurrentTimeintervalLong())
                            .receiverFirebaseToken(token)
                            .send();
                }
            }); */
        }

        return !isFollowed;
    }
    
    // MARK: SEND PUSH NOTIFICATION
    class func sendPushNotification(message: String       = "",
                                    userName: String      = "",
                                    senderID: String      = "",
                                    streamingID: String   = "",
                                    receiverID: String    = "",
                                    receiver: String      = "",
                                    deviceToken: String   = "",
                                    sendingTime: UInt64   = 0,
                                    msgType: MsgType      = .TEXT) {
        
        var noti_body = "\(userName): \(message)"
        if msgType == .COIN {
            noti_body = "Received \(message) coins from \(userName)"
        } else if msgType == .SUCCESS_MONTHLY {
            noti_body = "You succeed in the monthly TU-COIN GiveAway and got \(message) coins."
        } else if msgType == .FOLLOW {
            noti_body = "\(userName) followed you!"
        } else if msgType == .IMAGE {
            noti_body = "Received a Photo from \(userName)"
        } else if msgType == .AUDIO {
            noti_body = "Received a Audio message from \(userName)"
        } else if msgType == .VIDEO {
            noti_body = "Received a Video from \(userName)"
        } else if msgType == .LIKE || msgType == .LIVE || msgType == .COMMENTED {
            noti_body = message;
        }
        
        let notData: [String: Any] = [
            "to"            : deviceToken,
            "priority"      : "high",
            "notification"  : [
                                "title" : "SAL",
                                "body"  : noti_body,
                              ],
            "data"          : [
                                FCM_KEY_TEXT        : message,
                                FCM_KEY_USERNAME    : userName,
                                FCM_KEY_SENDERID    : senderID,
                                FCM_KEY_TYPE        : msgType.rawValue,
                                FCM_KEY_SENDTIME    : sendingTime,
                                FCM_KEY_RECEIVER    : receiver,
                                FCM_KEY_STREAMINGID : streamingID
                              ]
        ]
        
        var request = URLRequest(url: URL(string: FCM_URL)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(FCM_SERVER_API_KEY)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let jsonData = try? JSONSerialization.data(withJSONObject:notData)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error?.localizedDescription ?? "Failed Sending Push")")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
            }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString ?? "")")
        }
        task.resume()
    }
}
