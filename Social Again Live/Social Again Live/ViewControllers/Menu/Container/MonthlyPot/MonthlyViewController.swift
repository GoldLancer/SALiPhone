//
//  MonthlyViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 22.01.2021.
//

import UIKit

class MonthlyViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        addNavItem()
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
    
    @IBAction func onClickUpgradeBtn(_ sender: Any) {
        self.showUpgradeView()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
