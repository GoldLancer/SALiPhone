//
//  RoundTextField.swift
//  Social Again Live
//
//  Created by Anton Yagov on 10.12.2020.
//

import UIKit

class RoundTextField: UITextField {

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
        self.layer.borderColor = MAIN_YELLOW_COLOR?.cgColor
        self.layer.borderWidth = 1.0
        
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.bounds.height))
        self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.bounds.height))
        self.leftViewMode = .always
        self.rightViewMode = .always
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])

    }

}
