//
//  MainMenuViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import Firebase
import SideMenu
import SDWebImage

class MainMenuViewController: BaseNavViewController{

    @IBOutlet weak var categoryTV: UICollectionView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var pulseTV: UICollectionView!
    @IBOutlet weak var pulseSectionHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var filterSectionHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var newsFeedBtn: RoundButton!
    @IBOutlet weak var coinLbl: UILabel!
    @IBOutlet weak var notiBtn: UIButton!
    @IBOutlet weak var filterLbl: UILabel!
    
    @IBOutlet weak var filterSection: UIView!
    @IBOutlet weak var pulseSection: UIView!
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var myStreamerContainer: UIView!
    @IBOutlet weak var feedContainer: UIView!
    @IBOutlet weak var streamContainer: UIView!
    
    let CATEGORY_VIEW_TAG               = 101
    let PULSE_VIEW_TAG                  = 102
    let FEED_VIEW_TAG                   = 103
    let CATEGORY_CELL_HEIGHT: CGFloat   = 40.0
    
    var selectedCategoryIndex: Int      = -1
    var mPulseObjs: [FeedObject]        = []
    
    var pulseTimer: Timer?              = nil
    var pulseIndex: Int                 = 0
    
    let feedRef = Database.database().reference().child(POST_DB_NAME)
    let userRef = Database.database().reference().child(USER_DB_NAME)
    let streamRef = Database.database().reference().child(VIDEO_DB_NAME)
    let countryRef = Database.database().reference().child(COUNTRY_DB_NAME)
    let monthlyRef = Database.database().reference().child(MONTHLY_POT_DB_NAME)
    
    var nameKey: String     = ""
    var countryKey: String  = ""
    var genderKey: String   = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let sideMenuVC = SideMenuManager.default.leftMenuNavigationController!.viewControllers.first as? SideMenuViewController {
            sideMenuVC.delegate = self
        }
        
        searchView.setCornerRadius()
        
        // MARK: Init Category CollectionView
        let bundle = Bundle(for: type(of: self))
        let categoryCellNib = UINib(nibName: "CategoryCollectionViewCell", bundle: bundle)
        self.categoryTV.tag = CATEGORY_VIEW_TAG
        self.categoryTV.register(categoryCellNib, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        self.categoryTV.delegate = self
        self.categoryTV.dataSource = self
        
        // MARK: Init Pulse CollectionView
        let pulseCellNib = UINib(nibName: "PulseCollectionViewCell", bundle: bundle)
        self.pulseTV.tag = PULSE_VIEW_TAG
        self.pulseTV.register(pulseCellNib, forCellWithReuseIdentifier: "PulseCollectionViewCell")
        self.pulseTV.delegate = self
        self.pulseTV.dataSource = self
        
        self.coinLbl.text = "\(Global.mCurrentUser!.coin)"
        
        addFirebaseObserves()
        
        showDashboardView()
        startPulseTimer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        removeFirebaseObserves()
    }
    
    func initContainerViews() {
        
    }
    
    func hideAllContainerView() {
        self.profileContainer.isHidden = true
        self.myStreamerContainer.isHidden = true
        self.streamContainer.isHidden = true
        self.feedContainer.isHidden = true
        
        self.filterSection.isHidden = false
        self.pulseSection.isHidden = false
        self.filterSectionHeightLayout.constant = 110.0
        self.pulseSectionHeightLayout.constant = 180.0
        
        self.newsFeedBtn.isHidden = false
    }
    
    func showProfileView() {
        hideAllContainerView()
        
        self.filterSection.isHidden = true
        self.filterSectionHeightLayout.constant = 0.0
        self.profileContainer.isHidden = false
    }
    
    func showDashboardView() {
        hideAllContainerView()
        
        self.streamContainer.isHidden = false
    }
    
