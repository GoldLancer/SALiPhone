//
//  TransactionableViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 05.02.2021.
//

import UIKit

class TransactionableViewCell: UITableViewCell {

    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var beginLBl: UILabel!
    @IBOutlet weak var endLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
