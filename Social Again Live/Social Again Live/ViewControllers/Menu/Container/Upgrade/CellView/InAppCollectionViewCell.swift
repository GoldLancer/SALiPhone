//
//  InAppCollectionViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 27.01.2021.
//

import UIKit

protocol InAppCollectionViewCellDelegate {
    func selectedItemForBuyCoin(_ itemIndex: Int)
}

class InAppCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var coinImg: UIImageView!
    @IBOutlet weak var costTxt: UILabel!
    
    var itemIndex: Int = 0
    var delegate: InAppCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onClickCoinBtn(_ sender: Any) {
        self.delegate?.selectedItemForBuyCoin(self.itemIndex)
    }
}
