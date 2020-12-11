//
//  ProfileGreenImageView.swift
//  Social Again Live
//
//  Created by Anton Yagov on 10.12.2020.
//

import UIKit

class ProfileGreenImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.borderColor = MAIN_GREEN_COLOR?.cgColor
        self.layer.borderWidth = 1.0
    }

}
