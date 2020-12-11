//
//  SideMenuViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 10.12.2020.
//

import UIKit

protocol SideMenuViewControllerDelegate {
    func onClickMenuItem(_ item: String)
}

class SideMenuViewController: UIViewController {
    
    var delegate: SideMenuViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func onClickMenuItem(_ item: String) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.onClickMenuItem(item)
    }
    
    @IBAction func onClickProfileBtn(_ sender: Any) {
        onClickMenuItem("header")
    }
    
    @IBAction func onClickUpgradeBtn(_ sender: Any) {
        onClickMenuItem("upgrade")
    }
    
    @IBAction func onClickProfileItem(_ sender: Any) {
        onClickMenuItem("profile")
    }
    
    @IBAction func onClickChatItem(_ sender: Any) {
        onClickMenuItem("chat")
    }
    
    @IBAction func onClickStreamerItem(_ sender: Any) {
        onClickMenuItem("stream")
    }
    
    @IBAction func onClickFindItem(_ sender: Any) {
        onClickMenuItem("find")
    }
    
    @IBAction func onClickTransactionItem(_ sender: Any) {
        onClickMenuItem("transaction")
    }
    
    @IBAction func onClickSettingItem(_ sender: Any) {
        onClickMenuItem("setting")
    }
    
    @IBAction func onClickExitItem(_ sender: Any) {
        onClickMenuItem("exit")
    }
    
    @IBAction func onClickHeartBeatItem(_ sender: Any) {
        onClickMenuItem("heart")
    }
    
    @IBAction func onClickMonthlyItem(_ sender: Any) {
        onClickMenuItem("monthpot")
    }
}
