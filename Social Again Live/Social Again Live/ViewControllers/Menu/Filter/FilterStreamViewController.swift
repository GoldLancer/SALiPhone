//
//  FilterStreamViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 11.12.2020.
//

import UIKit

protocol FilterStreamViewControllerDelegate {
    func filterByKeys(nameKey: String, countryKey: String, genderKey: String)
    func resetFilter()
}

class FilterStreamViewController: UIViewController {

    @IBOutlet weak var usernameTV: UITextField!
    @IBOutlet weak var countryCV: UICollectionView!
    @IBOutlet weak var allGenderBtn: RoundButton!
    @IBOutlet weak var maleGenderBtn: RoundButton!
    @IBOutlet weak var femaleGenderBtn: RoundButton!
    
    var delegate: FilterStreamViewControllerDelegate?
    
    let COUNTRY_CELL_HEIGHT: CGFloat   = 45.0
    
    private var selectedCountryIndex: Int = -1
    private var countryKey: String = ""
    private var usernameKey: String = ""
    private var genderKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Init Country CollectionView
        let bundle = Bundle(for: type(of: self))
        let countryCellNib = UINib(nibName: "CategoryCollectionViewCell", bundle: bundle)
        self.countryCV.register(countryCellNib, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        self.countryCV.delegate = self
        self.countryCV.dataSource = self
        
        reloadCollectionView()
    }
    
    func initGenderRadio() {
        self.allGenderBtn.backgroundColor = MAIN_WHITE_COLOR
        self.maleGenderBtn.backgroundColor = MAIN_WHITE_COLOR
        self.femaleGenderBtn.backgroundColor = MAIN_WHITE_COLOR
    }
    
    func reloadCollectionView() {
        self.countryCV.reloadData()
        /*
        var cvHeight = self.countryCV.contentSize.height
        if cvHeight > 150 {
            cvHeight = 150.0
        }
        
        self.countryCVHeightLayout.constant = 180
        self.view.layoutIfNeeded() */
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onClickFemaleGenderBtn(_ sender: Any) {
        initGenderRadio()
        self.femaleGenderBtn.backgroundColor = MAIN_YELLOW_COLOR
        self.genderKey = "Female"
    }
    
    @IBAction func onClickMaleGenderBtn(_ sender: Any) {
        initGenderRadio()
        self.maleGenderBtn.backgroundColor = MAIN_YELLOW_COLOR
        self.genderKey = "Male"
    }
    
    @IBAction func onClickAllGenderBtn(_ sender: Any) {
        initGenderRadio()
        self.allGenderBtn.backgroundColor = MAIN_YELLOW_COLOR
        self.genderKey = ""
    }
    
    @IBAction func onClickFilterBtn(_ sender: Any) {
        self.usernameKey = self.usernameTV.text!.trimmingCharacters(in: .whitespaces)
        self.delegate?.filterByKeys(nameKey: self.usernameKey, countryKey: self.countryKey, genderKey: self.genderKey)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickClearBtn(_ sender: Any) {
        self.usernameKey = ""
        self.genderKey = ""
        self.countryKey = ""
        
        self.usernameTV.text = ""
        self.selectedCountryIndex = -1
        self.countryCV.reloadData()
        self.initGenderRadio()
        
        self.delegate?.resetFilter()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: CollectionView Delegation
extension FilterStreamViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Global.countryObjs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        cell.delegate = self
        
        cell.categoryIndex = indexPath.row
        let isSelected = (indexPath.row == self.selectedCountryIndex)
        if isSelected {
            cell.roundView.backgroundColor = MAIN_YELLOW_COLOR
        } else {
            cell.roundView.backgroundColor = MAIN_WHITE_COLOR
        }
        cell.roundView.setCornerRadius((COUNTRY_CELL_HEIGHT - 10)/2)
        let cObj = Global.countryObjs[indexPath.row]
        cell.categoryLbl.text = cObj.name
        
        return cell
    }
}

extension FilterStreamViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cObj = Global.countryObjs[indexPath.row]
        let itemName = cObj.name
        let cellWidth = itemName.widthWithConstrainedHeight(COUNTRY_CELL_HEIGHT, font: UIFont(name: "Montserrat-Light", size: 16.0)!) + 30
        return CGSize(width: cellWidth, height: COUNTRY_CELL_HEIGHT)
    }
}

extension FilterStreamViewController: CategoryCollectionViewCellDelegate {
    func onSelectCategory(_ index: Int) {
        let cObj = Global.countryObjs[index]
        
        self.selectedCountryIndex = index
        self.countryKey = cObj.name
        self.reloadCollectionView()
    }
}
