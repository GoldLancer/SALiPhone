//
//  RoundLabel.swift
//  Social Again Live
//
//  Created by Anton Yagov on 10.12.2020.
//

import UIKit

class RoundLabel: UILabel {

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
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        super.drawText(in: rect.inset(by: insets))
    }

}
