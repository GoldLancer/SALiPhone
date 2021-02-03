//
//  UpgradeViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 27.01.2021.
//

import UIKit

class UpgradeViewController: UIViewController {

    @IBOutlet weak var iapItemCV: UICollectionView!
    
    @IBOutlet var confirmLeadLayout: NSLayoutConstraint!
    
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
        
    }
}
