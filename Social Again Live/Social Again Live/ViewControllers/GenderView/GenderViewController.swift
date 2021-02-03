//
//  GenderViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 13.01.2021.
//

import UIKit

protocol GenderViewControllerDelegate {
    func selectGender(_ isFemale: Bool)
}

class GenderViewController: UIViewController {
    
    var delegate: GenderViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickFemaleBtn(_ sender: Any) {
        self.delegate?.selectGender(true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickMaleBtn(_ sender: Any) {
        self.delegate?.selectGender(false)
        
        self.dismiss(animated: true, completion: nil)
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
