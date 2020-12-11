//
//  BaseNavViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import SideMenu

class BaseNavViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addNavItem()
        setupSideMenu()
    }
    
    func setupSideMenu() {
        var settings = SideMenuSettings()
        settings.menuWidth = min(view.frame.width, view.frame.height) * 0.7
        settings.presentationStyle = .menuSlideIn
        
        // Define the menus
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        SideMenuManager.default.leftMenuNavigationController?.settings = settings
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
//        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
//        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
    }
    
    func addNavItem() {
        
        // Add Navigation Left Button
        let menuBtn = UIButton()
        menuBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        menuBtn.setImage(UIImage(named: "btn_menu"), for: .normal)
        menuBtn.addTarget(self, action:#selector(onClickMenuBtn(_:)), for: .touchUpInside)
        let leftBarItem = UIBarButtonItem(customView: menuBtn)
        self.navigationItem.setLeftBarButton(leftBarItem, animated: true)
        
        // Add Navigation Right Button
        let goLiveBtn = UIButton()
        goLiveBtn.backgroundColor = MAIN_GREEN_COLOR
        goLiveBtn.frame = CGRect(x: 0, y: 0, width: 70, height: 30)
        goLiveBtn.setTitle("Go Live", for: .normal)
        goLiveBtn.titleLabel?.font = UIFont(name: FONT_NAME_MONT_MEDIUM, size: 14)
        goLiveBtn.layer.cornerRadius = 15
        goLiveBtn.addTarget(self, action:#selector(onClickGoLiveBtn(_:)), for: .touchUpInside)
        let rightBarItem = UIBarButtonItem(customView: goLiveBtn)
        self.navigationItem.setRightBarButton(rightBarItem, animated: true)
        
        // Add Navigation Title
        let logoImg = UIImageView(image: UIImage(named: "ic_nav_logo"))
        logoImg.contentMode = .scaleAspectFit
        self.navigationItem.titleView = logoImg
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func onClickGoLiveBtn(_ sender: Any) {
        print("onClicked Go Live Button")
    }
    
    @objc func onClickMenuBtn(_ sender: Any) {
        print("onClicked Menu Button")
        self.present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }

}
