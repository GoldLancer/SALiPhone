//
//  CategoryViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 13.01.2021.
//

import UIKit

protocol CategoryViewControllerDelegate {
    func selectedCategory(ctIndex: Int)
}

class CategoryViewController: UIViewController {

    @IBOutlet weak var ctCollectionView: UICollectionView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var delegate: CategoryViewControllerDelegate?
    var currentCTIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init My Posts Collection
        let bundle = Bundle(for: type(of: self))
        let coinCellNib = UINib(nibName: "CTCollectionViewCell", bundle: bundle)
        self.ctCollectionView.register(coinCellNib, forCellWithReuseIdentifier: "CTCollectionViewCell")
        self.ctCollectionView.delegate = self
        self.ctCollectionView.dataSource = self

    }
    

    @IBAction func onClickCloseBtn(_ sender: Any) {
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

// MARK: CollectionView Delegations
extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CATEGORY_ITEMS.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CTCollectionViewCell", for: indexPath) as! CTCollectionViewCell
        cell.delegate = self
        
        cell.ctIndex = indexPath.row
        cell.categoryBtn.setTitle("    \(CATEGORY_ITEMS[indexPath.row])    ", for: .normal)
        if indexPath.row == currentCTIndex {
            cell.categoryBtn.backgroundColor = UIColor(named: "main_yellow_color")
        } else {
            cell.categoryBtn.backgroundColor = UIColor.clear
        }
        let frame = cell.categoryBtn.frame
        cell.categoryBtn.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width + 30.0, height: frame.height)
        
        return cell
    }
}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = (self.view.bounds.width - 60 - 50 ) / 2
        return CGSize(width: width, height: 60)
    }
}

extension CategoryViewController: CTCollectionViewCellDelegate {
    func selectCT(index: Int) {
        
        self.delegate?.selectedCategory(ctIndex: index)
        currentCTIndex = index
        
        self.dismiss(animated: true, completion: nil)
    }
}
