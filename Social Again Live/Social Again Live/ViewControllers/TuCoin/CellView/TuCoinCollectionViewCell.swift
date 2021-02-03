//
//  TuCoinCollectionViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 29.01.2021.
//

import UIKit

protocol TuCoinCollectionViewCellDelegate {
    func selectedTUCoins(_ coins: Int)
}

class TuCoinCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var coinLbl: UILabel!
    
    var coins: Int = TUCOIN_ITEMS[0]
    var delegate: TuCoinCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onClickCell(_ sender: Any) {
        self.delegate?.selectedTUCoins(self.coins)
    }
}
