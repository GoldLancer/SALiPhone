//
//  VideoPageViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 23.01.2021.
//

import UIKit

class VideoPageViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    
//    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var collectionView: UICollectionView!
    var currentIndex: Int = 0
    var videos:[FeedObject] = []
//    let pagerView = FSPagerView()
    
    let playerVars:[String: Any] = [
        "controls" : "0",
        "showinfo" : "0",
        "autoplay": "0",
        "rel": "0",
        "modestbranding": "0",
        "iv_load_policy" : "3",
        "fs": "0",
        "playsinline" : "1"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for vObj in Global.followPostObjs {
            if vObj.type == .VIDEO || vObj.type == .VIDEOURL {
                videos.append(vObj)
            }
        }

        self.view.layoutIfNeeded()
//        pagerView.frame = container.bounds
//        self.container.addSubview(pagerView)
        
        let bundle = Bundle(for: type(of: self))
        let videoCellNib = UINib(nibName: "VideoPageCollectionViewCell", bundle: bundle)
        collectionView.register(videoCellNib, forCellWithReuseIdentifier: "VideoPageCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        
//        pagerView.register(videoCellNib, forCellWithReuseIdentifier: "VideoPageCollectionViewCell")
//        pagerView.dataSource = self
//        pagerView.delegate = self
//        pagerView.scrollDirection = .vertical
//        pagerView.interitemSpacing = 0
        
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
        self.dismiss(animated: true, completion: nil)
    }
}

extension VideoPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPageCollectionViewCell", for: indexPath) as! VideoPageCollectionViewCell
        
        let vObj = self.videos[indexPath.row]
        Global.getProfileNameByID(vObj.ownerId) { (name) in
            cell.profileLbl.text = name
        }
        Global.getProfileUrlByID(vObj.ownerId) { (url) in
            cell.profileImg.sd_setImage(with: URL(string: url), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], context: nil)
        }
        
//        if indexPath.row == self.currentIndex {
//            cell.canStart = true
//        } else {
//            cell.canStart = false
//        }
        
        if let videoId = vObj.postUrl.youtubeID {
            cell.loadVideo(videoId)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("Did EndDisplaying Index = \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("Will Displaying Index = \(indexPath.row)")
        
    }
}

extension VideoPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        self.view.layoutIfNeeded()
        return CGSize(width: self.container.bounds.width, height: self.container.bounds.height/3)
    }
}


/*
extension VideoPageViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.videos.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "VideoPageCollectionViewCell", at: index) as! VideoPageCollectionViewCell
        
        let vObj = self.videos[index]
        Global.getProfileNameByID(vObj.ownerId) { (name) in
            cell.profileLbl.text = name
        }
        Global.getProfileUrlByID(vObj.ownerId) { (url) in
            cell.profileImg.sd_setImage(with: URL(string: url), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], context: nil)
        }
        
        if index == self.currentIndex {
            cell.canStart = true
        } else {
            cell.canStart = false
        }
        
        if let videoId = vObj.postUrl.youtubeID {
            cell.loadVideo(videoId)
        }
        
        return cell
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        print("current Photo index = %d", targetIndex)
        
        if self.currentIndex != targetIndex {
            let prevCell = pagerView.dequeueReusableCell(withReuseIdentifier: "VideoPageCollectionViewCell", at: self.currentIndex) as! VideoPageCollectionViewCell
            prevCell.stopVideo()
            
            let targetCell = pagerView.dequeueReusableCell(withReuseIdentifier: "VideoPageCollectionViewCell", at: targetIndex) as! VideoPageCollectionViewCell
            targetCell.startVideo()
            
            self.currentIndex = targetIndex
        }
    }
} */
