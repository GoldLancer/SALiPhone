//
//  UpgradeViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 27.01.2021.
//

import UIKit
import SwiftyStoreKit

protocol UpgradeViewControllerDelegate {
    func finishedPurchasing(_ result: String)
}

class UpgradeViewController: BaseViewController {

    @IBOutlet weak var iapItemCV: UICollectionView!
    
    @IBOutlet var confirmLeadLayout: NSLayoutConstraint!
    
    var delegate: UpgradeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()

        let bundle = Bundle(for: type(of: self))
        let iapCellNib = UINib(nibName: "InAppCollectionViewCell", bundle: bundle)
        self.iapItemCV.register(iapCellNib, forCellWithReuseIdentifier: "InAppCollectionViewCell")
        self.iapItemCV.delegate = self
        self.iapItemCV.dataSource = self
    }
    
    @IBAction func onClickUpgradeBtn(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.confirmLeadLayout.constant = 0
        }
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickConfirmBtn(_ sender: Any) {
        self.showLoadingView("")
        
        SwiftyStoreKit.purchaseProduct(IAP_MONTHLY_SUB_ID) { (result) in
            if case .success(let purchase) = result {
                
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                let timeInterval = Global.getCurrentTimeintervalUint()
                let transObj = TransObject()
                transObj.transactionID = "\(timeInterval)"
                transObj.price = 10.0
                transObj.productId = purchase.productId
                transObj.type = .SUBS
                transObj.startTime = timeInterval
                
                var isSuccessed = false
                switch purchase.transaction.transactionState {
                case .purchased:
                    transObj.status = "Purchased"
                    isSuccessed = true
                    break
                case .purchasing:
                    transObj.status = "Purchasing"
                    break
                case .restored:
                    transObj.status = "Restored"
                    break
                default:
                    transObj.status = "Failed"
                    break
                }
                
                Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.TRANSACTIONS).child(transObj.transactionID).setValue(transObj.getJsonValueOfObject())
                
                Global.mCurrentUser!.isUpgraded = isSuccessed
                Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.IS_UPGRADED).setValue(isSuccessed)
                
                if isSuccessed {
                    Global.mCurrentUser!.coin += 50
                    Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.COIN).setValue(Global.mCurrentUser!.coin)
                    
                    Global.mCurrentUser!.upgraded_time = Global.getCurrentTimeintervalUint()
                    Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.UPGRADED_TIME).setValue(Global.mCurrentUser!.upgraded_time)
                    
                    self.delegate?.finishedPurchasing("Your account was upgraded!")
                } else {
                    self.delegate?.finishedPurchasing("Purchasing failed!")
                }
                
                
                /*
                let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: IAP_SHARED_SECRET)
                SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                    
                    self.hideLoadingView()
                    if case .error (let error) = result {
                        self.showAlertWithText(errorText: error.localizedDescription)
                        return
                    }
                    
                    if case .success(let receipt) = result {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable,
                            productId: IAP_MONTHLY_SUB_ID,
                            inReceipt: receipt)
                        
                        var isPurchased = false
                        switch purchaseResult {
                        case .purchased( _, _):
                            isPurchased = true
                        case .expired( _, _):
                            break
                        case .notPurchased:
                            break
                        }
                        
                        Global.mCurrentUser!.isUpgraded = isPurchased
                        Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.IS_UPGRADED).setValue(isPurchased)
                        
                        if isPurchased {
                            Global.mCurrentUser!.upgraded_time = Global.getCurrentTimeintervalUint()
                            Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.UPGRADED_TIME).setValue(Global.mCurrentUser!.upgraded_time)
                        }
                        
                        self.delegate?.finishedPurchasing("Your account was upgraded!")
                        
                    } else {
                        // receipt verification error
                        self.delegate?.finishedPurchasing("Purchasing Failed")
                    }
                } */
                
                self.dismiss(animated: true, completion: nil)
                
            } else {
                self.hideLoadingView()
            }
        }
    }
    
    func buyCoin(_ index: Int) {
        let coins = IAP_ITEM_COINS[index]
        let iapItemId = "sal.iap.\(coins)coins"
        
        self.showLoadingView("")
        SwiftyStoreKit.purchaseProduct(iapItemId) { (result) in
            self.hideLoadingView()
            
            if case .success(let purchase) = result {
                
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                var isSuccessed = false
                var transStatus = ""
                switch purchase.transaction.transactionState {
                case .purchased:
                    transStatus = "Purchased"
                    isSuccessed = true
                    break
                    
                default:
                    transStatus = "Failed"
                    break
                }
                
                if isSuccessed {
                    let timeInterval = Global.getCurrentTimeintervalUint()
                    let transObj = TransObject()
                    transObj.transactionID = "\(timeInterval)"
                    transObj.price = 10.0
                    transObj.productId = purchase.productId
                    transObj.type = .INAPP
                    transObj.startTime = timeInterval
                    transObj.status = transStatus
                    
                    Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.TRANSACTIONS).child(transObj.transactionID).setValue(transObj.getJsonValueOfObject())
                    
                    Global.mCurrentUser!.coin += coins
                    Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.COIN).setValue(Global.mCurrentUser!.coin)
                    
                    self.delegate?.finishedPurchasing("Your account was upgraded!")
                } else {
                    self.delegate?.finishedPurchasing("Purchasing failed!")
                }
                
                self.dismiss(animated: true, completion: nil)
            }
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

}

// MARK: CollectionView Delegations
extension UpgradeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return IAP_ITEM_ICONS.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InAppCollectionViewCell", for: indexPath) as! InAppCollectionViewCell
        cell.itemIndex = indexPath.row
        cell.delegate = self
        
        cell.coinImg.image = UIImage(named: IAP_ITEM_ICONS[indexPath.row])
        cell.costTxt.text = "$\(IAP_ITEM_COSTS[indexPath.row])"
        
        return cell
    }
}

extension UpgradeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = (self.iapItemCV.bounds.width - 10) / 2
        return CGSize(width: cellWidth, height: 170)
    }
}

extension UpgradeViewController: InAppCollectionViewCellDelegate {
    func selectedItemForBuyCoin(_ itemIndex: Int) {
        self.buyCoin(itemIndex)
    }
}
