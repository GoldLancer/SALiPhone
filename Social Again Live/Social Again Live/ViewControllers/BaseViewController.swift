//
//  BaseViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import PKHUD

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }    

    func showLoadingView(_ label: String? = "Loading...") {
        DispatchQueue.main.async {
            HUD.show(.labeledProgress(title: nil, subtitle: label))
            HUD.dimsBackground = true
        }
    }
    
    func hideLoadingView() {
        DispatchQueue.main.async {
            HUD.hide()
        }
    }
    
    func showAlertWithText(errorText: String?,
                             title: String                        = "Error",
                             cancelTitle: String                  = "OK",
                             cancelAction: (() -> Void)?          = nil,
                             otherButtonTitle: String?            = nil,
                             otherButtonStyle: UIAlertAction.Style = .default,
                             otherButtonAction: (() -> Void)?     = nil,
                             completion: (() -> Void)?            = nil) -> Void {
        
        self.present(Global.alertWithText(errorText: errorText, title: title, cancelTitle: cancelTitle, cancelAction: cancelAction, otherButtonTitle: otherButtonTitle, otherButtonStyle: otherButtonStyle, otherButtonAction: otherButtonAction), animated: true, completion: completion)
    }

}
