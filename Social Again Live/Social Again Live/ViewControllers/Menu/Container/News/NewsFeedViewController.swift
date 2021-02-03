//
//  NewsFeedViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 11.12.2020.
//

import UIKit
import Firebase

protocol NewsFeedViewControllerDelegate {
    func showProfileView(_ userId: String)
}

class NewsFeedViewController: BaseViewController {
    
    @IBOutlet weak var feedTV: UITableView!
    var delegate: NewsFeedViewControllerDelegate?
    
    let feedCellHeight: CGFloat = 350.0
    var selectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Init My Posts Collection
        let bundle = Bundle(for: type(of: self))
        let feedCellNib = UINib(nibName: "NewsFeedTableViewCell", bundle: bundle)
        self.feedTV.register(feedCellNib, forCellReuseIdentifier: "NewsFeedTableViewCell")
        self.feedTV.delegate = self
        self.feedTV.dataSource = self
        
        // MARK: Add Notification
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFollowPosts), name: .didReloadAllFeeds, object:nil)
    }
    
    @objc func reloadFollowPosts() {
        self.feedTV.reloadData()
    }
    
    override func readyToSendGift(_ amount: Int, imgName: String, soundName: String) {
        super.readyToSendGift(amount, imgName: imgName, soundName: soundName)
        
        if selectedIndex < Global.followPostObjs.count {
            let pObj = Global.followPostObjs[selectedIndex]
            if self.sendCoinToUser(pObj.ownerId, amount: amount, rawValue: soundName, needPush: true) {
                print("Send \(amount) coins to \(pObj.ownerId)")
            }
        }
    }
    
    func onClickedLick(_ pObj: FeedObject) {
        let obj = Global.mCurrentUser!.copyBaseUserObject()

        var isLiked = getLikedValueForFeed(pObj)
        isLiked = !isLiked
        if isLiked {
            Global.postRef.child(pObj.postId).child(FeedConstant.LIKES).child(obj.id).updateChildValues(obj.getBaseJsonvalue());
        } else {
            Global.postRef.child(pObj.postId).child(FeedConstant.LIKES).child(obj.id).removeValue();
        }
    }
    
    func getLikedValueForFeed(_ pObj: FeedObject) -> Bool {
        var isLiked = false
        for uObj in pObj.likes {
            if uObj.id == Global.mCurrentUser!.id {
                isLiked = true;
                break;
            }
        }

        return isLiked
    }
}

extension NewsFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Global.followPostObjs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedTableViewCell", for: indexPath as IndexPath) as! NewsFeedTableViewCell
        cell.delegate = self
        cell.contentView.backgroundColor = .clear
        cell.feedIndex = indexPath.row
        
        let feedObj = Global.followPostObjs[indexPath.row]
        let isLast = indexPath.row == (Global.followPostObjs.count-1)
        if isLast {
            cell.bottomLayoutContaint.constant = 50.0
        } else {
            cell.bottomLayoutContaint.constant = 20.0
        }
        
        if feedObj.title.isEmpty {
            Global.getProfileNameByID(feedObj.ownerId) { (name) in
                cell.titleLbl.text = name
            }
        } else {
            cell.titleLbl.text = feedObj.title
        }
        
        Global.getProfileUrlByID(feedObj.ownerId) { (url) in
            cell.profileImg.sd_setImage(with: URL(string: url), placeholderImage: PROFILE_DEFAULT_WHITE_AVATAR, options: [], completed: nil)
        }
        if feedObj.type == .IMAGE {
            cell.youtubeView.isHidden = true
            cell.thumbImg.sd_setImage(with: URL(string: feedObj.postUrl), completed: nil)
        } else {
            cell.youtubeView.isHidden = false
            cell.thumbImg.sd_setImage(with: URL(string: feedObj.thumbUrl), completed: nil)
            
            cell.youtubeMark.isHidden = feedObj.type == .VIDEOURL ? false : true
            cell.videoMark.isHidden = feedObj.type == .VIDEOURL ? true : false
        }
        
        cell.likeLbl.text = "\(feedObj.likes.count)"
        cell.commentLbl.text = "\(feedObj.comments.count)"
        cell.postViewLbl.text = "\(feedObj.views.count)"
        cell.detailLbl.text = feedObj.descriptions
        
        if Global.mCurrentUser!.id == feedObj.ownerId {
            cell.likeBtn.isHidden = true
            cell.coinBtn.isHidden = true
            cell.controlTrailingLayoutContaint.constant = 15.0
        } else {
            cell.likeBtn.isHidden = false
            cell.coinBtn.isHidden = false
            cell.controlTrailingLayoutContaint.constant = 55.0
        }
        
        let liked = self.getLikedValueForFeed(feedObj)
        cell.likeBtn.setImage(UIImage(named: liked ? "ic_like_red" : "ic_like_white"), for: .normal)
        
        if feedObj.isShowLikes {
            cell.likeViewHeightLayoutContaint.constant = 50.0
        } else {
            cell.likeViewHeightLayoutContaint.constant = 0.0
        }
        cell.likeCV.reloadData()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let feedObj = Global.followPostObjs[indexPath.row]
        var cellHeight = feedCellHeight
        if !feedObj.descriptions.isEmpty {
            if let labelHeight = feedObj.descriptions.heightWithConstrainedWidth(self.view.bounds.width - 30, font: UIFont(name: "Montserrat-Regular", size: 14.0)!) {
                cellHeight += labelHeight
            }
            
            cellHeight += 25.0
        }
        
        if feedObj.isShowLikes {
            cellHeight += 50.0
        }
        
        let isLast = indexPath.row == (Global.followPostObjs.count-1)
        if isLast {
            cellHeight += 50.0
        } else {
            cellHeight += 20.0
        }
        
        return cellHeight
    }
    
}

extension NewsFeedViewController: NewsFeedTableViewCellDelegate {
    func selectOwnerProfile(_ index: Int) {
        let feedObj = Global.followPostObjs[index]
        self.delegate?.showProfileView(feedObj.ownerId)
    }
    
    func selectLikeProfile(_ userId: String) {
        self.delegate?.showProfileView(userId)
    }
    
    func likeNewsFeed(_ index: Int) {
        let pObj = Global.followPostObjs[index]
        self.onClickedLick(pObj)
        
        self.feedTV.reloadData()
    }
    
    func showCommentView(_ index: Int) {
        
    }
    
    func shareNewsFeed(_ index: Int) {
        
    }
    
    func showLikedProfiles(_ index: Int) {
        let isliked = Global.followPostObjs[index].isShowLikes
        Global.followPostObjs[index].isShowLikes = !isliked
        
        self.feedTV.reloadData()
    }
    
    func sendCoinToOwner(_ index: Int) {
        self.selectedIndex = index
        self.showGiftDialog()
    }
    
    func clickContentView(_ index: Int) {
        let pObj = Global.followPostObjs[index]
        
        if pObj.type == .IMAGE {
            self.showPostImageView(pObj)
        } else {
            self.showVideosView(pObj)
        }
    }
}
