//
//  LiveViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 30.01.2021.
//

import UIKit
import WebKit

protocol LiveViewControllerDelegate {
    func broadcastingClosed()
}

class LiveViewController: BaseBroadcastingViewController {
    
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var heartLbl: UILabel!
    @IBOutlet weak var heartImg: UIImageView!
    @IBOutlet weak var followBtnTrailingLayout: NSLayoutConstraint!
    
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var playWebView: WKWebView!
    @IBOutlet weak var playerWebViewHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var loadActivity: UIActivityIndicatorView!
    @IBOutlet weak var firstFPImg: ProfileGreenImageView!
    @IBOutlet weak var secondFPImg: ProfileGreenImageView!
    @IBOutlet weak var thirdFPImg: ProfileGreenImageView!
    
    @IBOutlet weak var partnerWebView: WKWebView!
    
    var mStreamObj: StreamObject!
    
    var isPlayed: Bool = false
    var hasLiked: Bool = false
    var follows: [BaseUserObject] = []
    
    let pumbGif = UIImage.gifImageWithName("pump_heart")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.isPlayer = false
        self.currentStreamId = mStreamObj.streamId
        
        self.initUI()
        
        self.addFirebaseListener()
        self.loadBroadcasting()
    }
    
    override func initUI() {
        super.initUI()
        
        self.playWebView.isHidden = true
        self.playWebView.navigationDelegate = self
        
        checkingHasLiked()
        Global.getProfileUrlByID(mStreamObj.owner.id) { (url) in
            self.profileImg.sd_setImage(with: URL(string: url), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], context: nil)
        }
        
        self.upgradeWatcherCounter()
    }
    
    override func addFirebaseListener() {
        super.addFirebaseListener()
        
        Global.userRef.child(mStreamObj.owner.id).child(UserConstant.FOLLOWINGS).observe(.childAdded, with: { (snapshot) in
            if let userData = snapshot.value as? NSDictionary {
                let uObj = BaseUserObject()
                uObj.initUserWithJsonresponse(value: userData)
                
                self.follows.insert(uObj, at: 0)
                
                self.firstFPImg.isHidden = true
                self.secondFPImg.isHidden = true
                self.thirdFPImg.isHidden = true
                
                for (i, user) in self.follows.enumerated() {
                    var pImgView: ProfileGreenImageView!
                    
                    if i == 0 {
                        pImgView = self.firstFPImg
                    } else if i == 1 {
                        pImgView = self.secondFPImg
                    } else if i == 2 {
                        pImgView = self.thirdFPImg
                    } else {
                        break
                    }
                    
                    pImgView.isHidden = false
                    Global.getProfileUrlByID(user.id) { (url) in
                        pImgView.sd_setImage(with: URL(string: url), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], context: nil)
                    }
                }
            }
        })
        
        Global.userRef.child(mStreamObj.owner.id).child(UserConstant.LIKES).observe(.value) { (snapshot) in
            var count = 0
            if snapshot.exists() {
                count = Int(snapshot.childrenCount)
            }
            self.heartLbl.text = "\(count)"
        }
        
        Global.videoRef.child(mStreamObj.streamId).child(StreamConstant.WATCHERS).observe(.value, with: { (snapshot) in
            var watchers = 0;
            if snapshot.exists() {
                watchers = snapshot.value as? Int ?? 0
            }

            self.countLbl.text = "\(watchers)"
        })
        
        Global.videoRef.child(mStreamObj.streamId).child(StreamConstant.IS_ONLINE).observe(.value, with: { (snapshot) in
            var isOnline = false
            if snapshot.exists() {
                isOnline = snapshot.value as? Bool ?? false
            }
            
            if !isOnline {
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: .didClosedBroadcasting, object: nil)
                }
            }
        })
                
        Global.videoRef.child(mStreamObj.streamId).child(StreamConstant.IS_PAUSED).observe(.value, with: { (snapshot) in
            var isPaused = false
            if snapshot.exists() {
                isPaused = snapshot.value as? Bool ?? false
            }
            
            if isPaused {
                self.updateStatusLable("This Broadcasting was paused!", alwaysShow: true)
            }
        })
        
        Global.videoRef.child(mStreamObj.streamId).child(StreamConstant.IS_MULTI).observe(.value, with: { (snapshot) in
            var isMultiple = false
            if snapshot.exists() {
                isMultiple = snapshot.value as? Bool ?? false
            }
            
            // More Coding
        })

        Global.videoRef.child(mStreamObj.streamId).child(StreamConstant.PARTNER).child(StreamConstant.IS_ONLINE).observe(.value, with: { (snapshot) in
            var isOnline = false
            if snapshot.exists() {
                isOnline = snapshot.value as? Bool ?? false
            }
            
            // More Coding
        })
                
        Global.videoRef.child(mStreamObj.streamId).child(StreamConstant.PARTNER).child(StreamConstant.IS_PAUSED).observe(.value, with: { (snapshot) in
            var isPaused = false
            if snapshot.exists() {
                isPaused = snapshot.value as? Bool ?? false
            }
            
            // More Coding
        })
    }
    
    override func removeFirebaseListener() {
        super.removeFirebaseListener()
        
        Global.userRef.child(mStreamObj.owner.id).child(UserConstant.FOLLOWINGS).removeAllObservers()
        Global.userRef.child(mStreamObj.owner.id).child(UserConstant.LIKES).removeAllObservers()
        Global.videoRef.child(mStreamObj.streamId).child(StreamConstant.WATCHERS).removeAllObservers()
        Global.videoRef.child(mStreamObj.streamId).child(StreamConstant.IS_ONLINE).removeAllObservers()
        Global.videoRef.child(mStreamObj.streamId).child(StreamConstant.IS_PAUSED).removeAllObservers()
        Global.videoRef.child(mStreamObj.streamId).child(StreamConstant.IS_MULTI).removeAllObservers()
        Global.videoRef.child(mStreamObj.streamId).child(StreamConstant.PARTNER).child(StreamConstant.IS_ONLINE).removeAllObservers()
        Global.videoRef.child(mStreamObj.streamId).child(StreamConstant.PARTNER).child(StreamConstant.IS_PAUSED).removeAllObservers()
    }
    
    override func readyToSendGift(_ amount: Int, imgName: String, soundName: String) {
        
        if Global.mCurrentUser!.coin < amount {
            self.present(Global.alertWithText(errorText: "You don't have enough coins, Do you want to buy some coins?"), animated: true, completion: nil)
        }
        
        if self.sendCoinToUser(mStreamObj.owner.id, amount: amount, rawValue: soundName, needPush: true) {
            print("Send \(amount) coins to \(mStreamObj.owner.name)")
        }
    }
    
    private func loadBroadcasting() {
        let streamUrl = "\(RTMP_BASE_URL)\(self.currentStreamId)"
        let streamRequest = URLRequest(url: URL(string: streamUrl)!)
        self.playWebView.load(streamRequest)
    }
    
    private func checkingHasLiked() {
        let likeID = makeLikeId()
        Global.userRef.child(mStreamObj.owner.id).child(UserConstant.LIKES).child(likeID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.hasLiked = snapshot.exists()
            self.updateUILiked()
        })
    }
    
    private func updateUILiked() {
        if (hasLiked) {
            self.heartImg.image = self.pumbGif
        } else {
            self.heartImg.image = self.pumbGif?.images![0]
        }
    }
    
    private func makeLikeId() -> String {
        return "\(Global.mCurrentUser!.id)-\(mStreamObj.created)"
    }
    
    private func showFollowBtn(_ showed: Bool) {
        self.view.layoutIfNeeded()
        if showed {
            self.followBtn.tag = 100
            UIView.animate(withDuration: 0.5) {
                self.followBtnTrailingLayout.constant = -120
            }
        } else {
            self.followBtn.tag = 101
            UIView.animate(withDuration: 0.5) {
                self.followBtnTrailingLayout.constant = -40
            }
        }
    }
    
    private func autoShowFollowBtn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let showed = self.followBtn.tag == 101 ? true : false
            if showed {
                return
            } else {
                self.showFollowBtn(showed)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onClickCoinBtn(_ sender: Any) {
        self.showGiftDialog()
    }
    
    @IBAction func onClickShareBtn(_ sender: Any) {
        let textToShare = "Share Live"

        let streamUrl = "\(RTMP_BASE_URL)\(self.currentStreamId)"
        if let shareUrl = URL(string: streamUrl) {//Enter link to your app here
            let objectsToShare = [textToShare, shareUrl, UIImage(named: "splash_logo") as Any] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            //

            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickFollowUsersBtn(_ sender: Any) {
        
    }
    
    @IBAction func onClickSponsorBtn(_ sender: Any) {
    }
    
    @IBAction func onClickHeartBtn(_ sender: Any) {
        if self.hasLiked {
            return
        }
        
        let likeID = makeLikeId()
        Global.userRef.child(mStreamObj.owner.id).child(UserConstant.LIKES).child(likeID).setValue(Global.mCurrentUser!.getBaseJsonvalue())
        
        self.hasLiked = true
        self.updateUILiked()
    }
    
    @IBAction func onClickFollowBtn(_ sender: Any) {
        Global.userRef.child(mStreamObj.owner.id).child(UserConstant.FOLLOWINGS).child(Global.mCurrentUser!.id).setValue(Global.mCurrentUser!.getBaseJsonvalue())
        Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.FOLLOWERS).child(mStreamObj.owner.id).setValue(mStreamObj.owner.getBaseJsonvalue())
        
        showFollowBtn(true)
    }
    
    @IBAction func onClickShowFollowBtn(_ sender: Any) {
        let showed = self.followBtn.tag == 101 ? true : false
        self.showFollowBtn(showed)
    }
}

extension LiveViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.playWebView.isHidden = false
        
        let cObj = CommentObject()
        cObj.userId = Global.mCurrentUser!.id
        cObj.userName = Global.mCurrentUser!.name
        cObj.message = "\(Global.mCurrentUser!.name) is Watching"
        cObj.type = .CAME_IN
        
        cObj.uploadObjectToFirebase(Global.videoRef.child(self.currentStreamId).child(StreamConstant.COMMENTS))
        
        self.autoShowFollowBtn()
    }
}
