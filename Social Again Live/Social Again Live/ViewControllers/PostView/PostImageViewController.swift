//
//  PostImageViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 22.01.2021.
//

import UIKit

class PostImageViewController: PostBaseViewController {

    
    @IBOutlet weak var postImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUIWithObject()
    }
    
    override func updateUIWithObject() {
        guard let feedobj = self.mFeedObj else {
            return
        }
        
        super.updateUIWithObject()
        self.postImg.sd_setImage(with: URL(string: feedobj.postUrl), completed: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onClickShareBtn(_ sender: Any) {
        
    }
}
