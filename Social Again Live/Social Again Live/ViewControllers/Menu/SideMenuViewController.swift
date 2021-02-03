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
    
    @IBOutlet weak var profileImg: ProfileGreenImageView!
    @IBOutlet weak var coinLbl: UILabel!
    @IBOutlet weak var heartCountLbl: UILabel!
    @IBOutlet weak var monthPotLbl: UILabel!
    var delegate: SideMenuViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let avatar = Global.mCurrentUser!.avatar
        if !avatar.isEmpty {
            self.profileImg.sd_setImage(with: URL(string: avatar), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], completed: nil)
        } else {
            self.profileImg.image = PROFILE_DEFAULT_GREEN_AVATAR
        }
        self.coinLbl.text = "\(Global.mCurrentUser!.coin)"
        self.heartCountLbl.text = "\(Global.likeCount)"
        self.monthPotLbl.text = "\(Global.monthlyPot)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCurrentUserInfo), name: .didReloadUserInfo, object:nil)
    }
    
    func onClickMenuItem(_ item: String) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.onClickMenuItem(item)
    }
    
    @objc func reloadCurrentUserInfo() {
        // Update Coin amount
        self.coinLbl.text = "\(Global.mCurrentUser!.coin)"
        let avatar = Global.mCurrentUser!.avatar
        if !avatar.isEmpty {
            self.profileImg.sd_setImage(with: URL(string: avatar), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], completed: nil)
        } else {
            self.profileImg.image = PROFILE_DEFAULT_GREEN_AVATAR
        }
        
    }
    
    @IBAction func onClickBusinessBtn(_ sender: Any) {
        onClickMenuItem("business")
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
