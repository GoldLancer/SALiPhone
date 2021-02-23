//
//  Constant.swift
//  Pulse Attendance
//
//  Created by Anton Yagov on 9/13/20.
//  Copyright © 2020 Goldlancer. All rights reserved.
//

import Foundation
import UIKit

public enum AccountType: String {
    case EMAIL      = "EMAIL"
    case FACEBOOK   = "FACEBOOK"
    case GMAIL      = "GMAIL"
}

public enum EmojiType: String {
    case EMOJI      = "EMOJI"
    case HERO       = "HERO"
    case SUPER      = "SUPER"
    case PRESI      = "PRESI"
}

public enum MsgType: String {
    case TEXT               = "TEXT"
    case IMAGE              = "IMAGE"
    case AUDIO              = "AUDIO"
    case VIDEO              = "VIDEO"
    case POST               = "POST"
    case COIN               = "COIN"
    case SUCCESS_MONTHLY    = "SUCCESS_MONTHLY"
    case LIKE               = "LIKE"
    case COMMENTED          = "COMMENTED"
    case LIVE               = "LIVE"
    case NEW_POST           = "NEW_POST"
    case FOLLOW             = "FOLLOW"
    case BLASTER            = "BLASTER"
    case ADMIN_NOTICE       = "ADMIN_NOTICE"
}

public enum PaymentType: String {
    case PAYPAL     = "PAYPAL"
    case PAYONEER   = "PAYONEER"
    case CASHAPP    = "CASHAPP"
}

public enum PostType: String {
    case IMAGE      = "IMAGE"
    case VIDEO      = "VIDEO"
    case VIDEOURL   = "VIDEOURL"
}

public enum RequestType: String {
    case REDEEM     = "REDEEM"
    case DELETE     = "DELETE"
    case OTHER      = "OTHER"
}

public enum TransactionType: String {
    case SUBS       = "SUBS"
    case INAPP      = "INAPP"
}

public enum CommentType: String {
    case COMMENT    = "COMMENT"
    case SENT_COIN  = "SENT_COIN"
    case CAME_IN    = "CAME_IN"
    case CAME_OUT   = "CAME_OUT"
    case FOLLOW     = "FOLLOW"
    case UNFOLLOW   = "UNFOLLOW"
}

let ADMIN_ID                = "admin"

let MAIN_BG_DARK_COLOR      = UIColor(named: "main_bg_dark_color")
let MAIN_BG_LIGHT_COLOR     = UIColor(named: "main_bg_light_color")
let MAIN_GREEN_COLOR        = UIColor(named: "main_green_color")
let MAIN_WHITE_COLOR        = UIColor(named: "main_white_color")
let MAIN_YELLOW_COLOR       = UIColor(named: "main_yellow_color")

let FONT_NAME_MONT_REGULAR  = "Montserrat-Regular"
let FONT_NAME_MONT_MEDIUM   = "Montserrat-Medium"
let FONT_NAME_MONT_BOLD     = "Montserrat-Bold"
let FONT_NAME_MONT_LIGHT    = "Montserrat-Light"
let FONT_NAME_MONT_SEMIBOLD = "Montserrat-SemiBold"
let FONT_NAME_MONT_THIN     = "Montserrat-Thin"

// AntMedia Server
let STREAM_API_URL          = "http://216.128.130.197/api.php?"
let SERVER_ADDRESS          = "216.128.130.197:5080"
let SERVER_TOKEN            = "AMS545e6789b70f18a233a53dd03b2505"
let TUCOIN_PAYOUT_PDF_URL   = "http://216.128.130.197/tucoin_payout.pdf"

let PAYONEER_SIGNUP_URL     = "https://payouts.payoneer.com/partners/or.aspx?pid=YOYIZC74IO2s4KZQp7tgsw==&BusinessLine=3&UsePurpose=3&Volume=above-100000&webInteraction=webpage_accounts&from=login"
let PAYPAL_SIGNUP_URL       = "https://www.paypal.com/webapps/mpp/account-selection"

