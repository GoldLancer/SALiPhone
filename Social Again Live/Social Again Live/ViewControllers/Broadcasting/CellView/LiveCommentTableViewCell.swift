//
//  LiveCommentTableViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 28.01.2021.
//

import UIKit

class LiveCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var nameLabelWidthLayout: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
