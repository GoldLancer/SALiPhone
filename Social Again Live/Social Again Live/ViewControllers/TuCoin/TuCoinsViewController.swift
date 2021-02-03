//
//  TuCoinsViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 29.01.2021.
//

import UIKit

protocol TuCoinsViewControllerDelegate {
    func selectedTuCoin(_ amount: Int)
}

class TuCoinsViewController: UIViewController {

    @IBOutlet weak var tucoinsCT: UICollectionView!
    
    var delegate: TuCoinsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init My Posts Collection
        let bundle = Bundle(for: type(of: self))
        let coinCellNib = UINib(nibName: "TuCoinCollectionViewCell", bundle: bundle)
        self.tucoinsCT.register(coinCellNib, forCellWithReuseIdentifier: "TuCoinCollectionViewCell")
        self.tucoinsCT.delegate = self
        self.tucoinsCT.dataSource = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onClickCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension TuCoinsViewController: TuCoinCollectionViewCellDelegate {
    func selectedTUCoins(_ coins: Int) {
        self.delegate?.selectedTuCoin(coins)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: CollectionView Delegations
extension TuCoinsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TUCOIN_ITEMS.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TuCoinCollectionViewCell", for: indexPath) as! TuCoinCollectionViewCell
        cell.delegate = self
        
        cell.coins = TUCOIN_ITEMS[indexPath.row]
        cell.coinLbl.text = "\(TUCOIN_ITEMS[indexPath.row]) TU-Coins"
        
        return cell
    }
}

extension TuCoinsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        self.view.layoutIfNeeded()
        let width: CGFloat = (self.view.bounds.width - 60 - 10 ) / 2
        return CGSize(width: width, height: 60)
    }
}