//Firebase Realtime Database
let ADMIN_DB_NAME           = "Admin"
let ADMIN_ID_NAME           = "adminId"
let USER_DB_NAME            = "Accounts"
let BLOCK_USER_DB_NAME      = "Blocked"
let REQUEST_DB_NAME         = "Request"
let VIDEO_DB_NAME           = "LiveStreams"
let POST_DB_NAME            = "NewsFeed"
let MSG_DB_NAME             = "ChatRoom"
let COUNTRY_DB_NAME         = "Countries"
let MONTHLY_POT_DB_NAME     = "monthPot"
let VERSION_DB_NAME         = "androidVersion"

// Admin
let SAL_ADMIN_EMAIL         = "socialagainlive@gmail.com"
let SAL_ADMIN_ID            = "admin"

// Date
let MONTH_NAME  = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

// Firebase Storage Directory
let STORAGE_VIDEO_NAME      = "videos/"
let STORAGE_IMAGE_NAME      = "images/"
let STORAGE_BLAST_IMAGE_NAME = "blast/"

let ALL_TOPIC_NAME          = "/topics/SAL_All"
let ADMIN_TOPIC_NAME        = "/topics/SAL_Admin"
let appStoreUrl             = "https://play.google.com/store/apps/details?id=com.goldlancer.socialagainlive"

let SAL_TUTORIAL_VIDEO_URL  = "https://www.youtube.com/watch?v=y_qjmo3a7Oc"
let RTMP_BASE_URL           = "http://216.128.130.197:5080/LiveApp/play.html?name="
let STEAMID_LENGTH          = 24

let BROADCASE_CHATROOM_CHANGE       = "chatroom_changed"
let BROADCASE_FOLLOWERS_CHANGE      = "followers_changed"
let BROADCASE_FOLLOWINGS_CHANGE     = "followings_changed"
let BROADCASE_NOTIFICATION_CHANGED  = "notification_changed"
let GLOBAL_NOTIFICATIONS            = "global_notifications"
let PUST_ACTION_MAIN                = "push_action_to_mainactivity"

// Verification Code
let VERIFICATION_CODE               = "verificationCode"
let VERIFICATION_CODE_TIME          = "verificationCodeTime"
let VERIFICATION_CODE_EMAIL         = "verificationCodeEmail"
let EXPIRED_LIMIT                   = 100

// Setting Options
let SETTING_SHARING_LIKED_OR_COMMENTED       = "setting_sharing_liked_or_commented"
let SETTING_NOTICATION_SOUND_WHEN_CHAT       = "setting_notification_sound_when_chat"
let SETTING_NOTICATION_SOUND_INAPP_SOUND     = "setting_notification_sound_inapp_sound"
let SETTING_NOTICATION_SOUND_INAPP_VIBRATION = "setting_notification_sound_inapp_vibration"
let SETTING_NOTICATION_SOUND_LIVE_BROADCAST  = "setting_notification_sound_live_broadcast"

// Schedule Intent Request Code
let BLASTER_SENDING_MAX_COUNT       = 5
let BLASTER_TITLE                   = "blaster_title"
let BLASTER_BODY                    = "blaster_body"
let BLASTER_IMAGE_BYTES             = "blaster_image_bytes"
let BLASTER_IMAGE_URL               = "blaster_image_url"
let BLASTER_YOUTUBE_URL             = "blasteryoutube_url"
let BLASTER_TO_EMAILS               = "blaster_to_emails"
let BLASTER_TO_IDS                  = "blaster_to_ids"
let BLASTER_MATCHES                 = "blaster_matches"
let BLASTER_REQUEST_CODE            = "blaster_request_code"
let CURRENT_USER                    = "current_user"

// MailGun
let MAILGUN_API_URL         = "https://api.mailgun.net/v3/socialagain.live/messages?from=sal@socialagain.live"
let MAILGUN_API_AUTH        = "Basic YXBpOjZhYzE1YzQxY2RjMmMwYjM5MDRmNmFiMzgwOGUwZmNhLTliMWJmNWQzLTBlZDUxYTNl"

