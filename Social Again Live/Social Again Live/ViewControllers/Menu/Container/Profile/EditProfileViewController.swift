//
//  EditProfileViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 12.01.2021.
//

import UIKit
import Firebase
import SKCountryPicker

class EditProfileViewController: BaseViewController {

    @IBOutlet weak var nameTxt: RoundGreenTextField!
    @IBOutlet weak var aboutMeTxt: UITextView!
    @IBOutlet weak var birthBtn: UIButton!
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var countryBtn: UIButton!
    @IBOutlet weak var cityTxt: RoundGreenTextField!
    @IBOutlet weak var stateTxt: RoundGreenTextField!
    @IBOutlet weak var zipcodeTxt: RoundGreenTextField!
    @IBOutlet weak var categoryBtn: UIButton!
    
    var birthYear: Int = 0
    var birthMonth: Int = 0
    var birthDay: Int = 0
    var ctIndex: Int = 0
    var countryName: String = ""
    var countryObj: CountryObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addNavItem()
        initUserInfo()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func selectedCategoryWithIndex(ctIndex: Int) {
        super.selectedCategoryWithIndex(ctIndex: ctIndex)
        
        self.ctIndex = ctIndex
        self.categoryBtn.setTitle(CATEGORY_ITEMS[ctIndex], for: .normal)
    }
    
    func initUserInfo() {
        self.nameTxt.text = Global.mCurrentUser!.name
        self.aboutMeTxt.text = Global.mCurrentUser!.aboutme
        
        countryName = Global.mCurrentUser!.country
        birthYear = Global.mCurrentUser!.birthYear
        birthMonth = Global.mCurrentUser!.birthMonth
        birthDay = Global.mCurrentUser!.birthDay
        
        let calendar = Calendar.current
        var dateComponents: DateComponents? = calendar.dateComponents([.hour, .minute, .second], from: Date())

        if birthYear != 0 {
            dateComponents?.day = birthDay
            dateComponents?.month = birthMonth + 1
            dateComponents?.year = birthYear
            let selectedDate: Date? = calendar.date(from: dateComponents!)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM dd, yyyy"
            let date = formatter.string(from: selectedDate ?? Date())
            
            self.birthBtn.setTitle(date, for: .normal)
            
        } else {
            self.birthBtn.setTitle("", for: .normal)
        }
        
        self.genderBtn.setTitle(Global.mCurrentUser!.gender, for: .normal)
        self.countryBtn.setTitle(self.countryName, for: .normal)
        self.cityTxt.text = Global.mCurrentUser!.city
        self.stateTxt.text = Global.mCurrentUser!.state
        self.zipcodeTxt.text = Global.mCurrentUser!.zipcode
        
        let categoryName = Global.mCurrentUser!.category
        
        for (i, name) in CATEGORY_ITEMS.enumerated() {
            if name == categoryName {
                self.ctIndex = i
                break
            }
        }
        self.categoryBtn.setTitle(Global.mCurrentUser!.category, for: .normal)
        
    }
    
