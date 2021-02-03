//
//  UserProfileViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 16.12.2020.
//

import UIKit
import Firebase

class UserProfileViewController: BaseViewController {

    @IBOutlet weak var profileImg: ProfileGreenImageView!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var postCountLbl: UILabel!
    @IBOutlet weak var followerCountLbl: UILabel!
    @IBOutlet weak var followingCountLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var birthLbl: UILabel!
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var followBtn: RoundButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var clickableImg: UIImageView!
    @IBOutlet weak var clickableImgHeightLayout: NSLayoutConstraint!
    
    var userId: String?
    var mUserObj: UserObject = UserObject()
    var followingCount: Int = 0
    var fromChat: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showLoadingView()
        Global.userRef.child(userId!).observeSingleEvent(of: .value) { (snapshot) in
            self.hideLoadingView()
            if snapshot.exists() {
                if let userValue = snapshot.value as? NSDictionary {
                    self.mUserObj.initUserWithJsonresponse(value: userValue)
                    
                    self.updateUserInfo()
                }
            } else {
                self.showAlertWithText(errorText: "This current is not exist.")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func readyToSendGift(_ amount: Int, imgName: String, soundName: String) {
        super.readyToSendGift(amount, imgName: imgName, soundName: soundName)
        
        if Global.mCurrentUser!.coin < amount {
            self.present(Global.alertWithText(errorText: "You don't have enough coins, Do you want to buy some coins?"), animated: true, completion: nil)
//            showAlertWithText(errorText: "You don't have enough coins, Do you want to buy some coins?")
        }
        
        if self.sendCoinToUser(self.mUserObj.id, amount: amount, rawValue: soundName, needPush: true) {
            print("Send \(amount) coins to \(self.mUserObj.name)")
        }
    }
    
    func updateUserInfo() {
        if !self.mUserObj.avatar.isEmpty {
            self.profileImg.sd_setImage(with: URL(string: self.mUserObj.avatar), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], context: nil)
        } else {
            self.profileImg.image = PROFILE_DEFAULT_GREEN_AVATAR
        }
        
        if !self.mUserObj.cover.isEmpty {
            self.coverImg.sd_setImage(with: URL(string: self.mUserObj.cover), completed: nil)
        }
        
        if !self.mUserObj.clickableImgURL.isEmpty {
            self.clickableImg.isHidden = false
            
            self.clickableImgHeightLayout.constant = 240.0
            self.clickableImg.sd_setImage(with: URL(string: self.mUserObj.clickableImgURL), completed: nil)
        } else {
            self.clickableImg.isHidden = true
            
            self.clickableImgHeightLayout.constant = 0.0
        }
        
        self.titleLbl.text = self.mUserObj.name
        
        let followed = Global.alreadyFollowed(self.mUserObj.id)
        self.followBtn.setTitle(followed ? "UnFollow" : "Follow", for: .normal)
        
        self.followingCount = self.mUserObj.followings.count
        self.postCountLbl.text = "\(self.mUserObj.posts.count)"
        self.followerCountLbl.text = "\(self.mUserObj.followers.count)"
        self.followingCountLbl.text = "\(followingCount)"
        
        self.aboutLbl.text = self.mUserObj.aboutme
        self.genderLbl.text = self.mUserObj.gender
        self.countryLbl.text = self.mUserObj.country
        self.cityLbl.text = self.mUserObj.city
        self.birthLbl.text = Global.getStringOfBirth(year: self.mUserObj.birthYear, month: self.mUserObj.birthMonth, day: self.mUserObj.birthDay)
        
    }

    @IBAction func onClickClickableImgBtn(_ sender: Any) {
        guard let url = URL(string: self.mUserObj.clickableURL) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func onClickCoinBtn(_ sender: Any) {
        self.showGiftDialog()
    }
    
    @IBAction func onClickFollowBtn(_ sender: Any) {
        let followed = Global.followUser(self.mUserObj.id)
        self.followBtn.setTitle(followed ? "UnFollow" : "Follow", for: .normal)
        
        if followed {
            followingCount += 1
        } else {
            followingCount -= 1
        }
        self.followingCountLbl.text = "\(followingCount)"
    }
    
    @IBAction func onClickSendBtn(_ sender: Any) {
        
        if self.fromChat {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let chatId = Global.getChatRoomId(self.mUserObj.id)
        let baseUserObj = self.mUserObj.copyBaseUserObject()
        
        self.showMessageView(chatId, pObj: baseUserObj)
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