// Billing Value
let LICENSE_KEY             = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnCdL7iYAdLgQC4wUUlJWNQ92c7H9tt1956dK9XyODpGgjJR2X0OG9l9f4439TxNyLBHs5TMrwgUvV5uwknrE57+y/acmeRo9PmEMcWcSp5hLTY+6cviCwg2a+Y2vU3EjWvB9HRU797qYJTCbeLV1M9QqrKuXdc4e5qG5daxkVoRX4iCAxDUVn0bVMg8qiUR05hV3lp4otTyTh+/bHIfMrznqaXRw/VzuPskOrsI9e0LVGHvW21wbaheYwLmmkkBlThveMWSAhuB17A34L4AzkXBI9UIIKZ3iyUk9qyJGMNrWXp0URYm7OhbrXuNWs/qeFkiGCrJT5RNQEhu35pVdSwIDAQAB" // PUT YOUR MERCHANT KEY HERE
let BUY_ITEM_LIMIT = 5


// Category
let CATEGORY_ITEMS          = ["Music", "Pod Cast", "Gamer", "Sports", "Comedy", "How To", "FundRaiser", "Cooking", "Religion", "Business"]
let TUCOIN_ITEMS            = [100, 200, 300, 400, 500, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000]
let REDEEM_ITEMS            = [3000, 5000, 10000, 20000, 30000, 50000, 100000, 200000, 300000, 500000, 1000000]

// Coins
let MONEYCOIN_VALUES        = [ 1, 5, 10, 25, 50, 75, 125, 300, 450, 500, 700, 1000]
let SUPERCOIN_VALUES        = [ 25, 75, 100, 150, 180, 250, 350, 400, 600, 750, 800, 1000, 2500, 3000, 4000, 6500, 7000, 8500, 9750, 12000, 14500, 18000, 20000, 24000]

let PROFILE_DEFAULT_GREEN_AVATAR = UIImage(named: "ic_default_profile_green")
let PROFILE_DEFAULT_WHITE_AVATAR = UIImage(named: "ic_default_profile_white")

// InApp
let IAP_ITEM_ICONS          = ["ic_upgrade_coin_200", "ic_upgrade_coin_500", "ic_upgrade_coin_1000", "ic_upgrade_coin_2000", "ic_upgrade_coin_3000", "ic_upgrade_coin_5000", "ic_upgrade_coin_10000", "ic_upgrade_coin_30000"]
let IAP_ITEM_COSTS          = [2.75, 5.75, 10.75, 21.50, 31.50, 51.50, 103.00, 306.00]
let IAP_ITEM_COINS          = [200, 500, 1000, 2000, 3000, 5000, 10000, 30000]

let IAP_SHARED_SECRET       = "ba733574b4144f12922256ccc483a1ec"
let IAP_MONTHLY_SUB_ID      = "sal.sub.monthly"

// FCM Properties
let FCM_TAG: String         = "FcmNotificationBuilder"
let FCM_SERVER_API_KEY      = "AAAAD-bYAV8:APA91bGpfZaRBSsEzIff-WpaHMYZ9yvAlch8vkoo9M2AWs8_NZbYx-mp1KXeCmu3x3a3VE_sbEuglrv0bGVrcVL8myTdMJyZoqdR7SAhWEKhaDo6hb45cEcv-PuODNFd2PG9IY2Bmi3S"
let FCM_CONTENT_TYPE        = "Content-Type"
let FCM_APPLICATION_JSON    = "application/json"
let FCM_AUTHORIZATION       = "Authorization"
let FCM_URL                 = "https://fcm.googleapis.com/fcm/send"

let FCM_KEY_TO              = "to"
let FCM_KEY_DATA            = "data"
let FCM_KEY_TEXT            = "body"
let FCM_KEY_USERNAME        = "username"
let FCM_KEY_SENDERID        = "senderid"
let FCM_KEY_STREAMINGID     = "streamingId"
let FCM_KEY_RECEIVERID      = "receiverid"
let FCM_KEY_RECEIVER        = "receiver"
let FCM_KEY_TYPE            = "type"
let FCM_KEY_SENDTIME        = "sendingtime"
