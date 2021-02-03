//
//  AllStreamViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 11.12.2020.
//

import UIKit

protocol AllStreamViewControllerDelegate {
    func selectUserProfile(_ userId: String)
}

class AllStreamViewController: BaseContainerViewController {

    @IBOutlet weak var streamTV: UICollectionView!
    
    let collectionViewHorizontalSpacing: CGFloat = 30.0
    let collectionViewVerticalSpacing: CGFloat = 30.0
    var delegate: AllStreamViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Init Stream CollectionView
        let bundle = Bundle(for: type(of: self))
        let streamCellNib = UINib(nibName: "StreamCollectionViewCell", bundle: bundle)
        self.streamTV.register(streamCellNib, forCellWithReuseIdentifier: "StreamCollectionViewCell")
        self.streamTV.delegate = self
        self.streamTV.dataSource = self
        
        // MARK: Add Notification
        NotificationCenter.default.addObserver(self, selector: #selector(didReloadLiveStreams), name: .didReloadAllSteams, object:nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didReloadLiveStreams() {
        self.streamTV.reloadData()
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
extension AllStreamViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Global.filterStreamObjs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StreamCollectionViewCell", for: indexPath) as! StreamCollectionViewCell
        cell.delegate = self
        cell.streamIndex = indexPath.row
        
        let streamObj = Global.filterStreamObjs[indexPath.row]
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
        print("Live Streaming : \(streamObj.owner.id), \(streamObj.streamId)")
        return cell
    }
}

extension AllStreamViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (self.view.bounds.width - collectionViewHorizontalSpacing - 25 * 2) / 2
        var height = width + 30
        
        if Global.filterStreamObjs.count % 2 == 0 {
            if indexPath.row == Global.filterStreamObjs.count-2 {
                height = width + 70
            }
        }
        
        if indexPath.row == Global.filterStreamObjs.count-1 {
            height = width + 70
        }
        
        return CGSize(width: width, height: height)
    }
}

// MARK: CollectionViewCell Delegation
extension AllStreamViewController: StreamCollectionViewCellDelegate {
    func onClickedOwnerProfile(_ index: Int) {
        let streamObj = Global.filterStreamObjs[index]
        self.delegate?.selectUserProfile(streamObj.owner.id)
    }
    
    func selectedStreaming(_ index: Int) {
        let streamObj = Global.filterStreamObjs[index]
        
        self.showLiveSteamView(streamObj)
    }
}
