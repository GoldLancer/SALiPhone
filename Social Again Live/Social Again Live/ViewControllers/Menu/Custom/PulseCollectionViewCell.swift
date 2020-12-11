//
//  PulseCollectionViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 10.12.2020.
//

import UIKit

protocol PulseCollectionViewCellDelegate {
    func onClickFeed(_ feedObj: FeedObject)
    func onClickFeedOwner(_ feedObj: FeedObject)
}

class PulseCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thumbImg: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var profileImg: ProfileGreenImageView!
    
    var delegate: PulseCollectionViewCellDelegate?
    var mFeedObj: FeedObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setFeedObject(_ feedObj: FeedObject) {
        
    }

    @IBAction func onClickRootView(_ sender: Any) {
        self.delegate?.onClickFeed(self.mFeedObj!)
    }
    
    @IBAction func onClickProfileBtn(_ sender: Any) {
        self.delegate?.onClickFeedOwner(self.mFeedObj!)
    }
}
