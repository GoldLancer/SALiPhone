//
//  BusinessProfileViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 14.01.2021.
//

import UIKit
import PWSwitch

protocol BusinessProfileViewControllerDelegate {
    func gotoUpgradeView()
}

class BusinessProfileViewController: BaseViewController {

    @IBOutlet weak var pulseSwitch: PWSwitch!
    @IBOutlet weak var sponsorSwitch: PWSwitch!
    @IBOutlet weak var sponsorTxt: UITextField!
    @IBOutlet weak var clickableBtn: UIButton!
    @IBOutlet weak var icBlaster: UIImageView!
    
    var delegate: BusinessProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addNavItem()
        initUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !Global.mCurrentUser!.isUpgraded {
            self.showAlertWithText(errorText: "You have to upgrade your account to use Business Settings. Do you want to upgarde now?", title: "", cancelTitle: "Not Now", cancelAction: {
                self.navigationController?.popViewController(animated: true)
            }, otherButtonTitle: "Yes", otherButtonAction: {
                self.navigationController?.popViewController(animated: false)
                self.delegate?.gotoUpgradeView()
            }, completion: {
                
            })
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initUserInfo() {
        icBlaster.image = UIImage(named: Global.mCurrentUser!.isBlaster ? "ic_notification_green" : "ic_bell_sticker")
        pulseSwitch.setOn(Global.mCurrentUser!.isPulse, animated: true)
        sponsorSwitch.setOn(Global.mCurrentUser!.isSponsor, animated: true)
        sponsorTxt.text = Global.mCurrentUser!.anyUrl
        clickableBtn.setTitle(Global.mCurrentUser!.clickableURL, for: .normal)
        
        sponsorTxt.isUserInteractionEnabled = Global.mCurrentUser!.isSponsor
    }
    
    func addNavItem() {
        
        // Add Navigation Left Button
        let backBtn = UIButton()
        backBtn.frame = CGRect(x: -30, y: 0, width: 30, height: 30)
        backBtn.setImage(UIImage(named: "btn_back"), for: .normal)
        backBtn.addTarget(self, action:#selector(onClickBackBtn(_:)), for: .touchUpInside)
        let leftBarItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.setLeftBarButton(leftBarItem, animated: true)
        
        // Add Navigation Title
        let logoImg = UIImageView(image: UIImage(named: "ic_nav_logo"))
        logoImg.contentMode = .scaleAspectFit
        self.navigationItem.titleView = logoImg
        
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickClikableBtn(_ sender: Any) {
        
    }
    
    @IBAction func onChangePulseSwitch(_ sender: Any) {
        Global.mCurrentUser!.isPulse = self.pulseSwitch.on
        Global.upgradeMyPosts()
    }
    
    @IBAction func onChangeSponsorSwitch(_ sender: Any) {
        Global.mCurrentUser!.isSponsor = sponsorSwitch.on
        sponsorTxt.isUserInteractionEnabled = Global.mCurrentUser!.isSponsor
    }
    
    @IBAction func onClickBlasterBtn(_ sender: Any) {
        Global.mCurrentUser!.isBlaster = !Global.mCurrentUser!.isBlaster
        icBlaster.image = UIImage(named: Global.mCurrentUser!.isBlaster ? "ic_notification_green" : "ic_bell_sticker")
    }
}