    func addNavItem() {
        
        // Add Navigation Left Button
        let backBtn = UIButton()
        backBtn.frame = CGRect(x: -30, y: 0, width: 30, height: 30)
        backBtn.setImage(UIImage(named: "btn_back"), for: .normal)
        backBtn.addTarget(self, action:#selector(onClickBackBtn(_:)), for: .touchUpInside)
        let leftBarItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.setLeftBarButton(leftBarItem, animated: true)
        
        // Add Navigation Right Button
        let saveBtn = UIButton()
        saveBtn.backgroundColor = MAIN_GREEN_COLOR
        saveBtn.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        saveBtn.setTitle("Save", for: .normal)
        saveBtn.titleLabel?.font = UIFont(name: FONT_NAME_MONT_MEDIUM, size: 13)
        saveBtn.layer.cornerRadius = 15
        saveBtn.addTarget(self, action:#selector(onClickSaveBtn(_:)), for: .touchUpInside)
        let rightBarItem = UIBarButtonItem(customView: saveBtn)
        self.navigationItem.setRightBarButton(rightBarItem, animated: true)
        
        // Add Navigation Title
        let logoImg = UIImageView(image: UIImage(named: "ic_nav_logo"))
        logoImg.contentMode = .scaleAspectFit
        self.navigationItem.titleView = logoImg
        
    }
    
    func saveUserInfo() {
        Global.mCurrentUser!.name       = self.nameTxt.text!
        Global.mCurrentUser!.aboutme    = self.aboutMeTxt.text
        Global.mCurrentUser!.birthYear  = self.birthYear
        Global.mCurrentUser!.birthMonth = self.birthMonth
        Global.mCurrentUser!.birthDay   = self.birthDay
        Global.mCurrentUser!.gender     = self.genderBtn.title(for: .normal)!
        Global.mCurrentUser!.country    = self.countryBtn.title(for: .normal)!
        Global.mCurrentUser!.city       = self.cityTxt.text!
        Global.mCurrentUser!.state      = self.stateTxt.text!
        Global.mCurrentUser!.zipcode    = self.zipcodeTxt.text!
        Global.mCurrentUser!.category   = self.categoryBtn.title(for: .normal)!
        
        Global.mCurrentUser!.uploadObjectToFirebase()
        Global.videoRef.child(Global.mCurrentUser!.streamID).child(StreamConstant.OWNER).setValue(Global.mCurrentUser!.getBaseJsonvalue())
        
        if let cObj = self.countryObj {
            cObj.uploadObjectToFirebase()
        }
    }
    
    func showDateDialog() {
        let storyboard = UIStoryboard(name: "Date", bundle: nil)
        if let dateDialog = storyboard.instantiateViewController(withIdentifier: "DateDialog") as? DateViewController {
            dateDialog.delegate = self
            dateDialog.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            dateDialog.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            dateDialog.setDateValue(year: self.birthYear, month: self.birthMonth, day: self.birthDay)
            self.present(dateDialog, animated: true, completion: nil)
        }
    }
    
    func showGenderDialog() {
        let storyboard = UIStoryboard(name: "Gender", bundle: nil)
        if let genderDialog = storyboard.instantiateViewController(withIdentifier: "GenderDialog") as? GenderViewController {
            genderDialog.delegate = self
            genderDialog.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            genderDialog.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(genderDialog, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSaveBtn(_ sender: Any) {
        saveUserInfo()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickBirthBtn(_ sender: Any) {
        showDateDialog()
    }
    
    @IBAction func onClickGenderBtn(_ sender: Any) {
        showGenderDialog()
    }
    
    @IBAction func onClickCountryBtn(_ sender: Any) {
        _ = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
            guard let self = self else { return }

            self.countryBtn.setTitle(country.countryName, for: .normal)
            
            self.countryObj = CountryObject()
            self.countryObj!.name = country.countryName
            self.countryObj!.countryCode = country.countryCode
        }
    }
    
    @IBAction func onClickCategoryBtn(_ sender: Any) {
        self.showCategoryDialog(self.ctIndex)
    }
}

extension EditProfileViewController: DateViewControllerDelegate {
    func selectedDate(selectedDate: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        let dateStr = formatter.string(from: selectedDate)
        self.birthBtn.setTitle(dateStr, for: .normal)
        
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: selectedDate)
        self.birthYear = Int(year) ?? 0
        formatter.dateFormat = "MM"
        let month = formatter.string(from: selectedDate)
        self.birthMonth = (Int(month) ?? 1) - 1
        formatter.dateFormat = "dd"
        let day = formatter.string(from: selectedDate)
        self.birthDay = Int(day) ?? 0
    }
}

extension EditProfileViewController: GenderViewControllerDelegate {
    func selectGender(_ isFemale: Bool) {
        self.genderBtn.setTitle(isFemale ? "Female" : "Male", for: .normal)
    }
}

