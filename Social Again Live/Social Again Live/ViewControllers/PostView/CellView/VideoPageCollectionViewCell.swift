//
//  VideoPageCollectionViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 23.01.2021.
//

import UIKit
import FSPagerView
import YoutubePlayer_in_WKWebView

class VideoPageCollectionViewCell: FSPagerViewCell, WKYTPlayerViewDelegate {

    @IBOutlet weak var profileLbl: UILabel!
    @IBOutlet weak var profileImg: ProfileGreenImageView!
    @IBOutlet weak var playImg: UIImageView!
    @IBOutlet weak var ytplayerView: WKYTPlayerView!
    
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
    var playerStatus: WKYTPlayerState = .unstarted
    var canStart: Bool = false
    var cellIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.ytplayerView.isHidden = true
        self.ytplayerView.delegate = self
        self.ytplayerView.isUserInteractionEnabled = true
    }
    
    func loadVideo(_ ytId: String) {
        canStart = false
        self.playerStatus = .unstarted
        _ = self.ytplayerView.load(withVideoId: ytId, playerVars: playerVars)
    }
    
    func deselectedVideo() {
        if self.playerStatus == .playing || self.playerStatus == .buffering {
            self.ytplayerView.pauseVideo()
        }
//        self.ytplayerView.load
//        if self.ytplayerView.playerState == .playing {
//            self.ytplayerView.pauseVideo()
//        }
    }
    
    func selectedVideo() {
//        if self.cellIndex ==
        if self.playerStatus == .unstarted {
//            self.ytplayerView.playVideo()
        } else if self.playerStatus == .paused {
            self.ytplayerView.playVideo()
        }
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
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        self.ytplayerView.isHidden = false
        
        self.ytplayerView.playVideo()
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        print("YTPlayerView: \(self.cellIndex) Did Change To \(state.rawValue)")
        if self.cellIndex != Global.ytVideoIndex {
            if state == .playing {
                playerView.pauseVideo()
            }
        } else {
            if state == .paused {
                playerView.playVideo()
            }
        }
        
        self.playerStatus = state
    }

}
