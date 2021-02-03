//
//  MyStreamViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 11.12.2020.
//

import UIKit

protocol MyStreamViewControllerDelegate {
    
}

class MyStreamViewController: BaseViewController {
    
    @IBOutlet weak var profileImg: ProfileGreenImageView!
    @IBOutlet weak var streamCV: UICollectionView!
    
    var delegate: MyStreamViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Init Stream CollectionView
        let bundle = Bundle(for: type(of: self))
        let streamCellNib = UINib(nibName: "StreamCollectionViewCell", bundle: bundle)
        self.streamCV.register(streamCellNib, forCellWithReuseIdentifier: "StreamCollectionViewCell")
        self.streamCV.delegate = self
        self.streamCV.dataSource = self
        
        let avatar = Global.mCurrentUser!.avatar
        if !avatar.isEmpty {
            self.profileImg.sd_setImage(with: URL(string: avatar), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], completed: nil)
        } else {
            self.profileImg.image = PROFILE_DEFAULT_GREEN_AVATAR
        }
        
        // MARK: Add Notification
        NotificationCenter.default.addObserver(self, selector: #selector(didReloadMyStreamers), name: .didReloadMyStreamers, object:nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didReloadMyStreamers() {
        self.streamCV.reloadData()
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
extension MyStreamViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Global.mySteamersObjs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StreamCollectionViewCell", for: indexPath) as! StreamCollectionViewCell
        cell.delegate = self
        cell.streamIndex = indexPath.row
        
        let streamObj = Global.mySteamersObjs[indexPath.row]
        if streamObj.videoThumbnail.isEmpty {
            cell.thumbImg.image = UIImage()
        } else {
            cell.thumbImg.sd_setImage(with: URL(string: streamObj.videoThumbnail), completed: nil)
        }
        Global.getProfileUrlByID(streamObj.owner.id) { (url) in
            if url.isEmpty {
                cell.profileImg.image = PROFILE_DEFAULT_GREEN_AVATAR
            } else {
                cell.profileImg.sd_setImage(with: URL(string: url), completed: nil)
            }
        }
        if streamObj.videoTitle.isEmpty {
            cell.profileLbl.text = streamObj.owner.name
//            Global.getProfileNameByID(streamObj.owner.id) { (name) in
//                cell.profileLbl.text = name
//            }
        } else {
            cell.profileLbl.text = streamObj.videoTitle
        }
        
        return cell
    }
}

extension MyStreamViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (self.view.bounds.width - 30 - 25 * 2) / 2
        var height = width + 30
        
        if Global.mySteamersObjs.count % 2 == 0 {
            if indexPath.row == Global.mySteamersObjs.count-2 {
                height = width + 70
            }
        }
        
        if indexPath.row == Global.mySteamersObjs.count-1 {
            height = width + 70
        }
        
        return CGSize(width: width, height: height)
    }
}

// MARK: CollectionViewCell Delegation
extension MyStreamViewController: StreamCollectionViewCellDelegate {
    func onClickedOwnerProfile(_ index: Int) {
        let streamObj = Global.mySteamersObjs[index]
        self.showUserProfileView(streamObj.owner.id)
    }
    
    func selectedStreaming(_ index: Int) {
        let streamObj = Global.filterStreamObjs[index]
        
        self.showLiveSteamView(streamObj)
    }
}
