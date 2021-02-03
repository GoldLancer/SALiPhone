//
//  FindUserViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 19.01.2021.
//

import UIKit
import Firebase
import SKCountryPicker

enum FilterType: String {
    case CITY       = "city"
    case STATE      = "state"
    case ZIPCODE    = "zipcode"
}

class FindUserViewController: BaseViewController {

    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var optionViewTitle: UILabel!
    @IBOutlet weak var optionText: RoundTextField!
    
    @IBOutlet weak var countryFTLbl: UILabel!
    @IBOutlet weak var stateFTLbl: UILabel!
    @IBOutlet weak var cityFTLbl: UILabel!
    @IBOutlet weak var zipcodeFTLbl: UILabel!
    @IBOutlet weak var nameSearchTxt: UITextField!
    @IBOutlet weak var userListTV: UITableView!
    
    var userList: [UserObject] = []
    var mFilterType: FilterType = .CITY
    var countryKey: String = ""
    var stateKey: String = ""
    var cityKey: String = ""
    var zipcodeKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init ContactList
        let bundle = Bundle(for: type(of: self))
        let followCellNib = UINib(nibName: "FollowTableViewCell", bundle: bundle)
        self.userListTV.register(followCellNib, forCellReuseIdentifier: "FollowTableViewCell")
        self.userListTV.delegate = self
        self.userListTV.dataSource = self
        
        self.nameSearchTxt.attributedPlaceholder = NSAttributedString(string: "Search by User Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        
        self.optionView.isHidden = true
        initOptionButtons()
        
        // MARK: Add Notification
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFollowUserList), name: .didReloadFollowers, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFollowUserList), name: .didReloadFollowings, object:nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func reloadFollowUserList() {
        self.userListTV.reloadData()
    }
    
    func showFilterOptionView(_ ftType: FilterType) {
        var title = "Input"
        switch ftType {
        case .CITY:
            title = "Input City"
            break
        case .STATE:
            title = "Input State"
            break
        case .ZIPCODE:
            title = "Input Zipcode"
            break
        }
        
        self.mFilterType = ftType
        self.optionViewTitle.text = title
        self.optionText.text = ""
        
        UIView.animate(withDuration: 0.3) {
            self.optionView.isHidden = false
        }
    }
    
    func initOptionButtons() {
        self.countryFTLbl.text = "Country"
        self.cityFTLbl.text = "City"
        self.stateFTLbl.text = "State"
        self.zipcodeFTLbl.text = "Zipcode"
        
        self.countryFTLbl.textColor = UIColor.white
        self.cityFTLbl.textColor = UIColor.white
        self.stateFTLbl.textColor = UIColor.white
        self.zipcodeFTLbl.textColor = UIColor.white
        
        self.countryKey = ""
        self.cityKey = ""
        self.stateKey = ""
        self.zipcodeKey = ""
    }
    
    @IBAction func onClickSearchBtn(_ sender: Any) {
        let nameKey = self.nameSearchTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if countryKey.isEmpty && stateKey.isEmpty && cityKey.isEmpty && zipcodeKey.isEmpty && nameKey.isEmpty {
            self.userList.removeAll()
            self.userListTV.reloadData()
        }
        
        self.showLoadingView("Finding...")
        Global.userRef.observeSingleEvent(of: .value) { (snapshot) in
            self.userList.removeAll()
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let data = snap.value as? NSDictionary {
                    let uObj = UserObject()
                    uObj.initUserWithJsonresponse(value: data)
                    
                    if uObj.id == Global.mCurrentUser!.id {
                        continue
                    }
                    
                    if !self.countryKey.isEmpty && uObj.country.lowercased() != self.countryKey.lowercased() {
                        continue
                    }
                    
                    if !self.cityKey.isEmpty && uObj.city.lowercased() != self.cityKey.lowercased() {
                        continue
                    }
                    
                    if !self.stateKey.isEmpty && uObj.state.lowercased() != self.stateKey.lowercased() {
                        continue
                    }
                    
                    if !self.zipcodeKey.isEmpty && uObj.zipcode.lowercased() != self.zipcodeKey.lowercased() {
                        continue
                    }
                    
                    if !nameKey.isEmpty && !uObj.name.lowercased().contains(nameKey.lowercased()) {
                        continue
                    }
                        
                    self.userList.append(uObj)
                }
            }
            
            
            self.userList.sort(by: {$0.name < $1.name})
            self.userListTV.reloadData()
            
            self.hideLoadingView()
        }
    }
    
    @IBAction func onClickZipcodeFTBtn(_ sender: Any) {
        showFilterOptionView(.ZIPCODE)
    }
    
    @IBAction func onClickCityFTBtn(_ sender: Any) {
        showFilterOptionView(.CITY)
    }
    
    @IBAction func onClickStateFTBtn(_ sender: Any) {
        showFilterOptionView(.STATE)
    }
    
    @IBAction func onClickCountryFTBtn(_ sender: Any) {
        _ = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
            guard let self = self else { return }

            self.countryFTLbl.text = country.countryName
            self.countryFTLbl.textColor = MAIN_YELLOW_COLOR
            
            self.countryKey = country.countryName
        }
    }
    
    @IBAction func onClickClearBtn(_ sender: Any) {
        initOptionButtons()
        
        self.nameSearchTxt.text = ""
        self.userList.removeAll()
        self.userListTV.reloadData()
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickDoneOptionView(_ sender: Any) {
        let optionStr = self.optionText.text
        if optionStr!.isEmpty {
            return
        }
        
        switch self.mFilterType {
        case .CITY:
            cityKey = optionStr!
            self.cityFTLbl.text = cityKey
            self.cityFTLbl.textColor = MAIN_YELLOW_COLOR
            break
        case .STATE:
            stateKey = optionStr!
            self.stateFTLbl.text = stateKey
            self.stateFTLbl.textColor = MAIN_YELLOW_COLOR
            break
        case .ZIPCODE:
            zipcodeKey = optionStr!
            self.zipcodeFTLbl.text = zipcodeKey
            self.zipcodeFTLbl.textColor = MAIN_YELLOW_COLOR
            break
        }
        
        UIView.animate(withDuration: 0.2) {
            self.optionView.isHidden = true
        }
    }
    
    @IBAction func onClickCloseOptionView(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.optionView.isHidden = true
        }
    }
}

extension FindUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath as IndexPath) as! FollowTableViewCell
        
        cell.delegate = self
        cell.cellIndex = indexPath.row
        
        let userObj = self.userList[indexPath.row]
        
        let followed = Global.alreadyFollowed(userObj.id)
        cell.followBtn.setTitle(followed ? "UnFollow" : "Follow", for: .normal)
        
        cell.countryLbl.text = userObj.country
        cell.userNameLbl.text = userObj.name
        cell.userProfileImg.sd_setImage(with: URL(string: userObj.avatar), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], completed: nil)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}

extension FindUserViewController: FollowTableViewCellDelegate {
    func clickedUserProfile(_ cellIndex: Int) {
        let userObj = self.userList[cellIndex]
        
        self.showUserProfileView(userObj.id)
    }
    
    func clickedFollowingBtn(_ cellIndex: Int) {
        let userObj = self.userList[cellIndex]
        
        _ = Global.followUser(userObj.id)
    }
}
