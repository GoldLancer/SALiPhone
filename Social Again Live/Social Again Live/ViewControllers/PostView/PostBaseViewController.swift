//
//  PostBaseViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 22.01.2021.
//

import UIKit

class PostBaseViewController: BaseViewController {
    
    @IBOutlet weak var followBtn: RoundButton!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var coinBtn: UIButton!
    
    var mFeedObj: FeedObject? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateUIWithObject() {
        
        guard let feedobj = self.mFeedObj else {
            return
        }
        
        if Global.mCurrentUser!.id == feedobj.ownerId {
            self.coinBtn.isHidden = true
            self.followBtn.tag = 101
            self.followBtn.setTitle("Edit", for: .normal)
        } else {
            self.coinBtn.isHidden = false
            self.followBtn.tag = 102
            
            let followed = Global.alreadyFollowed(feedobj.ownerId)
            self.followBtn.setTitle(followed ? "Unfollow" : "Follow", for: .normal)
        }
        
        Global.getProfileNameByID(feedobj.ownerId) { (name) in
            self.nameLbl.text = name
        }
        Global.getProfileUrlByID(feedobj.ownerId) { (url) in
            self.profileImg.sd_setImage(with: URL(string: url), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], context: nil)
        }
        
        self.titleLbl.text = feedobj.title
        self.descLbl.text = feedobj.descriptions
    }
    
    override func readyToSendGift(_ amount: Int, imgName: String, soundName: String) {
        super.readyToSendGift(amount, imgName: imgName, soundName: soundName)
        
        if self.sendCoinToUser(self.mFeedObj!.ownerId, amount: amount, rawValue: soundName, needPush: true) {
            print("Send \(amount) coins to \(self.mFeedObj!.ownerId)")
        }
    }
    
    @IBAction func onClickCoinBtn(_ sender: Any) {
        self.showGiftDialog()
    }
    
    @IBAction func onClickProfileBtn(_ sender: Any) {
        self.showUserProfileView(self.mFeedObj!.ownerId)
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickFollowBtn(_ sender: Any) {
        if self.followBtn.tag == 101 {
            let storyboard = UIStoryboard(name: "NewPost", bundle: nil)
            if let postVC = storyboard.instantiateViewController(withIdentifier: "NewPostView") as? NewPostViewController {
                
                postVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                postVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                
                postVC.mPostObj = mFeedObj
                postVC.delegate = self
                
                self.present(postVC, animated: true, completion: nil)
            }
        } else {
            let followed = Global.followUser(mFeedObj!.ownerId)
            self.followBtn.setTitle(followed ? "Unfollow" : "Follow", for: .normal)
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

}

extension PostBaseViewController: NewPostViewControllerDelegate {
    func deletedMoment() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updatedMomentInfo() {
        self.updateUIWithObject()
    }
}
