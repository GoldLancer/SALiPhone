//
//  FollowTableViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 21.01.2021.
//

import UIKit

protocol FollowTableViewCellDelegate {
    func clickedUserProfile(_ cellIndex: Int)
    func clickedFollowingBtn(_ cellIndex: Int)
}

class FollowTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var followBtn: RoundButton!
    @IBOutlet weak var userProfileImg: ProfileGreenImageView!
    
    var cellIndex: Int = 0
    var delegate: FollowTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickFollowBtn(_ sender: Any) {
        self.delegate?.clickedFollowingBtn(self.cellIndex)
    }
    
    @IBAction func onClickUserProfileBtn(_ sender: Any) {
        self.delegate?.clickedUserProfile(self.cellIndex)
    }
}
