//
//  RankingViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 22.01.2021.
//

import UIKit
import Firebase
import SKCountryPicker

class RankingViewController: BaseViewController {

    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var firstProfileImg: ProfileGreenImageView!
    @IBOutlet weak var firstFlagImg: UIImageView!
    @IBOutlet weak var firstCountLbl: UILabel!
    @IBOutlet weak var firstNameLbl: UILabel!
    @IBOutlet weak var firstFollowBtn: RoundButton!
    
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var secondNameLbl: UILabel!
    @IBOutlet weak var secondProfileImg: ProfileGreenImageView!
    @IBOutlet weak var secondFlagImg: UIImageView!
    @IBOutlet weak var secondCountLbl: UILabel!
    @IBOutlet weak var secondFollowBtn: RoundButton!
    
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var thirdNameLbl: UILabel!
    @IBOutlet weak var thirdProfileImg: ProfileGreenImageView!
    @IBOutlet weak var thirdFlagImg: UIImageView!
    @IBOutlet weak var thirdCountLbl: UILabel!
    @IBOutlet weak var thirdFollowBtn: RoundButton!
    
    @IBOutlet weak var rankingTV: UITableView!
    
    var firstUserObj: UserObject? = nil
    var secondUserObj: UserObject? = nil
    var thirdUserObj: UserObject? = nil
    
