//
//  ProfileViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 11.12.2020.
//

import UIKit
import Firebase
import SDWebImage
import SKCountryPicker

enum PhotoType {
    case NONE
    case PROFILE
    case COVER
}

protocol ProfileViewControllerDelegate {
    func onClickedEditProfileBtn()
}

class ProfileViewController: BaseViewController {
    
    var delegate: ProfileViewControllerDelegate?

    @IBOutlet weak var ivProfile: ProfileGreenImageView!
    @IBOutlet weak var ivCover: UIImageView!
    @IBOutlet weak var lblHeart: UILabel!
    @IBOutlet weak var btnCountry: RoundButton!
    @IBOutlet weak var btnGender: RoundButton!
    @IBOutlet weak var lblLevel01: UILabel!
    @IBOutlet weak var lblLevel02: UILabel!
    @IBOutlet weak var lblLevel03: UILabel!
    @IBOutlet weak var lblLevel04: UILabel!
    @IBOutlet weak var ivLevelIndicator: UIImageView!
    @IBOutlet weak var btnCoins: RoundButton!
    @IBOutlet weak var btnFollowers: RoundButton!
    @IBOutlet weak var btnFollowings: RoundButton!
    @IBOutlet weak var feedCV: UICollectionView!
    @IBOutlet weak var lblNothing: UILabel!
    @IBOutlet weak var cvHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var clickableImg: UIImageView!
    @IBOutlet weak var clickableHeightConstraint: NSLayoutConstraint!
    
    private var cvCellWidth: CGFloat = 80.0
    private var photoType: PhotoType = .NONE
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clickableHeightConstraint.constant = 0
        setUserValues()
        
        cvCellWidth = (self.view.bounds.width - 30 - 25 * 2) / 2
        
        // Init My Posts Collection
        let bundle = Bundle(for: type(of: self))
        let feedCellNib = UINib(nibName: "MyFeedCollectionViewCell", bundle: bundle)
        self.feedCV.register(feedCellNib, forCellWithReuseIdentifier: "MyFeedCollectionViewCell")
        self.feedCV.delegate = self
        self.feedCV.dataSource = self
        
