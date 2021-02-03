//
//  NewsFeedTableViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 16.12.2020.
//

import UIKit

protocol NewsFeedTableViewCellDelegate {
    func selectOwnerProfile(_ index: Int)
    func selectLikeProfile(_ userId: String)
    func likeNewsFeed(_ index: Int)
    func showCommentView(_ index: Int)
    func shareNewsFeed(_ index: Int)
    func sendCoinToOwner(_ index: Int)
    func showLikedProfiles(_ index: Int)
    func clickContentView(_ index: Int)
}

class NewsFeedTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImg: ProfileWhiteImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var thumbImg: UIImageView!
    @IBOutlet weak var youtubeView: UIView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var postViewLbl: UILabel!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var coinBtn: UIButton!
    @IBOutlet weak var likeCV: UICollectionView!
    @IBOutlet weak var youtubeMark: UIImageView!
    @IBOutlet weak var videoMark: UIImageView!
    
    @IBOutlet weak var likeViewHeightLayoutContaint: NSLayoutConstraint!
    @IBOutlet weak var bottomLayoutContaint: NSLayoutConstraint!
    @IBOutlet weak var controlTrailingLayoutContaint: NSLayoutConstraint!
    
    var delegate: NewsFeedTableViewCellDelegate?
    var feedIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Init My Posts Collection
        let bundle = Bundle(for: type(of: self))
        let feedCellNib = UINib(nibName: "LikeProfileCollectionViewCell", bundle: bundle)
        self.likeCV.register(feedCellNib, forCellWithReuseIdentifier: "LikeProfileCollectionViewCell")
        likeCV.delegate = self
        likeCV.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickUserProfile(_ sender: Any) {
        self.delegate?.selectOwnerProfile(self.feedIndex)
    }
    
    @IBAction func onClickLikeBtn(_ sender: Any) {
        self.delegate?.likeNewsFeed(self.feedIndex)
    }
    
    @IBAction func onClickCommentBtn(_ sender: Any) {
        self.delegate?.showCommentView(self.feedIndex)
    }
    
    @IBAction func onClickShareBtn(_ sender: Any) {
        self.delegate?.shareNewsFeed(self.feedIndex)
    }
    
    @IBAction func onClickLikeViewBtn(_ sender: Any) {
        self.delegate?.showLikedProfiles(self.feedIndex)
    }
    
    @IBAction func onClickContentView(_ sender: Any) {
        self.delegate?.clickContentView(self.feedIndex)
    }
    
    @IBAction func onClickCoinBtn(_ sender: Any) {
        self.delegate?.sendCoinToOwner(self.feedIndex)
    }
}

// MARK: CollectionView Delegations
extension NewsFeedTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let postObj = Global.followPostObjs[self.feedIndex]
        return postObj.likes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikeProfileCollectionViewCell", for: indexPath) as! LikeProfileCollectionViewCell
        
        let postObj = Global.followPostObjs[self.feedIndex]
        let likeObj = postObj.likes[indexPath.row]
        Global.getProfileUrlByID(likeObj.id) { (url) in
            cell.profileImg.sd_setImage(with: URL(string: url), placeholderImage: PROFILE_DEFAULT_WHITE_AVATAR, options: [], context: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postObj = Global.followPostObjs[self.feedIndex]
        let userID = postObj.likes[indexPath.row].id
        
        self.delegate?.selectLikeProfile(userID)
    }
}

extension NewsFeedTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 50.0, height: 50.0)
    }
}