    func showNewsFeedView() {
        hideAllContainerView()
        
        self.filterSection.isHidden = true
        self.filterSectionHeightLayout.constant = 0.0
        self.newsFeedBtn.isHidden = true
        self.feedContainer.isHidden = false
    }
    
    func showMyStreamerView() {
        hideAllContainerView()
        
        self.filterSectionHeightLayout.constant = 0.0
        self.pulseSectionHeightLayout.constant = 0.0
        self.filterSection.isHidden = true
        self.pulseSection.isHidden = true
        self.myStreamerContainer.isHidden = false
    }
    
    // MARK: ADD Firebase Observers
    func addFirebaseObserves() {
        // Firebase Observe For All Feeds
        feedRef.observe(.value) { (snapshot) in
            Global.allPostObjs.removeAll()
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let data = snap.value as? NSDictionary {
                    let postObj = FeedObject()
                    postObj.initUserWithJsonresponse(value: data)
                    
                    Global.allPostObjs.append(postObj)
                }
            }
            
            self.loadAvailableFeeds()
        }
        
        // Firebase Observe For All Live Streamings
        streamRef.observe(.value) { (snapshot) in
            Global.allStreamObj.removeAll()
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let data = snap.value as? NSDictionary {
                    let streamObj = StreamObject()
                    streamObj.initUserWithJsonresponse(value: data)
                    
                    Global.allStreamObj.append(streamObj)
                }
            }
            Global.allStreamObj.sort(by: { $0.created > $1.created })
            
