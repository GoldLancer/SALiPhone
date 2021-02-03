//
//  CoinCollectionViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 17.12.2020.
//

import UIKit

protocol CoinCollectionViewCellDelegate {
    func selectGiftWithInfo(_ amount: Int, imgName: String, soundName: String)
}

class CoinCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var giftImg: UIImageView!
    @IBOutlet weak var amountLbl: UILabel!
    
    var delegate: CoinCollectionViewCellDelegate?
    
    var resourceName: String = ""
    var rawValue: String = ""
    var amount: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onClickCellView(_ sender: Any) {
        self.delegate?.selectGiftWithInfo(self.amount, imgName: self.resourceName, soundName: self.rawValue)
    }
}
