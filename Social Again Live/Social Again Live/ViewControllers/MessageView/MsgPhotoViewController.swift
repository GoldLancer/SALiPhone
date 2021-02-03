//
//  MsgPhotoViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 19.01.2021.
//

import UIKit

class MsgPhotoViewController: UIViewController {

    @IBOutlet weak var photoImg: UIImageView!
    
    var photoUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !photoUrl.isEmpty {
            self.photoImg.sd_setImage(with: URL(string: photoUrl), completed: nil)
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
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
