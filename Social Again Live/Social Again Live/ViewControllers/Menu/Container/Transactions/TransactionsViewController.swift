//
//  TransactionsViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 05.02.2021.
//

import UIKit
import Firebase

class TransactionsViewController: BaseViewController {

    @IBOutlet weak var transactionsTV: UITableView!
    
    var transList: [TransObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addNavItem()
        
        // Init Ranking List
        let bundle = Bundle(for: type(of: self))
        let transCellNib = UINib(nibName: "TransactionableViewCell", bundle: bundle)
        self.transactionsTV.register(transCellNib, forCellReuseIdentifier: "TransactionableViewCell")
        self.transactionsTV.delegate = self
        self.transactionsTV.dataSource = self
        
        
    }
    
    private func loadTransactions() {
        self.showLoadingView("Loading...")
        Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.TRANSACTIONS).observeSingleEvent(of: .value) { (snapshot) in
            for snap in snapshot.children {
                let snapData = snap as! DataSnapshot
                if let jsonData = snapData.value as? NSDictionary {
                    let transObj = TransObject()
                    transObj.initObjectFromJSON(jsonData)
                    
                    self.transList.append(transObj)
                }
            }
            
            self.transactionsTV.reloadData()
            self.hideLoadingView()
        }
    }
    
    private func addNavItem() {
        
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
    
    private func isExpiredPurchasing(_ time: UInt64) -> Bool {
        let startedAt = Date(timeIntervalSince1970: TimeInterval(time/1000))
        let endAt = startedAt.addDay(n: 1)
        let current = Date()
        
        return current > endAt
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
        self.navigationController?.popViewController(animated: true)
    }

}

extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionableViewCell", for: indexPath as IndexPath) as! TransactionableViewCell
        
        let transObj = self.transList[indexPath.row]
        
        cell.priceLbl.text = "$\(transObj.price)"
        cell.beginLBl.text = Global.getPurchseDateTimeFromTimeMillis(transObj.startTime)
        if transObj.type == .SUBS {
            cell.endLbl.text = Global.getPurchseEndDateTimeFromTimeMillis(transObj.startTime)
        } else {
            cell.endLbl.text = "--"
        }
        
        if self.isExpiredPurchasing(transObj.startTime) {
            cell.statusLbl.text = "Expired"
        } else {
            cell.statusLbl.text = transObj.status
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
