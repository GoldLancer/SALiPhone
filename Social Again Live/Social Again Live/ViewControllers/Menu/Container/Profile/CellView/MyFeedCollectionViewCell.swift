//
//  MyFeedCollectionViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 13.12.2020.
//

import UIKit

protocol MyFeedCollectionViewCellDelegate {
    func selectedFeedForDetail(_ index: Int)
    func selectedFeedForShare(_ index: Int)
}

class MyFeedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbImg: UIImageView!
    @IBOutlet weak var videoView: UIView!
    
    var postIndex = 0
    var delegate: MyFeedCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onClickDetailBtn(_ sender: Any) {
        self.delegate?.selectedFeedForDetail(self.postIndex)
    }
    
    @IBAction func onClickFollowBtn(_ sender: Any) {
        self.delegate?.selectedFeedForShare(self.postIndex)
    }
}
