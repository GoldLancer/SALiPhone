//
//  PublishViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 27.01.2021.
//

import UIKit
import WebRTC
import WebRTCiOSSDK
import AVFoundation
import Firebase

enum PlayStatus {
    case PLAYING
    case PAUSED
    case STOPPED
}

let DISABLE_ALPHA_VALUE: CGFloat = 0.3
let ENABLE_ALPHA_VALUE: CGFloat = 1.0

class PublishViewController: BaseBroadcastingViewController {

    @IBOutlet var preView: RTCEAGLVideoView!
    @IBOutlet var categoryBtn: RoundButton!
    @IBOutlet var segBtn: UISegmentedControl!
    @IBOutlet var pauseBtn: UIButton!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var stopBtn: UIButton!
    
    var playStatus: PlayStatus = .STOPPED {
        didSet {
            disableAllPlayBtns()
            
            DispatchQueue.main.async {
                self.segBtn.isUserInteractionEnabled = true
                self.categoryBtn.isUserInteractionEnabled = true
                
                switch self.playStatus {
                case .PLAYING:
                    self.pauseBtn.isUserInteractionEnabled = true
                    self.pauseBtn.alpha = ENABLE_ALPHA_VALUE
                    self.stopBtn.isUserInteractionEnabled = true
                    self.stopBtn.alpha = ENABLE_ALPHA_VALUE
                    
                    self.segBtn.isUserInteractionEnabled = false
                    self.categoryBtn.isUserInteractionEnabled = false
                    break
                case .PAUSED:
                    self.playBtn.isUserInteractionEnabled = true
                    self.playBtn.alpha = ENABLE_ALPHA_VALUE
                    self.stopBtn.isUserInteractionEnabled = true
                    self.stopBtn.alpha = ENABLE_ALPHA_VALUE
                    break
                case .STOPPED:
                    self.playBtn.isUserInteractionEnabled = true
                    self.playBtn.alpha = ENABLE_ALPHA_VALUE
                    break
                }
            }
        }
    }
    
    let client: AntMediaClient = AntMediaClient.init()
    let clientMode: AntMediaClientMode = .publish
    let clientUrl = "ws://\(SERVER_ADDRESS)/LiveApp/websocket"
    
    var tapGesture: UITapGestureRecognizer!
    
    var isGhosting: Bool = false
    var tucoin: Int = 0    
    var ctIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Global.deleteOldStreamFiles()
        self.setGesture()
        
        self.isPlayer = true
        self.currentStreamId = Global.mCurrentStream!.streamId
        
        self.initUI()
        self.initFBDB()
        
        self.configureRTCClient()
        
        Global.videoRef.child(Global.mCurrentStream!.streamId).child(StreamConstant.COMMENTS).removeValue { (error, dataRef) in
            self.addFirebaseListener()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.playStatus == .PLAYING {
            self.client.start()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.client.isConnected() {
            self.client.stop()
        }
    }
    
    deinit {
        
    }
    
    override func selectedCategoryWithIndex(ctIndex: Int) {
        super.selectedCategoryWithIndex(ctIndex: ctIndex)
        
        self.ctIndex = ctIndex
        self.categoryBtn.setTitle(CATEGORY_ITEMS[ctIndex], for: .normal)
    }
    
    override func initUI() {
        super.initUI()
        
        self.profileImg.sd_setImage(with: URL(string: Global.mCurrentUser!.avatar), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], context: nil)
        self.upgradeWatcherCounter()
        
        for (i, ctname) in CATEGORY_ITEMS.enumerated() {
            if ctname == Global.mCurrentStream!.category {
                self.ctIndex = i
                break
            }
        }
        
        self.categoryBtn.setTitle(CATEGORY_ITEMS[self.ctIndex], for: .normal)
        
        // Init MessageList
        let bundle = Bundle(for: type(of: self))
        let msgCellNib = UINib(nibName: "LiveCommentTableViewCell", bundle: bundle)
        self.commentTV.register(msgCellNib, forCellReuseIdentifier: "LiveCommentTableViewCell")
        self.commentTV.delegate = self
        self.commentTV.dataSource = self
    }
    
    private func initFBDB() {
        Global.mCurrentStream!.comments = []
        
        let streamRef = Global.videoRef.child(Global.mCurrentStream!.streamId)
        streamRef.child(StreamConstant.IS_GHOST).setValue(false)
        streamRef.child(StreamConstant.IS_MULTI).setValue(false)
        
        // Init Partner Object
        // videoRef.child(GlobalManager.mVideoObj.streamId).child("isMulti").setValue(false);
        // videoRef.child(GlobalManager.mVideoObj.streamId).child("partner").setValue(new PartnerObj());
        
        
    }
    
    private func configureRTCClient() {
        self.view.layoutIfNeeded()
        
        self.preView.transform = CGAffineTransform(scaleX: -1, y: 1);
        
        self.client.delegate = self
        self.client.setDebug(true)
        self.client.setOptions(url: self.clientUrl, streamId: Global.mCurrentUser!.streamID, token: SERVER_TOKEN, mode: self.clientMode, enableDataChannel: true)

        /*
         Enable the below line if you use multi peer node for embedded sdk
         */
        //self.client.setMultiPeerMode(enable: true, mode: "play")
        /*
         Enable below line if you don't want to have mic permission dialog while playing
         */
        //dontAskMicPermissionForPlaying();
        
        self.client.setCameraPosition(position: .front)
        self.client.setTargetResolution(width: Int(self.preView.bounds.width), height: Int(self.preView.bounds.height))
        self.client.setLocalView(container: self.preView, mode: .scaleAspectFill)
        
        //calling this method is not necessary. It just initializes the connection and opens the camera
        self.client.initPeerConnection()
    }
    
