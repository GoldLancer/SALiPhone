//
//  RankingTableViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 22.01.2021.
//

import UIKit

protocol RankingTableViewCellDelegate {
    func clickedFollowBtn(_ cellIndex: Int)
    func clickedProfileBtn(_ cellIndex: Int)
}

class RankingTableViewCell: UITableViewCell {

    @IBOutlet weak var followBtn: RoundButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var rankingLbl: UILabel!
    @IBOutlet weak var flagImg: UIImageView!
    @IBOutlet weak var profileImg: ProfileGreenImageView!
    
    var delegate: RankingTableViewCellDelegate?
    var cellIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickProfileBtn(_ sender: Any) {
        self.delegate?.clickedProfileBtn(self.cellIndex)
    }
    
    @IBAction func onClickFollowBtn(_ sender: Any) {
        self.delegate?.clickedFollowBtn(self.cellIndex)
    }
}
