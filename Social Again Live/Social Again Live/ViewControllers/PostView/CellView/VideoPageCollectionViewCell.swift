//
//  VideoPageCollectionViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 23.01.2021.
//

import UIKit
import FSPagerView
import youtube_ios_player_helper_swift

class VideoPageCollectionViewCell: FSPagerViewCell, YTPlayerViewDelegate {

    @IBOutlet weak var profileLbl: UILabel!
    @IBOutlet weak var profileImg: ProfileGreenImageView!
    @IBOutlet weak var playImg: UIImageView!
    @IBOutlet weak var ytplayerView: YTPlayerView!
    
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
    
    var ytId: String? = nil
    var canStart: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.ytplayerView.isHidden = true
        self.ytplayerView.delegate = self
        self.ytplayerView.isUserInteractionEnabled = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
//        ytplayerView.pauseVideo()
    }
    
    func loadVideo(_ ytId: String) {
        _ = self.ytplayerView.load(videoId: ytId, playerVars: playerVars)
    }
    
    func stopVideo() {
//        self.ytplayerView.load
//        if self.ytplayerView.playerState == .playing {
//            self.ytplayerView.pauseVideo()
//        }
    }
    
    func startVideo() {
//        switch self.ytplayerView.playerState {
//        case .playing:
//            break
//        case .buffering:
//            break
//        case .paused:
//            self.ytplayerView.playVideo()
//            break
//        case .ended:
//            self.ytplayerView.playVideo()
//            break
//        default:
//            canStart = true
//            _ = self.ytplayerView.load(videoId: self.ytId!, playerVars: playerVars)
//        }
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        if canStart {
            self.ytplayerView.playVideo()
            canStart = false
        }
        self.ytplayerView.isHidden = false
    }

}
