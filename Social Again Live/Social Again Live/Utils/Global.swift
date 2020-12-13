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
    static var countries: [String]              = []
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
    
    // MARK: Time&Date
    class func getCurrentTimeintervalString() -> String {
        let timestamp = NSDate().timeIntervalSince1970
        return "\(timestamp)"
    }
    
    class func getCurrentTimeintervalUint() -> UInt64 {
        let timestamp = NSDate().timeIntervalSince1970
        return UInt64(timestamp)
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
    
    // MARK: GET PROFILE PROPERTY
    class func getProfileUrlByID(_ uId: String, completion: @escaping (String) -> ()) {
        let userRef = Database.database().reference().child(USER_DB_NAME)
        userRef.child(uId).child(UserConstant.AVATAR).observeSingleEvent(of: .value) { (snapshot) in
            let profileUrl = snapshot.value as? String ?? ""
            completion(profileUrl)
        }
    }
    
    class func getProfileNameByID(_ uId: String, completion: @escaping (String) -> ()) {
        let userRef = Database.database().reference().child(USER_DB_NAME)
        userRef.child(uId).child(UserConstant.NAME).observeSingleEvent(of: .value) { (snapshot) in
            let profileName = snapshot.value as? String ?? ""
            completion(profileName)
        }
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
}
