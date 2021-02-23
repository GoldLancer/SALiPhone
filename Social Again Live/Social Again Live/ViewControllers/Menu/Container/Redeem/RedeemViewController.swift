//
//  RedeemViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 10.02.2021.
//

import UIKit
import Firebase

protocol RedeemViewControllerDelegate {
    func finishedSending()
}

class RedeemViewController: BaseViewController {

    @IBOutlet weak var coinBtn: RoundButton!
    @IBOutlet weak var redeemTV: UICollectionView!
    @IBOutlet weak var sendingView: UIView!
    @IBOutlet weak var cashamountLbl: UILabel!
    @IBOutlet weak var paymentEmailTxt: RoundTextField!
    
    var delegate: RedeemViewControllerDelegate?
    var redeemAmount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addNavItem()
        self.sendingView.isHidden = true
        self.coinBtn.setTitle("\(Global.mCurrentUser!.coin)", for: .normal)
        self.paymentEmailTxt.text = Global.mCurrentUser!.email
        
        // Init My Posts Collection
        let bundle = Bundle(for: type(of: self))
        let coinCellNib = UINib(nibName: "TuCoinCollectionViewCell", bundle: bundle)
        self.redeemTV.register(coinCellNib, forCellWithReuseIdentifier: "TuCoinCollectionViewCell")
        self.redeemTV.delegate = self
        self.redeemTV.dataSource = self
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
    
    @IBAction func onClickSendBtn(_ sender: Any) {
        let paymentEmail = self.paymentEmailTxt.text!
        
        if paymentEmail.isEmpty || !Global.isValidEmail(paymentEmail) {
            self.showAlertWithText(errorText: "Please enter valid payment email")
            return
        }
        
        let requestObj = RequestObject()
        requestObj.id = Global.getCurrentTimeintervalString()
        requestObj.title = "Redeem Request"
        requestObj.requesterId = Global.mCurrentUser!.id
        requestObj.requesterName = Global.mCurrentUser!.name
        requestObj.redeem_coin_amount = self.redeemAmount
        requestObj.paymentEmail = paymentEmail
        requestObj.paymentMethod = .PAYPAL
        requestObj.type = .REDEEM
        
        let reqRef = Database.database().reference().child(REQUEST_DB_NAME)
        reqRef.child(requestObj.id).setValue(requestObj.getJsonvalue())
        
        self.delegate?.finishedSending()
        self.navigationController?.popViewController(animated: true)
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

extension RedeemViewController: TuCoinCollectionViewCellDelegate {
    func selectedTUCoins(_ index: Int) {
//        self.delegate?.selectedTuCoin(coins)
//        self.dismiss(animated: true, completion: nil)
        let coins = REDEEM_ITEMS[index]
//        if coins > Global.mCurrentUser!.coin {
//            self.showAlertWithText(errorText: "You don't have enough coins!")
//        } else {
            self.cashamountLbl.text = "\(coins)"
            self.sendingView.isHidden = false
            self.redeemAmount = coins
//        }
    }
}

// MARK: CollectionView Delegations
extension RedeemViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return REDEEM_ITEMS.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TuCoinCollectionViewCell", for: indexPath) as! TuCoinCollectionViewCell
        cell.delegate = self
        
        cell.cellIndex = indexPath.row
        cell.coinLbl.text = "\(REDEEM_ITEMS[indexPath.row]) TU-Coins"
        
        return cell
    }
}

extension RedeemViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        self.view.layoutIfNeeded()
        let width: CGFloat = (self.view.bounds.width - 30 ) / 2
        return CGSize(width: width, height: 60)
    }
}
