//
//  PostVideoViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 22.01.2021.
//

import UIKit
import AVKit
import youtube_ios_player_helper_swift

class PostVideoViewController: PostBaseViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var ytView: UIView!
    @IBOutlet weak var ytPlayerView: YTPlayerView!
    @IBOutlet weak var playImg: UIImageView!
    
    var moviePlayer:AVPlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUIWithObject()
    }
    
    override func updateUIWithObject() {
        guard let feedobj = self.mFeedObj else {
            return
        }
        
        super.updateUIWithObject()
        
        if feedobj.type == .VIDEO {
            self.ytView.isHidden = true
            self.videoView.isHidden = false
            
            let url = URL(string: feedobj.postUrl)
            let player = AVPlayer(url: url!)
            
            moviePlayer.player = player
            moviePlayer.view.frame = self.videoView.bounds
            self.addChild(moviePlayer)
            self.videoView.addSubview(moviePlayer.view)
            moviePlayer.didMove(toParent: self)
            
        } else {
            self.ytView.isHidden = false
            self.ytPlayerView.isHidden = true
            self.videoView.isHidden = true
            
            
            self.ytPlayerView.delegate = self
            
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
            
            if let videoId = feedobj.postUrl.youtubeID {
                _ = self.ytPlayerView.load(videoId: videoId, playerVars: playerVars)
                self.ytPlayerView.isUserInteractionEnabled = true
            } else {
                showAlertWithText(errorText: "Can't get Youtube Video ID from this feed.")
            }
        }
    }
    

    @IBAction func onClickYTPlayerView(_ sender: Any) {
        
        if self.playImg.isHidden == true {
            self.playImg.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.playImg.isHidden = true
            }
            
        } else {
            if self.ytPlayerView.playerState == .playing {
                self.ytPlayerView.pauseVideo()
                self.playImg.image = UIImage(systemName: "play.circle")
            } else {
                self.ytPlayerView.playVideo()
                self.playImg.image = UIImage(systemName: "pause.circle")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.playImg.isHidden = true
                }
            }
        }
        
        
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

extension PostVideoViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.ytPlayerView.playVideo()
        self.ytPlayerView.isHidden = false
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float){
        
    }
    
    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor{
        return MAIN_BG_DARK_COLOR ?? UIColor.black
    }
}

extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"

        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)

        guard let result = regex?.firstMatch(in: self, range: range) else {
            return nil
        }

        return (self as NSString).substring(with: result.range)
    }
    
    var youtubeThumbUrl: String? {
        
        if !self.isEmpty {
            return "https://img.youtube.com/vi/\(self)/0.jpg"
        }
        return nil
    }
}
