//
//  CoinViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 17.12.2020.
//

import UIKit

protocol CoinViewControllerDelegate {
    func selectGift(_ amount: Int, imgName: String, soundName: String)
}

class CoinViewController: UIViewController {

    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var emojiLine: UILabel!
    @IBOutlet weak var emojiLbl: UILabel!
    @IBOutlet weak var heroLine: UILabel!
    @IBOutlet weak var heroLbl: UILabel!
    @IBOutlet weak var superLine: UILabel!
    @IBOutlet weak var superLbl: UILabel!
    @IBOutlet weak var moneyLine: UILabel!
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var coinCountLbl: UILabel!
    @IBOutlet weak var giftCV: UICollectionView!
    
    var delegate: CoinViewControllerDelegate?
    
    var mType: EmojiType = .EMOJI
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init My Posts Collection
        let bundle = Bundle(for: type(of: self))
        let coinCellNib = UINib(nibName: "CoinCollectionViewCell", bundle: bundle)
        self.giftCV.register(coinCellNib, forCellWithReuseIdentifier: "CoinCollectionViewCell")
        self.giftCV.delegate = self
        self.giftCV.dataSource = self
        
        initTabItems()
        self.emojiLbl.textColor = MAIN_YELLOW_COLOR?.withAlphaComponent(1.0)
        self.emojiLine.backgroundColor = MAIN_YELLOW_COLOR?.withAlphaComponent(1.0)
        
        self.dialogView.layer.cornerRadius = 10.0
        
        mType = .EMOJI
        self.giftCV.reloadData()
    }
    
    func initTabItems() {
        let alphaValue: CGFloat = 0.5
        self.emojiLbl.textColor = MAIN_WHITE_COLOR!.withAlphaComponent(alphaValue)
        self.emojiLine.backgroundColor = MAIN_WHITE_COLOR!.withAlphaComponent(alphaValue)
        self.heroLbl.textColor = MAIN_WHITE_COLOR?.withAlphaComponent(alphaValue)
        self.heroLine.backgroundColor = MAIN_WHITE_COLOR!.withAlphaComponent(alphaValue)
        self.superLbl.textColor = MAIN_WHITE_COLOR?.withAlphaComponent(alphaValue)
        self.superLine.backgroundColor = MAIN_WHITE_COLOR!.withAlphaComponent(alphaValue)
        self.moneyLbl.textColor = MAIN_WHITE_COLOR?.withAlphaComponent(alphaValue)
        self.moneyLine.backgroundColor = MAIN_WHITE_COLOR!.withAlphaComponent(alphaValue)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onClickMoneyTab(_ sender: Any) {
        initTabItems()
        self.moneyLbl.textColor = MAIN_YELLOW_COLOR!.withAlphaComponent(1.0)
        self.moneyLine.backgroundColor = MAIN_YELLOW_COLOR!.withAlphaComponent(1.0)
        
        mType = .PRESI
        self.giftCV.reloadData()
    }
    
    @IBAction func onClickHeroTab(_ sender: Any) {
        initTabItems()
        self.heroLbl.textColor = MAIN_YELLOW_COLOR!.withAlphaComponent(1.0)
        self.heroLine.backgroundColor = MAIN_YELLOW_COLOR!.withAlphaComponent(1.0)
        
        mType = .HERO
        self.giftCV.reloadData()
    }
    
    @IBAction func onClickEmojiTab(_ sender: Any) {
        initTabItems()
        self.emojiLbl.textColor = MAIN_YELLOW_COLOR!.withAlphaComponent(1.0)
        self.emojiLine.backgroundColor = MAIN_YELLOW_COLOR!.withAlphaComponent(1.0)
        
        mType = .EMOJI
        self.giftCV.reloadData()
    }
    
    @IBAction func onClickSuperTab(_ sender: Any) {
        initTabItems()
        self.superLbl.textColor = MAIN_YELLOW_COLOR!.withAlphaComponent(1.0)
        self.superLine.backgroundColor = MAIN_YELLOW_COLOR!.withAlphaComponent(1.0)
        
        mType = .SUPER
        self.giftCV.reloadData()
    }
    
    @IBAction func onClickDismissBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: CollectionView Delegations
extension CoinViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        switch mType {
        case .HERO:
            count = 44;
            break;
        case .EMOJI:
            count = 33;
            break;
        case .PRESI:
            count = MONEYCOIN_VALUES.count
            break;
        case .SUPER:
            count = SUPERCOIN_VALUES.count
            break;
        }

        return count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoinCollectionViewCell", for: indexPath) as! CoinCollectionViewCell
        cell.delegate = self
        
        var filename = ""
        var amount = 0
        var rawValue = "coin_emoji";
        let position = indexPath.row
        
        switch mType {
        case .HERO:
            filename = String(format: "tu_hero_%02d", position);
            amount = position > 23 ? 300 : 200
            cell.amountLbl.isHidden = false
            rawValue = "coin_hero"
            break;
        case .EMOJI:
            filename = String(format: "tu_emoji_%02d", position);
            amount = position > 15 ? 50 : 10
            cell.amountLbl.isHidden = false
            rawValue = "coin_emoji"
            break;
        case .PRESI:
            amount = MONEYCOIN_VALUES[position]
            filename = "money_\(amount)"
            cell.amountLbl.isHidden = false
            rawValue = "coin_mark";
            break;
        case .SUPER:
            amount = SUPERCOIN_VALUES[position]
            filename = "super_\(amount)"
            cell.amountLbl.isHidden = true
            rawValue = "coin_animal";
            break;
        }
        
        cell.amountLbl.text = "\(amount)"
        cell.giftImg.image = UIImage(named: filename)
        
        cell.amount = amount
        cell.resourceName = filename
        cell.rawValue = rawValue
        
        return cell
    }
}

extension CoinViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = (self.view.bounds.width - 60 - 10 * 3 ) / 4
        return CGSize(width: width, height: width + 20)
    }
}

extension CoinViewController: CoinCollectionViewCellDelegate {
    func selectGiftWithInfo(_ amount: Int, imgName: String, soundName: String) {
        self.dismiss(animated: true, completion: {
            self.delegate?.selectGift(amount, imgName: imgName, soundName: soundName)
        })
    }
}
