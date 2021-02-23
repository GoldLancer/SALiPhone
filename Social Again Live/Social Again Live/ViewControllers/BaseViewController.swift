//
//  BaseViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import PKHUD
import Firebase
import IQKeyboardManagerSwift
import SwiftySound
import SVProgressHUD

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        IQKeyboardManager.shared.enable = true
    }    

    func showLoadingView(_ label: String? = "Loading...") {
        
        DispatchQueue.main.async {
//            HUD.show(.labeledProgress(title: nil, subtitle: label))
//            HUD.dimsBackground = true
            
            SVProgressHUD.show(withStatus: label)
        }
    }
    
    func hideLoadingView() {
        DispatchQueue.main.async {
//            HUD.hide()
            SVProgressHUD.dismiss()
        }
    }
    
    func showAlertWithText(errorText: String?,
                             title: String                        = "Error",
                             cancelTitle: String                  = "OK",
                             cancelAction: (() -> Void)?          = nil,
                             otherButtonTitle: String?            = nil,
                             otherButtonStyle: UIAlertAction.Style = .default,
                             otherButtonAction: (() -> Void)?     = nil,
                             completion: (() -> Void)?            = nil) -> Void {
        
        let alertVC = Global.alertWithText(errorText: errorText,
                                           title: title,
                                           cancelTitle: cancelTitle,
                                           cancelAction: cancelAction,
                                           otherButtonTitle: otherButtonTitle,
                                           otherButtonStyle: otherButtonStyle,
                                           otherButtonAction: otherButtonAction)
        self.present(alertVC, animated: true, completion: completion)
    }
    
    func showGiftDialog() {
        let storyboard = UIStoryboard(name: "Coin", bundle: nil)
        if let giftDialog = storyboard.instantiateViewController(withIdentifier: "CoinDialog") as? CoinViewController {
            giftDialog.delegate = self
            giftDialog.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            giftDialog.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(giftDialog, animated: true, completion: nil)
        }
    }
    
    func showCategoryDialog(_ currentIndex: Int = 0) {
        let storyboard = UIStoryboard(name: "Category", bundle: nil)
        if let ctDialog = storyboard.instantiateViewController(withIdentifier: "CategoryDialog") as? CategoryViewController {
            ctDialog.delegate = self
            
            ctDialog.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            ctDialog.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            ctDialog.currentCTIndex = currentIndex
            self.present(ctDialog, animated: true, completion: nil)
        }
    }
    
    func showLiveSteamView(_ stremObj: StreamObject) {
        let storyboard = UIStoryboard(name: "Broadcasting", bundle: nil)
        if let liveView = storyboard.instantiateViewController(withIdentifier: "LiveView") as? LiveViewController {
            
            liveView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            liveView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            liveView.mStreamObj = stremObj
            
            self.present(liveView, animated: true, completion: nil)
        }
    }
    
    func readyToSendGift(_ amount: Int, imgName: String, soundName: String) {
        
    }
    
    func sendCoinToUser(_ userId: String, amount: Int, rawValue: String, needPush: Bool) -> Bool {
        if Global.mCurrentUser!.coin < amount {
            showAlertWithText(errorText: "You don't have enough coins, Do you want to buy some coins?")
            return false
        }

        playSound(rawValue)

        Global.mCurrentUser!.coin -= amount;
        self.updateNumberofCoins(userId, addCoins: amount)

        if !needPush {
            return true
        }

        // Send Push Notification
        Global.getProfileTokenByID(userId) { (devToken) in
            if !devToken.isEmpty {
                Global.sendPushNotification(message: "\(amount)",
                                            userName: Global.mCurrentUser!.name,
                                            senderID: Global.mCurrentUser!.id,
                                            receiverID: userId,
                                            receiver: userId,
                                            deviceToken: devToken,
                                            sendingTime: Global.getCurrentTimeintervalUint(),
                                            msgType: .COIN)
            }
        }

        return true
    }
    
    // Set Number of user's coin
    func upgradeNumberofCoins() {
        let userRef = Database.database().reference().child(USER_DB_NAME)
        userRef.child(Global.mCurrentUser!.id).child(UserConstant.COIN).setValue(Global.mCurrentUser!.coin)
    }

    // Set Number of user's coin
    func updateNumberofCoins(_ userId: String, addCoins: Int) {
        let userRef = Database.database().reference().child(USER_DB_NAME)
        Global.getUserCoinByID(userId) { (amount) in
            let coins = amount + addCoins
            userRef.child(userId).child(UserConstant.COIN).setValue(coins)
        }
        
        self.upgradeNumberofCoins()
    }
    
    func playSound(_ ringtone: String) {
        
        Sound.play(file: "\(ringtone).mp3")
        
        
    }
    
    func showUserProfileView(_ userId: String, fromChat: Bool = false) {
        let storyboard = UIStoryboard(name: "UserProfile", bundle: nil)
        if let userProfileView = storyboard.instantiateViewController(withIdentifier: "UserProfileView") as? UserProfileViewController {
            
            userProfileView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            userProfileView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            userProfileView.userId = userId
            userProfileView.fromChat = fromChat
            
            self.present(userProfileView, animated: true, completion: nil)
        }
    }
    
    func showMessageView(_ chatroomId: String, pObj: BaseUserObject) {
        let storyboard = UIStoryboard(name: "Message", bundle: nil)
        if let messageView = storyboard.instantiateViewController(withIdentifier: "MessageView") as? MessageViewController {
            
            messageView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            messageView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            
            messageView.chatRoomId = chatroomId
            messageView.partnerObj = pObj
            
            self.present(messageView, animated: true, completion: nil)
        }
    }
    
    func showPostImageView(_ feedObj: FeedObject) {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let postImgView = storyboard.instantiateViewController(withIdentifier: "PostImageView") as? PostImageViewController {
            
            postImgView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            postImgView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            
            postImgView.mFeedObj = feedObj
            
            self.present(postImgView, animated: true, completion: nil)
        }
    }    
    
    func showPostVideoView(_ feedObj: FeedObject) {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let videoView = storyboard.instantiateViewController(withIdentifier: "PostVideoView") as? PostVideoViewController {
            
            videoView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            videoView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            
            videoView.mFeedObj = feedObj
            
            self.present(videoView, animated: true, completion: nil)
        }
    }
    
    func showVideosView(_ feedObj: FeedObject) {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let postVideoView = storyboard.instantiateViewController(withIdentifier: "VideoPageView") as? VideoPageViewController {
            
            postVideoView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            postVideoView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            
//            postVideoView.mFeedObj = feedObj
            
            self.present(postVideoView, animated: true, completion: nil)
        }
    }
    
    func showUpgradeView() {
        let storyboard = UIStoryboard(name: "Upgrade", bundle: nil)
        if let upgradeView = storyboard.instantiateViewController(withIdentifier: "UpgradeView") as? UpgradeViewController {
            
            upgradeView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            upgradeView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            upgradeView.delegate = self
            
            self.present(upgradeView, animated: true, completion: nil)
        }
    }
    
    func showPublishView() {
        
        let storyboard = UIStoryboard(name: "Broadcasting", bundle: nil)
        if let publishView = storyboard.instantiateViewController(withIdentifier: "PublishView") as? PublishViewController {
            
            publishView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            publishView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            
            self.present(publishView, animated: true, completion: nil)
        }
    }
    
    func openPhotoActivity() {
        let alertViewController = UIAlertController(title: "", message: "Choose your option", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (alert) in
            self.openCamera()
        })
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (alert) in
            self.openGallary()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in

        }
        alertViewController.addAction(camera)
        alertViewController.addAction(gallery)
        alertViewController.addAction(cancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func processSelectedPhoto(_ selectedImage: UIImage) {
        // More via override func
    }
    
    func finishPurchasing(_ result: String) {
        // More view Override func
    }
    
    func openCamera() {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera

        present(imagePicker, animated: true, completion: nil)
    }
    
    func openGallary() {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    func selectedCategoryWithIndex(ctIndex: Int) {
        print("Selected Category Index: \(ctIndex)")
    }

}

extension BaseViewController: CategoryViewControllerDelegate {
    func selectedCategory(ctIndex: Int) {
        self.selectedCategoryWithIndex(ctIndex: ctIndex)
    }
}

extension BaseViewController: CoinViewControllerDelegate {
    func selectGift(_ amount: Int, imgName: String, soundName: String) {
        self.readyToSendGift(amount, imgName: imgName, soundName: soundName)
    }
}

extension BaseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
            
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        
        self.processSelectedPhoto(selectedImage)
    }
}

extension BaseViewController: UpgradeViewControllerDelegate {
    func finishedPurchasing(_ result: String) {
        self.finishPurchasing(result)
    }
}

