//
//  AppDelegate.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import Firebase
import GoogleSignIn
import IQKeyboardManagerSwift
import FBSDKCoreKit
import AVKit
import SVProgressHUD
import SwiftyStoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Keyboard Manager Configuration
        IQKeyboardManager.shared.enable = true
        
        // SVProgress Configuration
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setForegroundColor(MAIN_WHITE_COLOR!)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.setRingThickness(4)
        
        // Firebase Configuration
        FirebaseApp.configure()
        
        // In-App Store Configuration
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                print("IN-APP: \(purchase)")
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break
                }
            }
        }
        
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: IAP_SHARED_SECRET)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            
            Global.hasPurchased = false
            if case .success(let receipt) = result {
                let subscibeResult = SwiftyStoreKit.verifyPurchase(productId: IAP_MONTHLY_SUB_ID, inReceipt: receipt)
                switch subscibeResult {
                case .purchased(item: _):
                    Global.hasPurchased = true
                    break
                default:
                    break
                }
            }
        }
        
        // Messaging Configuration
        Messaging.messaging().delegate = self
        Messaging.messaging().subscribe(toTopic: "webhook")
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if GIDSignIn.sharedInstance().handle(url) {
            return true
        } else if ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation]) {
            return true
        }
        
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if GIDSignIn.sharedInstance().handle(url) {
            return true
        } else if ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        
        return false
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

      // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo

        // Print full message.
        print("willPresent: \(userInfo)")
        guard let data = userInfo["data"] as? NSDictionary else {
            print("Failed Json Decoding for Push Data")
            return
        }
        
        /*
        let pushData = PushData(jsonData: data)
        if pushData.siteId == Global.currentUser.id {
            return
        } else {
            guard let aps = userInfo["aps"] as? NSDictionary else {
                print("Failed Json Decoding for Push Data")
                return
            }
            guard let alert = aps["alert"] as? NSDictionary else {
                print("Failed Json Decoding for Push Data")
                return
            }
            
            let msg = MessageObj()
            msg.direction = .inbound
            msg.body = alert["body"] as? String ?? "MISSING"
            msg.contactId = pushData.contactId
            msg.type = .sms
            
            NotificationCenter.default.post(name: .didReceivePushMessage, object: self, userInfo: ["message": msg])
        }
        */
            
        // Change this to your preferred presentation option
        completionHandler([])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse,
                                  withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo as NSDictionary
        
        guard let data = userInfo["data"] as? NSDictionary else {
            print("Failed Json Decoding for Push Data")
            /*
            Global.reDirectChat = false
            Global.pushInfo = nil */
            return
        }
        
        // Print full message.
        print("DidReceive: \(userInfo)")
//        Global.loadingPushInfo(data)
        
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "Empty")")

        if let token = fcmToken {
            if !token.isEmpty {
                Global.deviceToken = token
            } else {
                Global.deviceToken = nil
            }
        }
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
    }
}

