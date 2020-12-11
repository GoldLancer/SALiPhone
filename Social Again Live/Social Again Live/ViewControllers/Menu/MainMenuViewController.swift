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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let sideMenuVC = SideMenuManager.default.leftMenuNavigationController!.viewControllers.first as? SideMenuViewController {
            sideMenuVC.delegate = self
        }
        
        searchView.setCornerRadius()
        
        // Init Category CollectionView
        let bundle = Bundle(for: type(of: self))
        let categoryCellNib = UINib(nibName: "CategoryCollectionViewCell", bundle: bundle)
        self.categoryTV.tag = CATEGORY_VIEW_TAG
        self.categoryTV.register(categoryCellNib, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        self.categoryTV.delegate = self
        self.categoryTV.dataSource = self
        
        // Init Pulse CollectionView
        let pulseCellNib = UINib(nibName: "PulseCollectionViewCell", bundle: bundle)
        self.pulseTV.tag = PULSE_VIEW_TAG
        self.pulseTV.register(pulseCellNib, forCellWithReuseIdentifier: "PulseCollectionViewCell")
        self.pulseTV.delegate = self
        self.pulseTV.dataSource = self
        
        self.coinLbl.text = "\(Global.mCurrentUser!.coin)"
        
        addFirebaseObserve()
        
        showDashboardView()
        startPulseTimer()
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
    
    func addFirebaseObserve() {
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
            
            self.loadAvailableContents()
        }
        streamRef.observe(.value) { (snapshot) in
            
        }
    }
    
    func loadAvailableContents() {
        Global.followPostObjs.removeAll()
        Global.myPostObjs.removeAll()
        Global.pulsePostObjs.removeAll()

        for pObj in Global.allPostObjs {
//            if (isAvaiableFeed(pObj.ownerId)) {
//                GlobalManager.followPostObjs.add(pObj);
//            }
            if pObj.canShared {
                Global.pulsePostObjs.append(pObj);
            }
//            if (pObj.ownerId.equals(GlobalManager.mUserObj.id)) {
//                GlobalManager.myPostObjs.add(pObj);
//            }
        }

//        Collections.sort(GlobalManager.followPostObjs, PostObj.IDComparator);
//        Collections.sort(GlobalManager.myPostObjs, PostObj.IDComparator);
//
//        this.reloadPostObjs();
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onClickNotificationBtn(_ sender: Any) {
    }
    
    @IBAction func onClickMonthPotBtn(_ sender: Any) {
    }
    
    @IBAction func onClickNewsFeedBtn(_ sender: Any) {
        showNewsFeedView()
    }
}

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

extension MainMenuViewController: CategoryCollectionViewCellDelegate {
    func onSelectCategory(_ index: Int) {
        self.selectedCategoryIndex = index
        self.categoryTV.reloadData()
    }
}

extension MainMenuViewController: PulseCollectionViewCellDelegate {
    func onClickFeed(_ feedObj: FeedObject) {
        
    }
    
    func onClickFeedOwner(_ feedObj: FeedObject) {
        
    }
}

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