            self.loadAvailableStreams()
        }
        
        // Firebase Observe For All Countries
        countryRef.observe(.value) { (snapshot) in
            Global.countries.removeAll()
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let data = snap.value as? NSDictionary {
                    let countryName = data["name"] as? String ?? ""
                    
                    Global.countries.append(countryName)
                }
            }
        }
        
        // Firebase Observe For Monthly Pot
        monthlyRef.observe(.value) { (snapshot) in
            if let pot = snapshot.value as? Int {
                Global.monthlyPot = pot
            }
        }
        
        // Firebase Observe For Likes Me
        userRef.child(Global.mCurrentUser!.id).child(UserConstant.LIKES).observe(.value) { (snapshot) in
            if snapshot.exists() {
                Global.likeCount = Int(snapshot.childrenCount)
            } else {
                Global.likeCount = 0
            }
        }
        
        // Firebase Observe For Following Users
        userRef.child(Global.mCurrentUser!.id).child(UserConstant.FOLLOWINGS).observe(.value) { (snapshot) in
            Global.mCurrentUser!.followings.removeAll()
            Global.followingObjs.removeAll()
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let data = snap.value as? NSDictionary {
                    let uObj = BaseUserObject()
                    uObj.initUserWithJsonresponse(value: data)
                    
                    Global.mCurrentUser!.followings.append(uObj)
                    Global.followingObjs.append(uObj)
                }
            }
            
            NotificationCenter.default.post(name: .didReloadFollowings, object: nil)
        }
        
        // Firebase Observe For Following Users
        userRef.child(Global.mCurrentUser!.id).child(UserConstant.FOLLOWERS).observe(.value) { (snapshot) in
            Global.mCurrentUser!.followers.removeAll()
            Global.followerObjs.removeAll()
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let data = snap.value as? NSDictionary {
                    let uObj = BaseUserObject()
                    uObj.initUserWithJsonresponse(value: data)
                    
                    Global.mCurrentUser!.followers.append(uObj)
                    Global.followerObjs.append(uObj)
                }
            }
            
            self.reloadMyStreamers()
            NotificationCenter.default.post(name: .didReloadFollowers, object: nil)
        }
    }
    
    func removeFirebaseObserves() {
        feedRef.removeAllObservers()
        streamRef.removeAllObservers()
        countryRef.removeAllObservers()
        monthlyRef.removeAllObservers()
        
        userRef.child(Global.mCurrentUser!.id).child(UserConstant.LIKES).removeAllObservers()
        userRef.child(Global.mCurrentUser!.id).child(UserConstant.FOLLOWINGS).removeAllObservers()
        userRef.child(Global.mCurrentUser!.id).child(UserConstant.FOLLOWERS).removeAllObservers()
    }
    
    func loadAvailableStreams() {
        
        var filterStr = self.nameKey
        filterStr = filterStr.isEmpty ? self.countryKey : "\(filterStr)\(self.countryKey.isEmpty ? "" : ", \(self.countryKey)")"
        filterStr = filterStr.isEmpty ? self.genderKey : "\(filterStr)\(self.genderKey.isEmpty ? "" : ", \(self.genderKey)")"
        if filterStr.isEmpty {
            filterStr = "All"
        }
        self.filterLbl.text = filterStr

        Global.filterStreamObjs.removeAll()
        
        for sObj in Global.allStreamObj {
            if sObj.owner.id == Global.mCurrentUser?.id {
                continue
            }
            
            if !sObj.isOnline {
                continue
            }
            
            if isMatchedSearchOption(sObj) {
                if selectedCategoryIndex > 0 {
                    let category = CATEGORY_ITEMS[selectedCategoryIndex]
                    if sObj.category == category {
                        Global.filterStreamObjs.append(sObj)
                    }                    
                } else {
                    Global.filterStreamObjs.append(sObj)
                }
            }
            
        }
        
        NotificationCenter.default.post(name: .didReloadAllSteams, object: nil)
        reloadMyStreamers()
    }
    
    func reloadMyStreamers() {
        Global.mySteamersObjs.removeAll()
        
        for sObj in Global.allStreamObj {
            if sObj.owner.id == Global.mCurrentUser?.id {
                continue
            }
            
            if !sObj.isOnline {
                continue
            }
            
            if Global.alreadyFollowed(sObj.owner.id) {
                Global.mySteamersObjs.append(sObj)
            }
        }
        
        NotificationCenter.default.post(name: .didReloadMyStreamers, object: nil)
    }
    
    func isMatchedSearchOption(_ obj: StreamObject) -> Bool {

        if !self.nameKey.isEmpty {
            if obj.owner.name.lowercased().contains(self.nameKey.lowercased())
                || obj.videoTitle.lowercased().contains(self.nameKey.lowercased()) {
                return true
            }
        }
        if !self.countryKey.isEmpty {
            if obj.owner.country == self.countryKey {
                return true
            }
        }
        if !self.genderKey.isEmpty {
            if obj.owner.gender == self.genderKey {
                return true
            }
        }
        
        if self.nameKey.isEmpty && self.countryKey.isEmpty && self.genderKey.isEmpty {
            return true
        }

        return false;
    }
    
    func loadAvailableFeeds() {
        Global.followPostObjs.removeAll()
        Global.myPostObjs.removeAll()
        Global.pulsePostObjs.removeAll()

        for pObj in Global.allPostObjs {
            if isAvaiableFeed(pObj.ownerId) {
                Global.followPostObjs.append(pObj)
            }
            if pObj.canShared {
                Global.pulsePostObjs.append(pObj)
            }
            if pObj.ownerId == Global.mCurrentUser!.id {
                Global.myPostObjs.append(pObj)
            }
        }

        Global.followPostObjs.sort(by: {$0.postId > $1.postId})
        Global.myPostObjs.sort(by: {$0.postId > $1.postId})

        NotificationCenter.default.post(name: .didReloadAllFeeds, object: nil)
        reloadMyStreamers()
    }
    
    func isAvaiableFeed(_ ownerID: String) -> Bool {
        if Global.mCurrentUser!.id == ownerID {
            return true
        }
        
        for uObj in Global.followerObjs {
            if uObj.id == ownerID {
                return true
            }
        }
        
        for uObj in Global.followingObjs {
            if uObj.id == ownerID {
                return true
            }
        }
        
        return false
    }
    
    func stopPulseTimer() {
        if self.pulseTimer != nil {
            self.pulseTimer?.invalidate()
            self.pulseTimer = nil;
        }
    }
    
    func startPulseTimer() {
        if self.pulseTimer != nil {
            self.pulseTimer?.invalidate()
            self.pulseTimer = nil;
        }

        pulseTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updatePulseBar), userInfo: nil, repeats: true)
    }
    
    @objc func updatePulseBar() {
        self.mPulseObjs.removeAll()
        if Global.pulsePostObjs.count < 4 {
            for pObj in Global.pulsePostObjs {
                self.mPulseObjs.append(pObj)
            }
        } else {
            for _ in 0..<4 {
                if pulseIndex >= Global.pulsePostObjs.count {
                    pulseIndex = pulseIndex - Global.pulsePostObjs.count
                }
                
                let pObj = Global.pulsePostObjs[pulseIndex]
                self.mPulseObjs.append(pObj)
                pulseIndex += 1
            }
        }
        
        self.pulseTV.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AllStreamVCID" {
            if let allStreamVC = segue.destination as? AllStreamViewController {
                allStreamVC.delegate = self
            }
        }
        
        if segue.identifier == "NewsFeedVCID" {
            if let newFeedVC = segue.destination as? NewsFeedViewController {
                newFeedVC.delegate = self
            }
        }
        
        if segue.identifier == "MyStreamVCID" {
            if let myStreamVC = segue.destination as? MyStreamViewController {
                myStreamVC.delegate = self
            }
        }
        
        if segue.identifier == "ProfileVCID" {
            if let profileVC = segue.destination as? ProfileViewController {
                profileVC.delegate = self
            }
        }
        
        if segue.identifier == "Main2Filter" {
            if let filterVC = segue.destination as? FilterStreamViewController {
                filterVC.delegate = self
            }
        }
    }

    // MARK: - UI ACTIONS
    @IBAction func onClickFilterBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "Main2Filter", sender: nil)
    }
    
    @IBAction func onClickNotificationBtn(_ sender: Any) {
    }
    
    @IBAction func onClickMonthPotBtn(_ sender: Any) {
    }
    
    @IBAction func onClickNewsFeedBtn(_ sender: Any) {
        showNewsFeedView()
    }
}