    var rankList:[UserObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavItem()
        
        // Init Ranking List
        let bundle = Bundle(for: type(of: self))
        let rankCellNib = UINib(nibName: "RankingTableViewCell", bundle: bundle)
        self.rankingTV.register(rankCellNib, forCellReuseIdentifier: "RankingTableViewCell")
        self.rankingTV.delegate = self
        self.rankingTV.dataSource = self

        self.firstView.isHidden = true
        self.secondView.isHidden = true
        self.thirdView.isHidden = true
        
        self.showLoadingView("Loading...")
        Global.userRef.observeSingleEvent(of: .value) { (snapshot) in
            
            var userList: [UserObject] = []
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let data = snap.value as? NSDictionary {
                    let uObj = UserObject()
                    uObj.initUserWithJsonresponse(value: data)
                    
                    userList.append(uObj)
                }
            }
            
            userList.sort(by: { $0.likes.count > $1.likes.count })
            if userList.count > 0 {
                self.firstUserObj = userList[0]
            }
            if userList.count > 1 {
                self.secondUserObj = userList[1]
            }
            if userList.count > 2 {
                self.thirdUserObj = userList[2]
            }
            
            let count: Int = userList.count < 50 ? userList.count : 50
            if userList.count > 3 {
                for i in 3..<count {
                    let uObj = userList[i]
                    self.rankList.append(uObj)
                }
            }
            
            self.updateUI()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFollowUsers), name: .didReloadFollowers, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFollowUsers), name: .didReloadFollowings, object:nil)
        
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
    
    @objc func reloadFollowUsers() {
        self.rankingTV.reloadData()
    }
    
    func updateUI() {
        if self.firstUserObj != nil {
            self.firstView.isHidden = false
            
            self.firstNameLbl.text = self.firstUserObj!.name
            self.firstProfileImg.sd_setImage(with: URL(string: self.firstUserObj!.avatar), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], completed: nil)
            self.loadCountryFlag(self.firstUserObj!.country, flagView: self.firstFlagImg)
            self.firstCountLbl.text = "\(self.firstUserObj!.likes.count)"
            
            let followed = Global.alreadyFollowed(self.firstUserObj!.id)
            self.firstFollowBtn.setTitle(followed ? "UnFollow" : "Follow", for: .normal)
            
        } else {
            self.firstView.isHidden = true
        }
        
        if self.secondUserObj != nil {
            self.secondView.isHidden = false
            
            self.secondNameLbl.text = self.secondUserObj!.name
            self.secondProfileImg.sd_setImage(with: URL(string: self.secondUserObj!.avatar), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], completed: nil)
            self.loadCountryFlag(self.secondUserObj!.country, flagView: self.secondFlagImg)
            self.secondCountLbl.text = "\(self.secondUserObj!.likes.count)"
            
            let followed = Global.alreadyFollowed(self.secondUserObj!.id)
            self.secondFollowBtn.setTitle(followed ? "UnFollow" : "Follow", for: .normal)
            
        } else {
            self.secondView.isHidden = true
        }
        
        if self.thirdUserObj != nil {
            self.thirdView.isHidden = false
            
            self.thirdNameLbl.text = self.thirdUserObj!.name
            self.thirdProfileImg.sd_setImage(with: URL(string: self.thirdUserObj!.avatar), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], completed: nil)
            self.loadCountryFlag(self.thirdUserObj!.country, flagView: self.thirdFlagImg)
            self.thirdCountLbl.text = "\(self.thirdUserObj!.likes.count)"
            
            let followed = Global.alreadyFollowed(self.thirdUserObj!.id)
            self.thirdFollowBtn.setTitle(followed ? "UnFollow" : "Follow", for: .normal)
            
        } else {
            self.thirdView.isHidden = true
        }
        
        self.rankingTV.reloadData()
        hideLoadingView()
    }
    
    func loadCountryFlag(_ countryName: String, flagView: UIImageView) {
        for countryObj in Global.countryObjs {
            if countryObj.name == countryName {
                if let country = CountryManager.shared.country(withDigitCode: countryObj.countryCode) {
                    flagView.isHidden = false
                    flagView.image = country.flag
                    
                    return
                }
            }
        }
        
        flagView.isHidden = true
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

    @IBAction func onClickFirstFollowBtn(_ sender: Any) {
        if self.firstUserObj != nil {
            let followed = Global.followUser(self.firstUserObj!.id)
            self.firstFollowBtn.setTitle(followed ? "UnFollow" : "Follow", for: .normal)
        }
    }
    @IBAction func onClickFirstProfileBtn(_ sender: Any) {
        if self.firstUserObj != nil {
            self.showUserProfileView(self.firstUserObj!.id)
        }
    }
    
    @IBAction func onClickSecondFollowBtn(_ sender: Any) {
        if self.secondUserObj != nil {
            let followed = Global.followUser(self.secondUserObj!.id)
            self.secondFollowBtn.setTitle(followed ? "UnFollow" : "Follow", for: .normal)
        }
    }
    @IBAction func onClickSecondProfileBtn(_ sender: Any) {
        if self.secondUserObj != nil {
            self.showUserProfileView(self.secondUserObj!.id)
        }
    }
    
    @IBAction func onClickThirdFollowBtn(_ sender: Any) {
        if self.thirdUserObj != nil {
            let followed = Global.followUser(self.thirdUserObj!.id)
            self.thirdFollowBtn.setTitle(followed ? "UnFollow" : "Follow", for: .normal)
        }
    }
    @IBAction func onClickThirdProfileBtn(_ sender: Any) {
        if self.thirdUserObj != nil {
            self.showUserProfileView(self.thirdUserObj!.id)
        }
    }
    
}

extension RankingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingTableViewCell", for: indexPath as IndexPath) as! RankingTableViewCell
        
        cell.delegate = self
        cell.cellIndex = indexPath.row
        
        let userObj = self.rankList[indexPath.row]
        cell.rankingLbl.text = "Rank #\(indexPath.row+4)"
        cell.nameLbl.text = userObj.name
        cell.profileImg.sd_setImage(with: URL(string: userObj.avatar), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], completed: nil)
        self.loadCountryFlag(userObj.country, flagView: cell.flagImg)
        
        let followed = Global.alreadyFollowed(userObj.id)
        cell.followBtn.setTitle(followed ? "UnFollow" : "Follow", for: .normal)
        cell.countLbl.text = "\(userObj.likes.count)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

extension RankingViewController: RankingTableViewCellDelegate {
    func clickedFollowBtn(_ cellIndex: Int) {
        let uObj = self.rankList[cellIndex]
        
        _ = Global.followUser(uObj.id)
    }
    
    func clickedProfileBtn(_ cellIndex: Int) {
        let uObj = self.rankList[cellIndex]
        
        self.showUserProfileView(uObj.id)
    }
}
