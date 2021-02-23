//
//  NewPostViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 25.01.2021.
//

import UIKit
import YoutubePlayer_in_WKWebView
import Firebase

protocol NewPostViewControllerDelegate {
    func deletedMoment()
    func updatedMomentInfo()
}

class NewPostViewController: BaseViewController {

    @IBOutlet weak var dialogTitleTxt: UILabel!
    @IBOutlet weak var chooseView: UIView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var dialogHeightLayout: NSLayoutConstraint!
    
    @IBOutlet weak var thumbImg: UIImageView!
    @IBOutlet weak var videoLogoImg: UIImageView!
    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var youtubeUrlTxt: RoundTextField!
    @IBOutlet weak var titleTxt: RoundTextField!
    @IBOutlet weak var detailTxt: UITextView!
    @IBOutlet weak var titleTopLayout: NSLayoutConstraint!
    @IBOutlet weak var ownUrlTxt: RoundTextField!
    @IBOutlet weak var postBtnTopLayout: NSLayoutConstraint!
    
    var mediaType: PostType = .IMAGE
    var mPostObj: FeedObject? = nil
    var forEditing = false
    var changedPhoto = false
    
    var delegate: NewPostViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.youtubeUrlTxt.delegate = self
        self.detailTxt.layer.borderWidth = 0.5
        self.detailTxt.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        self.detailTxt.layer.cornerRadius = 8.0
        
