//
//  TermsViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 22.02.2021.
//

import UIKit
import WebKit

class TermsViewController: UIViewController {

    @IBOutlet weak var htmlView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        htmlView.isOpaque = false
        htmlView.scrollView.showsVerticalScrollIndicator = false
        
        guard let filePath = Bundle.main.path(forResource: "terms", ofType: "html")
            else {
                // File Error
                print ("File reading error")
                return
        }
        
        let request = NSURLRequest(url: URL(fileURLWithPath: filePath))
        htmlView.load(request as URLRequest)
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

}
