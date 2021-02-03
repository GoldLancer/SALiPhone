//
//  RoundGreenTextField.swift
//  Social Again Live
//
//  Created by Anton Yagov on 12.01.2021.
//

import UIKit

class RoundGreenTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 15.0
        self.backgroundColor = UIColor(named: "main_green_color")
        
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: self.bounds.height))
        self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: self.bounds.height))
        self.leftViewMode = .always
        self.rightViewMode = .always
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])

    }

}
