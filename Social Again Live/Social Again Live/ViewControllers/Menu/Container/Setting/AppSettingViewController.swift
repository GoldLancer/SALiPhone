//
//  AppSettingViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 21.01.2021.
//

import UIKit

class AppSettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onClickedBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onValueChangedInappVibration(_ sender: Any) {
    }
    
    @IBAction func onValueChangedNotiSound(_ sender: Any) {
    }
    
    @IBAction func onValueChangedSharing(_ sender: Any) {
    }
    
    @IBAction func onValueChangedInappSound(_ sender: Any) {
    }
    
    @IBAction func onClickLiveBroadcast(_ sender: Any) {
    }
}