        if self.mPostObj == nil {
            self.forEditing = false
            self.dialogTitleTxt.text = "Add a Moment"
            
            self.postBtnTopLayout.constant = 30.0
            self.dialogHeightLayout.constant = 350.0
            self.chooseView.isHidden = false
            self.confirmView.isHidden = true
        } else {
            self.forEditing = true
            
            self.dialogTitleTxt.text = "Edit This Moment"
            if self.mPostObj!.type == .IMAGE {
                configurePhotoConfirmView()
                self.thumbImg.sd_setImage(with: URL(string: self.mPostObj!.postUrl), completed: nil)
            } else {
                configureYTConfirmView()
                self.thumbImg.sd_setImage(with: URL(string: self.mPostObj!.thumbUrl), completed: nil)
                self.youtubeUrlTxt.text = self.mPostObj!.postUrl
                self.ownUrlTxt.text = self.mPostObj!.ownerUrl
            }
            
            self.titleTxt.text = self.mPostObj!.title
            self.detailTxt.text = self.mPostObj!.descriptions
        }
        self.deleteBtn.isHidden = !self.forEditing
    }
    
    func configurePhotoConfirmView() {
        self.mediaType = .IMAGE
        
        self.titleTopLayout.constant = 28.0
        self.dialogHeightLayout.constant = 460.0
        self.postBtnTopLayout.constant = 30.0
        
        self.confirmView.isHidden = false
        self.videoLogoImg.isHidden = true
        self.ownUrlTxt.isHidden = true
        
        self.addPhotoBtn.isHidden = !self.forEditing
    }
    
    func configureYTConfirmView() {
        self.mediaType = .VIDEOURL
        
        self.titleTopLayout.constant = 78.0
        self.postBtnTopLayout.constant = 80.0
        self.dialogHeightLayout.constant = 580.0
        
        self.confirmView.isHidden = false
        self.videoLogoImg.isHidden = false
        self.ownUrlTxt.isHidden = false
        
        self.addPhotoBtn.isHidden = true
    }
    
    override func processSelectedPhoto(_ selectedImage: UIImage) {
        configurePhotoConfirmView()
        self.thumbImg.image = selectedImage
        
        self.changedPhoto = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func uploadPostWithPhoto() {
        
        guard let pImg = self.thumbImg.image else {
            return
        }
        
        if self.mPostObj == nil {
            self.mPostObj = FeedObject()
            self.mPostObj!.postId = Global.getCurrentTimeintervalString()
            self.mPostObj!.ownerId = Global.mCurrentUser!.id
        }
        
        self.mPostObj!.title = self.titleTxt.text!
        self.mPostObj!.descriptions = self.detailTxt.text!
        self.mPostObj!.type = .IMAGE
        
        if self.forEditing && !changedPhoto {
            Global.registerNewPost(self.mPostObj!)
            finishUploadPhoto()
            return
        }
        
        showLoadingView("Uploading...")
        let imgData = pImg.jpegData(compressionQuality: 0.5)
        
        // Create a reference to the file you want to upload
        let imgPath = Global.getPictureStorageRefUrl(self.mPostObj!.postId)
        let imgRef = Storage.storage().reference().child(STORAGE_IMAGE_NAME).child(imgPath)

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
                self.mPostObj!.postUrl = pictureUrl
                
                Global.registerNewPost(self.mPostObj!)
                self.finishUploadPhoto()
            }
        }
    }
    
    func uploadPostWithYTVideo(_ ytUrl: String, thumbUrl: String) {
        
        if self.mPostObj == nil {
            self.mPostObj = FeedObject()
            self.mPostObj!.postId = Global.getCurrentTimeintervalString()
            self.mPostObj!.ownerId = Global.mCurrentUser!.id
        }
        self.mPostObj!.title = self.titleTxt.text!
        self.mPostObj!.descriptions = self.detailTxt.text!
        self.mPostObj!.type = .VIDEOURL
        self.mPostObj!.postUrl = ytUrl
        self.mPostObj!.thumbUrl = thumbUrl
        self.mPostObj!.ownerUrl = self.ownUrlTxt.text!
        
        Global.registerNewPost(self.mPostObj!)
        finishUploadPhoto()
    }
    
    func finishUploadPhoto(_ deleted:Bool = false) {
        self.hideLoadingView()
        
        self.dismiss(animated: true) {
            if deleted {
                self.delegate?.deletedMoment()
            } else {
                self.delegate?.updatedMomentInfo()
            }
        }
    }
    
    func deletePost() {
        showLoadingView("Deleting...");
        
        Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.POSTS).child(mPostObj!.postId).removeValue()
        Global.postRef.child(mPostObj!.postId).removeValue()
        
        if self.mPostObj!.type == .IMAGE {
            let filePath = Global.getPictureStorageRefUrl(self.mPostObj!.postId)
            let storageRef = Storage.storage().reference().child(STORAGE_IMAGE_NAME)
            storageRef.child(filePath).delete { (error) in
                if let err = error {
                    print("Post File did not delete because \(err.localizedDescription)")
                } else {
                    print("Post File has been deleted")
                }
                
                self.finishUploadPhoto(true)
            }
        }
    }
    
    @IBAction func onClickEditPhotoBtn(_ sender: Any) {
        self.openPhotoActivity()
    }
    
    @IBAction func onClickPostBtn(_ sender: Any) {
        if self.mediaType == .IMAGE {
            uploadPostWithPhoto()
        } else {
            let ytUrl = self.youtubeUrlTxt.text!
            if let ytId = ytUrl.youtubeID {
                if !ytId.isEmpty {
                    uploadPostWithYTVideo(ytUrl, thumbUrl: ytId.youtubeThumbUrl!)
                }
            }
            
            self.showAlertWithText(errorText: "The Youtube Url is a invalid.")
        }
    }
    
    @IBAction func onClickAddYoutubeUrl(_ sender: Any) {
        configureYTConfirmView()
    }
    
    @IBAction func onClickTakePhotoFromCamera(_ sender: Any) {
        self.openCamera()
    }
    
    @IBAction func onClickChoosePhotoFromGallery(_ sender: Any) {
        self.openGallary()
    }
    
    @IBAction func onClickCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickDeleteMoment(_ sender: Any) {
        let alertViewController = UIAlertController(title: "", message: "Are you sure to Delete this moment now?", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
            if self.mPostObj != nil {
                self.deletePost()
            }
        })
        let cancel = UIAlertAction(title: "No", style: .cancel) { (alert) in
            
        }
        alertViewController.addAction(camera)
        alertViewController.addAction(cancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
}

extension NewPostViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if let ytId = textField.text?.youtubeID {
            self.thumbImg.sd_setImage(with: URL(string: ytId.youtubeThumbUrl!), completed: nil)
        }
        
        return true
    }
}


