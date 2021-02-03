//
//  CTCollectionViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 13.01.2021.
//

import UIKit

protocol CTCollectionViewCellDelegate {
    func selectCT(index: Int)
}

class CTCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryBtn: RoundButton!
    
    var delegate: CTCollectionViewCellDelegate?
    var ctIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onClickCTBtn(_ sender: Any) {
        self.delegate?.selectCT(index: ctIndex)
    }
}
