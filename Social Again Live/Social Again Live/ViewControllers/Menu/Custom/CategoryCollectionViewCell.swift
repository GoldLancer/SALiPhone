//
//  CategoryCollectionViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 10.12.2020.
//

import UIKit

protocol CategoryCollectionViewCellDelegate {
    func onSelectCategory(_ index: Int)
}

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var roundView: RoundView!
    @IBOutlet weak var categoryLbl: UILabel!
    
    var categoryIndex: Int = 0
    var delegate: CategoryCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onClickRootView(_ sender: Any) {
        self.delegate?.onSelectCategory(self.categoryIndex)
    }
}