// MARK: - CollectionView Delegation

extension MainMenuViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == CATEGORY_VIEW_TAG {
            return CATEGORY_ITEMS.count
        } else if collectionView.tag == PULSE_VIEW_TAG {
            return 4
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == CATEGORY_VIEW_TAG {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            cell.delegate = self
            
            cell.categoryIndex = indexPath.row
            let isSelected = (indexPath.row == self.selectedCategoryIndex)
            if isSelected {
                cell.roundView.backgroundColor = MAIN_YELLOW_COLOR
            } else {
                cell.roundView.backgroundColor = MAIN_WHITE_COLOR
            }
            cell.categoryLbl.text = CATEGORY_ITEMS[indexPath.row]
            
            return cell
        } else if collectionView.tag == PULSE_VIEW_TAG {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PulseCollectionViewCell", for: indexPath) as! PulseCollectionViewCell
            cell.delegate = self
            
            var pulseObj: FeedObject? = nil
            if self.mPulseObjs.count > indexPath.row {
                pulseObj = self.mPulseObjs[indexPath.row]
            } else {
                pulseObj = FeedObject()
            }
            
            cell.mFeedObj = pulseObj
            if pulseObj?.type == .VIDEOURL {
                cell.videoView.isHidden = false
                if !pulseObj!.thumbUrl.isEmpty {
                    cell.thumbImg.sd_setImage(with: URL(string: pulseObj!.thumbUrl), completed: nil)
                }
            } else {
                cell.videoView.isHidden = true
                if !pulseObj!.postUrl.isEmpty {
                    cell.thumbImg.sd_setImage(with: URL(string: pulseObj!.postUrl), completed: nil)
                }
            }
            
            if !pulseObj!.ownerId.isEmpty {
                Global.getProfileUrlByID(pulseObj!.ownerId) { (url) in
                    if url.isEmpty {
                        cell.profileImg.image = PROFILE_DEFAULT_GREEN_AVATAR
                    } else {
                        cell.profileImg.sd_setImage(with: URL(string: url), completed: nil)
                    }
                }
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension MainMenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == CATEGORY_VIEW_TAG {
            let itemName = CATEGORY_ITEMS[indexPath.row]
            let cellWidth = itemName.widthWithConstrainedHeight(CATEGORY_CELL_HEIGHT, font: UIFont(name: "Montserrat-Light", size: 16.0)!) + 30
            return CGSize(width: cellWidth, height: CATEGORY_CELL_HEIGHT)
        } else if collectionView.tag == PULSE_VIEW_TAG {
            let cellWidth = (self.view.bounds.width - 15) / 4
            let cellHeight = collectionView.bounds.height
            return CGSize(width: cellWidth, height: cellHeight)
        }
        
        return CGSize(width: 50, height: 50)
    }
}

// MARK: SideMenu Delegation
extension MainMenuViewController: SideMenuViewControllerDelegate {
    func onClickMenuItem(_ item: String) {
        print("Item Clicked : \(item)")
        switch item {
        case "header":
            showDashboardView()
            break
        case "profile":
            showProfileView()
            break
        case "chat":
            break
        case "stream":
            showMyStreamerView()
            break
        case "find":
            break
        case "transaction":
            break
        case "setting":
            break
        case "exit":
            do { try Auth.auth().signOut() }
            catch { print("already logged out") }
            
            Global.signoutWithUI()
            break
        case "heart":
            break
        case "monthpot":
            break
        case "upgrade":
            break
            
        default:
            break
        }
    }
}

// MARK: Cell Delegations
extension MainMenuViewController: CategoryCollectionViewCellDelegate {
    func onSelectCategory(_ index: Int) {
        self.selectedCategoryIndex = index
        self.categoryTV.reloadData()
        
        self.loadAvailableStreams()
    }
}

extension MainMenuViewController: PulseCollectionViewCellDelegate {
    func onClickFeed(_ feedObj: FeedObject) {
        
    }
    
    func onClickFeedOwner(_ feedObj: FeedObject) {
        
    }
}

// MARK: FilterView Delegation
extension MainMenuViewController: FilterStreamViewControllerDelegate {
    func resetFilter() {
        self.nameKey = ""
        self.countryKey = ""
        self.genderKey = ""
        self.selectedCategoryIndex = -1
        
        self.categoryTV.reloadData()
        self.loadAvailableStreams()
    }
    
    func filterByKeys(nameKey: String, countryKey: String, genderKey: String) {
        self.nameKey = nameKey
        self.countryKey = countryKey
        self.genderKey = genderKey
        
        self.loadAvailableStreams()
    }
}

// MARK: ContainerView Delegations
extension MainMenuViewController: AllStreamViewControllerDelegate {
    
}

extension MainMenuViewController: MyStreamViewControllerDelegate {
    
}

extension MainMenuViewController: NewsFeedViewControllerDelegate {
    
}

extension MainMenuViewController: ProfileViewControllerDelegate {
    
}

// MARK: Notification Extention
extension Notification.Name {
    static let didReloadAllFeeds    = Notification.Name("didReloadAllFeeds")
    static let didReloadAllSteams   = Notification.Name("didReloadAllSteams")
    static let didReloadFollowings  = Notification.Name("didReloadFollowings")
    static let didReloadFollowers   = Notification.Name("didReloadFollowers")
    static let didReloadMyStreamers   = Notification.Name("didReloadMyStreamers")
    
}

// MARK: View Extentsions
extension UIView {
    func setCornerRadius(_ radius: CGFloat = 10.0) {
        self.layer.cornerRadius = radius
    }
}

extension String {
    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)

        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }

    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat? {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}
