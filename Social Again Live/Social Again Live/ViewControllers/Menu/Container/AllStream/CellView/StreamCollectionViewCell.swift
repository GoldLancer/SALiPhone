//
//  StreamCollectionViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 11.12.2020.
//

import UIKit

protocol StreamCollectionViewCellDelegate {
    func onClickedOwnerProfile(_ index: Int)
}

class StreamCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileImg: ProfileGreenImageView!
    @IBOutlet weak var profileLbl: UILabel!
    @IBOutlet weak var thumbImg: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    var delegate: StreamCollectionViewCellDelegate?
    var streamIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bgView.setCornerRadius()
        self.bgView.layer.borderColor = MAIN_GREEN_COLOR?.cgColor
        self.bgView.layer.borderWidth = 1.0
    }

    @IBAction func onClickOwnerProfileBtn(_ sender: Any) {
        self.delegate?.onClickedOwnerProfile(self.streamIndex)
    }
}
