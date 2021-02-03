//
//  BaseBroadcastingViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 31.01.2021.
//

import UIKit
import IQKeyboardManagerSwift


class BaseBroadcastingViewController: BaseViewController {
    
    @IBOutlet weak var commentTV: UITableView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentTVHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var mainViewBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var profileImg: ProfileGreenImageView!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    
    var watchers: Int = 0
    var bottomMargin: CGFloat = 0    
    var msgList: [CommentObject] = []
    
    var currentStreamId: String = ""
    var isPlayer = false

    override func viewDidLoad() {
        super.viewDidLoad()

        IQKeyboardManager.shared.enable = false
        // Get Bottom Margin Between safeview and superview
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows[0]
            // let topPadding = window?.safeAreaInsets.top
            self.bottomMargin = window.safeAreaInsets.bottom
        }
        
        // Define Keyboard Event
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification , object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification , object:nil)
    }
    
    func initUI() {
        // Init MessageList
        let bundle = Bundle(for: type(of: self))
        let msgCellNib = UINib(nibName: "LiveCommentTableViewCell", bundle: bundle)
        self.commentTV.register(msgCellNib, forCellReuseIdentifier: "LiveCommentTableViewCell")
        self.commentTV.delegate = self
        self.commentTV.dataSource = self
    }
    
    func upgradeWatcherCounter() {
        self.countLbl.text = "\(self.watchers)"
        Global.videoRef.child(self.currentStreamId).child(StreamConstant.WATCHERS).setValue(watchers);
    }
    
    func removeFirebaseListener() {
        // Remove Obsever for partner
        // videoRef.child(GlobalManager.mVideoObj.streamId).child("partner").removeAllObservers()
        Global.videoRef.child(self.currentStreamId).child(StreamConstant.COMMENTS).removeAllObservers()
    }
    
    func addFirebaseListener() {
        // Add Obsever for partner
        // videoRef.child(GlobalManager.mVideoObj.streamId).child("partner").addValueEventListener(partnerStatusListener);
        
        // Add Comments Obsever
        Global.videoRef.child(self.currentStreamId).child(StreamConstant.COMMENTS).observe(.childAdded) { (snapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                let commentObj = CommentObject()
                commentObj.initObjectWithJsonresponse(value: data)
                
                switch commentObj.type {
                case .FOLLOW:
                    break

                case .UNFOLLOW:
                    break

                case .CAME_IN:
                    if self.isPlayer {
                        self.watchers += 1
                        self.upgradeWatcherCounter()
                        self.updateStatusLable("\(commentObj.userName) is Watching")
                    }
                    break;

                case .CAME_OUT:
                    if self.isPlayer {
                        self.watchers -= 1
                        if self.watchers < 0 {
                            self.watchers = 0
                        }
                        self.upgradeWatcherCounter()
                    }
                    break;

                default:
                    self.msgList.append(commentObj)
                    break;
                }
                
                self.reloadCommentTV()
            }
        }
    }
    
    private func reloadCommentTV() {
        self.commentTV.reloadData()
        
        self.view.layoutIfNeeded()
        let height = self.commentTV.contentSize.height
        if height < self.commentView.bounds.height {
            self.commentTVHeightLayout.constant = height
        } else {
            self.commentTVHeightLayout.constant = self.commentView.bounds.height
        }
        self.commentTV.scrollToBottom(animated: true)
    }
    
    func updateStatusLable(_ statusMsg: String, alwaysShow: Bool = false) {
        
        self.statusLbl.text = "    \(statusMsg)    "
        self.statusLbl.isHidden = false
        
        if !alwaysShow {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.statusLbl.isHidden = true
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        print(keyboardHeight)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.mainViewBottomLayout.constant = keyboardHeight - self.bottomMargin
            }) { (result) in
                self.commentTV.scrollToBottom()
            }
        }
        self.view.layoutIfNeeded()
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        print(keyboardHeight)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.mainViewBottomLayout.constant = 0.0
            }) { (result) in
                self.commentTV.scrollToBottom()
            }
        }
        self.view.layoutIfNeeded()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onClickSendBtn(_ sender: Any) {
        let msgStr = self.commentTxt.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if msgStr.isEmpty {
            return
        }
        
        let cObj = CommentObject()
        cObj.userId = Global.mCurrentUser!.id
        cObj.userName = Global.mCurrentUser!.name
        cObj.message = msgStr
        cObj.type = .COMMENT
        
        cObj.uploadObjectToFirebase(Global.videoRef.child(self.currentStreamId).child(StreamConstant.COMMENTS))
        
        self.commentTxt.text = ""
        self.commentTxt.resignFirstResponder()
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickProfileBtn(_ sender: Any) {
    }
    
    @IBAction func onClickCommentBtn(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.commentTV.isHidden = !self.commentTV.isHidden
        }
    }

}

extension BaseBroadcastingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.msgList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveCommentTableViewCell", for: indexPath as IndexPath) as! LiveCommentTableViewCell
        
        let msgObj = self.msgList[indexPath.row]
        
        cell.nameLbl.text = "\(msgObj.userName):"
        cell.msgLbl.text = msgObj.message
        
        var nameLblWidth = cell.nameLbl.intrinsicContentSize.width
        if nameLblWidth > 150 {
            nameLblWidth = 150
        }
        cell.nameLabelWidthLayout.constant = nameLblWidth
        cell.layoutIfNeeded()
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