    private func setGesture() {
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleContainer))
        self.tapGesture.numberOfTapsRequired = 1
        self.preView.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func showTUCoinDialog(_ currentIndex: Int = 0) {
        let storyboard = UIStoryboard(name: "TuCoin", bundle: nil)
        if let tuDialog = storyboard.instantiateViewController(withIdentifier: "TuCoinsView") as? TuCoinsViewController {
            tuDialog.delegate = self
            
            tuDialog.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            tuDialog.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            
            self.present(tuDialog, animated: true, completion: nil)
        }
    }
    
    private func finishPublishing() {
        
    }
    
    private func disableAllPlayBtns() {
        DispatchQueue.main.async {
            self.playBtn.isUserInteractionEnabled = false
            self.playBtn.alpha = DISABLE_ALPHA_VALUE
            self.pauseBtn.isUserInteractionEnabled = false
            self.pauseBtn.alpha = DISABLE_ALPHA_VALUE
            self.stopBtn.isUserInteractionEnabled = false
            self.stopBtn.alpha = DISABLE_ALPHA_VALUE
        }
    }
    
    private func updateFBDBValues() {
        
        let isConnected = self.client.isConnected()
        
        Global.mCurrentStream!.isOnline = isConnected
        Global.mCurrentStream!.isGhost = self.isGhosting
        Global.mCurrentStream!.videoTitle = Global.mCurrentUser!.name
        Global.mCurrentStream!.category = CATEGORY_ITEMS[self.ctIndex]
        Global.mCurrentStream!.tuCoins = isGhosting ? self.tucoin : 0
        Global.mCurrentStream!.comments = []
        Global.mCurrentStream!.joiners = []
        Global.mCurrentStream!.created = Global.getCurrentTimeintervalString()
        
        Global.mCurrentStream!.uploadObjectToFirebase()
        Global.userRef.child(Global.mCurrentUser!.id).child(UserConstant.CATEGORY).setValue(Global.mCurrentStream!.category)
        Global.mCurrentUser!.category = Global.mCurrentStream!.category
        
        if isConnected {
            // Send Push notification
        }
    }
    
    @objc private func toggleContainer() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
        })
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onClickStopBtn(_ sender: Any) {
        
        self.showLoadingView("Disconnecting...")
        if self.client.isConnected() {
            self.client.stop()
        }
    }
    
    @IBAction func onClickPlayBtn(_ sender: Any) {
        
        if self.client.isConnected() {
            // resume play
        } else {
            self.showLoadingView("Connecting...")
            self.client.start()
        }
    }
    
    @IBAction func onClickPauseBtn(_ sender: Any) {
    }
    
    @IBAction func onChangedSegBtn(_ sender: Any) {
        if self.segBtn.selectedSegmentIndex == 0 {
            self.isGhosting = true
            self.showTUCoinDialog()
        } else {
            self.isGhosting = false
            
            self.segBtn.setTitle("Go Ghost", forSegmentAt: 0)
            self.tucoin = 0
        }

    }
    
    @IBAction func onClickCategoryBtn(_ sender: Any) {
        self.showCategoryDialog(self.ctIndex)
    }
    
}

extension PublishViewController: TuCoinsViewControllerDelegate {
    func selectedTuCoin(_ amount: Int) {
        self.tucoin = amount
        
        self.segBtn.setTitle("TU \(amount)", forSegmentAt: 0)
    }
}

extension PublishViewController: AntMediaClientDelegate {
    func clientDidConnect(_ client: AntMediaClient) {
        print("Broadcasting: clientDidConnect")
    }
    
    func clientDidDisconnect(_ message: String) {
        print("Broadcasting: clientDidDisConnect")
        
        self.hideLoadingView()
        
        self.playStatus = .STOPPED
        self.updateFBDBValues()
    }
    
    func clientHasError(_ message: String) {
        print("Broadcasting: hasError \(message)")
    }
    
    func remoteStreamStarted() {
        print("Broadcasting: remoteStreamStarted")
    }
    
    func remoteStreamRemoved() {
        print("Broadcasting: remoteStreamRemoved")
    }
    
    func localStreamStarted() {
        print("Broadcasting: localStreamStarted")
    }
    
    func playStarted() {
        
    }
    
    func playFinished() {
        
    }
    
    func publishStarted() {
        print("Broadcasting: Publish Started")

        self.hideLoadingView()
        
        if self.isGhosting {
            self.updateStatusLable("Ghost Broadcasting...")
        } else {
            self.updateStatusLable("Broadcasting...")
        }
        
        self.playStatus = .PLAYING
        self.updateFBDBValues()
    }
    
    func publishFinished() {
        print("Broadcasting: Publish Finished")
    }
    
    func disconnected() {
        print("Broadcasting: Disconnected")
    }
    
    func audioSessionDidStartPlayOrRecord() {
        
    }
    
    func dataReceivedFromDataChannel(streamId: String, data: Data, binary: Bool) {
        
    }
}
