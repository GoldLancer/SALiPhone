//
//  TuCoinCollectionViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 29.01.2021.
//

import UIKit

protocol TuCoinCollectionViewCellDelegate {
    func selectedTUCoins(_ index: Int)
}

class TuCoinCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var coinLbl: UILabel!
    
    var cellIndex: Int = 0
    var delegate: TuCoinCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onClickCell(_ sender: Any) {
        self.delegate?.selectedTUCoins(self.cellIndex)
    }
}