        // MARK: Add Notification
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMyPosts), name: .didReloadAllFeeds, object:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let country = Global.mCurrentUser!.country.isEmpty ? "Country" : Global.mCurrentUser!.country
        let gender = Global.mCurrentUser!.gender.isEmpty ? "Gender" : Global.mCurrentUser!.gender
        btnCountry.setTitle(country, for: .normal)
        btnGender.setTitle(gender, for: .normal)
        
        if Global.mCurrentUser!.clickableImgURL.isEmpty {
            self.clickableHeightConstraint.constant = 0
            self.clickableImg.isHidden = true
        } else {
            self.clickableHeightConstraint.constant = 220
            self.clickableImg.isHidden = false
            self.clickableImg.sd_setImage(with: URL(string: Global.mCurrentUser!.clickableImgURL), completed: nil)
        }
    }
    
    override func processSelectedPhoto(_ selectedImage: UIImage) {
        if self.photoType == .PROFILE {
            self.ivProfile.image = selectedImage
        } else if self.photoType == .COVER {
            self.ivCover.image = selectedImage
        } else {
            return
        }
        
        showLoadingView("Uploading...")
        let imgData = selectedImage.jpegData(compressionQuality: 0.5)
        
        // Create a reference to the file you want to upload
        var imgName = ""
        if self.photoType == .PROFILE {
            imgName = "\(Global.mCurrentUser!.id).jpg"
        } else {
            imgName = "\(Global.mCurrentUser!.id)_cover.jpg"
        }
        let imgRef = Storage.storage().reference().child(STORAGE_IMAGE_NAME).child(imgName)

        // Upload the file to the path "images/rivers.jpg"
        _ = imgRef.putData(imgData!, metadata: nil) { (metadata, error) in
            if error != nil {
                print("Uploading Failed: \(error!.localizedDescription)")
                self.finishUploadPhoto()
                return
            }
            
            // You can also access to download URL after upload.
            imgRef.downloadURL { (url, error) in
                  guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    self.finishUploadPhoto()
                    return
                }
                
                let pictureUrl = downloadURL.absoluteString
                
                if self.photoType == .PROFILE {
                    Global.mCurrentUser!.avatar = pictureUrl
                    Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.AVATAR).setValue(pictureUrl)
                    NotificationCenter.default.post(name: .didReloadUserInfo, object: nil)
                } else {
                    Global.mCurrentUser!.cover = pictureUrl
                    Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.COVER).setValue(pictureUrl)
                }
                
                self.finishUploadPhoto()
            }
        }
    }
    
    func finishUploadPhoto() {
        hideLoadingView()
        
        self.photoType = .NONE
    }
    
    func setUserValues() {
        if Global.mCurrentUser!.avatar.isEmpty {
            self.ivProfile.image = PROFILE_DEFAULT_GREEN_AVATAR
        } else {
            self.ivProfile.sd_setImage(with: URL(string: Global.mCurrentUser!.avatar), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], completed: nil)
        }
        
        if !Global.mCurrentUser!.cover.isEmpty {
            self.ivCover.sd_setImage(with: URL(string: Global.mCurrentUser!.cover))
        }
        
        updateUserInfo()
        
        let country = Global.mCurrentUser!.country.isEmpty ? "Country" : Global.mCurrentUser!.country
        let gender = Global.mCurrentUser!.gender.isEmpty ? "Gender" : Global.mCurrentUser!.gender
        btnCountry.setTitle(country, for: .normal)
        btnGender.setTitle(gender, for: .normal)
    }
    
    func updateUserInfo() {
        lblHeart.text = "\(Global.likeCount)"
        btnCoins.setTitle("\(Global.mCurrentUser!.coin)", for: .normal)
        btnFollowers.setTitle("\(Global.followerObjs.count)", for: .normal)
        btnFollowings.setTitle("\(Global.followingObjs.count)", for: .normal)
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
    
    func showFollowView(_ isFollower: Bool) {
        let storyboard = UIStoryboard(name: "Follow", bundle: nil)
        if let followView = storyboard.instantiateViewController(withIdentifier: "FollowView") as? FollowViewController {
            
            followView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            followView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            followView.isFollower = isFollower
            
            self.present(followView, animated: true, completion: nil)
        }
    }
    
    @objc func reloadMyPosts() {
        updateUserInfo()
        
        if (Global.myPostObjs.count > 0) {
            self.lblNothing.isHidden = true
            self.cvHeightLayoutConstraint.constant = CGFloat(Int((Global.myPostObjs.count + 1) / 2)) * cvCellWidth
        } else {
            self.lblNothing.isHidden = false
        }
        self.feedCV.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onClickAddCoverBtn(_ sender: Any) {
        self.photoType = .COVER
        self.openPhotoActivity()
    }
    
    @IBAction func onClickAddProfile(_ sender: Any) {
        self.photoType = .PROFILE
        self.openPhotoActivity()
    }
    
    @IBAction func onClickHeartBtn(_ sender: Any) {
    }
    
    @IBAction func onClickEditProfileBtn(_ sender: Any) {
        self.delegate?.onClickedEditProfileBtn()
    }
    
    @IBAction func onClickShareBtn(_ sender: Any) {
    }
    
    @IBAction func onClickUpgradeBtn(_ sender: Any) {
        self.showUpgradeView()
    }
    
    @IBAction func onClickCountryBtn(_ sender: Any) {
        _ = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
            guard let self = self else { return }

            self.btnCountry.setTitle(country.countryName, for: .normal)
            
            Global.mCurrentUser!.country = country.countryName
            Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.COUNTRY).setValue(country.countryName)
            Global.videoRef.child(Global.mCurrentUser!.streamID).child(StreamConstant.OWNER).setValue(Global.mCurrentUser!.getBaseJsonvalue())
            
            let countryObj = CountryObject()
            countryObj.name = country.countryName
            countryObj.countryCode = country.digitCountrycode!
            countryObj.uploadObjectToFirebase()
        }
    }
    
    @IBAction func onClickGenderBtn(_ sender: Any) {
        showGenderDialog()
    }
    
    @IBAction func onClickRedeemBtn(_ sender: Any) {
    }
    
    @IBAction func onClickDetailRedeemBtn(_ sender: Any) {
    }
    
    @IBAction func onClickFollowersBtn(_ sender: Any) {
        showFollowView(true)
    }
    
    @IBAction func onClickFollowingsBtn(_ sender: Any) {
        showFollowView(false)
    }
    
}

// MARK: CollectionView Delegations
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Global.myPostObjs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyFeedCollectionViewCell", for: indexPath) as! MyFeedCollectionViewCell
        cell.postIndex = indexPath.row
        cell.delegate = self
        
        let feedObj = Global.myPostObjs[indexPath.row]
        if feedObj.type == .IMAGE {
            cell.videoView.isHidden = true
            if feedObj.postUrl.isEmpty {
                cell.thumbImg.image = UIImage()
            } else {
                cell.thumbImg.sd_setImage(with: URL(string: feedObj.postUrl), completed: nil)
            }
        } else {
            cell.videoView.isHidden = false
            if feedObj.thumbUrl.isEmpty {
                cell.thumbImg.image = UIImage()
            } else {
                cell.thumbImg.sd_setImage(with: URL(string: feedObj.thumbUrl), completed: nil)
            }
        }
        
        return cell
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cvCellWidth, height: cvCellWidth)
    }
}

extension ProfileViewController: GenderViewControllerDelegate {
    func selectGender(_ isFemale: Bool) {
        let genderStr = isFemale ? "Female" : "Male"
        self.btnGender.setTitle(genderStr, for: .normal)
        
        Global.mCurrentUser!.gender = genderStr
        Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.GENDER).setValue(genderStr)
        Global.videoRef.child(Global.mCurrentUser!.streamID).child(StreamConstant.OWNER).setValue(Global.mCurrentUser!.getBaseJsonvalue())
    }
}

extension ProfileViewController: MyFeedCollectionViewCellDelegate {
    func selectedFeedForDetail(_ index: Int) {
        let pObj = Global.myPostObjs[index]
        
        if pObj.type == .IMAGE {
            self.showPostImageView(pObj)
        } else {
            self.showPostVideoView(pObj)
        }
    }
    
    func selectedFeedForShare(_ index: Int) {
        let pObj = Global.myPostObjs[index]
    }
}
