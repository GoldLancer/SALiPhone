//
//  MessageViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 15.01.2021.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

class MessageViewController: BaseViewController {

    @IBOutlet weak var imgProfile: ProfileGreenImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var messageTV: UITableView!
    @IBOutlet weak var inputTxt: UITextView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var chatRoomId: String = ""
    var partnerObj: BaseUserObject?
    var messages: [MsgObj] = []
    
    var bottomMargin: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init MessageList
        let bundle = Bundle(for: type(of: self))
        let msgCellNib = UINib(nibName: "MessageTableViewCell", bundle: bundle)
        self.messageTV.register(msgCellNib, forCellReuseIdentifier: "MessageTableViewCell")
        self.messageTV.delegate = self
        self.messageTV.dataSource = self
        
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
        
        self.nameLable.text = partnerObj!.name
        Global.getProfileUrlByID(partnerObj!.id) { (url) in
            self.imgProfile.sd_setImage(with: URL(string: url), placeholderImage: PROFILE_DEFAULT_WHITE_AVATAR, options: [], context: nil)
        }
        
        showLoadingView("Updating...")
        let msgRef = Global.chatRef.child(chatRoomId).child(ChatConstant.MESSAGES)
        msgRef.observe(.value) { (snapshot) in
            self.messages.removeAll()
            
            if snapshot.exists() {
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    if let data = snap.value as? NSDictionary {
                        let msgObj = MsgObj()
                        msgObj.initMessageWithJsonresponse(value: data)
                        
                        self.messages.append(msgObj)
                    }
                }
            } else {
                Global.chatRef.child(self.chatRoomId).child(ChatConstant.USERS).child(Global.mCurrentUser!.id).setValue(Global.mCurrentUser!.getBaseJsonvalue())
                Global.chatRef.child(self.chatRoomId).child(ChatConstant.USERS).child(self.partnerObj!.id).setValue(self.partnerObj!.getBaseJsonvalue())
                Global.chatRef.child(self.chatRoomId).child(ChatConstant.CHAT_ID).setValue(self.chatRoomId)
            }
            
            self.messageTV.reloadData()
            self.messageTV.layoutIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.messageTV.scrollToBottom(animated: false)
                self.hideLoadingView()
            }            
        }        
    }
    
    deinit {
        removeFireBaseObserver()
    }
    
    func removeFireBaseObserver() {
        Global.chatRef.child(chatRoomId).child(ChatConstant.MESSAGES).removeAllObservers()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        print(keyboardHeight)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomLayoutConstraint.constant = keyboardHeight - self.bottomMargin
            }) { (result) in
                self.messageTV.scrollToBottom()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        print(keyboardHeight)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomLayoutConstraint.constant = 0.0
            }) { (result) in
                self.messageTV.scrollToBottom()
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Msg2Photo" {
            let photoUrl = sender as! String
            if let vc = segue.destination as? MsgPhotoViewController {
                vc.photoUrl = photoUrl
            }
        }
    }
    
    override func processSelectedPhoto(_ selectedImage: UIImage) {
        
        super.processSelectedPhoto(selectedImage)
        
        let msgObj = MsgObj()
        msgObj.msgTime = Global.getCurrentTimeintervalUint()
        msgObj.msgId = "\(msgObj.msgTime)"
        msgObj.senderId = Global.mCurrentUser!.id
        msgObj.receiverId = partnerObj!.id
        msgObj.type = .IMAGE
        
        self.inputTxt.text = ""
        let imgData = selectedImage.jpegData(compressionQuality: 0.5)
        
        Global.chatRef.child(chatRoomId).child(ChatConstant.MESSAGES).child(msgObj.msgId).setValue(msgObj.getJsonvalue())
        Global.chatRef.child(chatRoomId).child(ChatConstant.LAST_MESSAGE).setValue(msgObj.getJsonvalue())
        
        // Play sound

        // Create a reference to the file you want to upload
        let imgRef = Storage.storage().reference().child("\(STORAGE_IMAGE_NAME)\(msgObj.msgId)_chat.jpg")

        // Upload the file to the path "images/rivers.jpg"
        _ = imgRef.putData(imgData!, metadata: nil) { (metadata, error) in
            if error != nil {
                print("Uploading Failed: \(error!.localizedDescription)")
                return
            }
            
            // You can also access to download URL after upload.
            imgRef.downloadURL { (url, error) in
                  guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    
                    return
                }
                
                msgObj.pictureUrl = downloadURL.absoluteString
                
                Global.chatRef.child(self.chatRoomId).child(ChatConstant.MESSAGES).child(msgObj.msgId).setValue(msgObj.getJsonvalue())
                Global.chatRef.child(self.chatRoomId).child(ChatConstant.LAST_MESSAGE).setValue(msgObj.getJsonvalue())
                
                // Send PushNotification...
                Global.getProfileTokenByID(self.partnerObj!.id) { (devToken) in
                    if !devToken.isEmpty {
                        Global.sendPushNotification(message: "Image",
                                                    userName: Global.mCurrentUser!.name,
                                                    senderID: msgObj.senderId,
                                                    receiverID: msgObj.receiverId,
                                                    receiver: msgObj.receiverId,
                                                    deviceToken: devToken,
                                                    sendingTime: msgObj.msgTime,
                                                    msgType: .IMAGE)
                    }
                }
                
            }
        }
    }
    
    @IBAction func onClickPartnerViewBtn(_ sender: Any) {
        showUserProfileView(self.partnerObj!.id, fromChat: true)
    }
    
    @IBAction func onClickCameraBtn(_ sender: Any) {
        
        self.inputTxt.resignFirstResponder()
        
        self.openPhotoActivity()
    }
    
    @IBAction func onClickSendBtn(_ sender: Any) {
        let sendMessage = self.inputTxt.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if sendMessage.isEmpty {
            return
        }
        
        let msgObj = MsgObj()
        msgObj.msgTime = Global.getCurrentTimeintervalUint()
        msgObj.msgId = "\(msgObj.msgTime)"
        msgObj.senderId = Global.mCurrentUser!.id
        msgObj.receiverId = partnerObj!.id
        msgObj.type = .TEXT
        msgObj.message = sendMessage
        
        self.inputTxt.text = ""
        // self.inputTxt.resignFirstResponder()
        
        Global.chatRef.child(chatRoomId).child(ChatConstant.MESSAGES).child(msgObj.msgId).setValue(msgObj.getJsonvalue())
        Global.chatRef.child(chatRoomId).child(ChatConstant.LAST_MESSAGE).setValue(msgObj.getJsonvalue())
        
        // Send Push & Play Sound
        self.playSound("send_msg")
        Global.getProfileTokenByID(partnerObj!.id) { (devToken) in
            if !devToken.isEmpty {
                Global.sendPushNotification(message: msgObj.message,
                                            userName: Global.mCurrentUser!.name,
                                            senderID: msgObj.senderId,
                                            receiverID: msgObj.receiverId,
                                            receiver: msgObj.receiverId,
                                            deviceToken: devToken,
                                            sendingTime: msgObj.msgTime,
                                            msgType: msgObj.type)
            }
        }
    }
    
    @IBAction func onClickMicBtn(_ sender: Any) {
        self.inputTxt.resignFirstResponder()
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath as IndexPath) as! MessageTableViewCell
        
        let msgObj = self.messages[indexPath.row]
        let isMine = (msgObj.senderId == Global.mCurrentUser!.id)
        
        cell.delegate = self
        cell.mMsgObj = msgObj
        
        cell.receiveView.isHidden = isMine
        cell.sendView.isHidden = !isMine
        
        if isMine {
            cell.sendTextView.isHidden = true
            cell.sendImgView.isHidden = true
            
            cell.sendImgProfile.sd_setImage(with: URL(string: Global.mCurrentUser!.avatar), placeholderImage: PROFILE_DEFAULT_WHITE_AVATAR, options: [], context: nil)
        } else {
            cell.receiveTextView.isHidden = true
            cell.receiveImgView.isHidden = true
            
            Global.getProfileUrlByID(partnerObj!.id) { (url) in
                cell.receiveImgProfile.sd_setImage(with: URL(string: url), placeholderImage: PROFILE_DEFAULT_WHITE_AVATAR, options: [], context: nil)
            }
        }
        
        
        if msgObj.type == .TEXT {
            if isMine {
                cell.sendTextView.isHidden = false
                
                cell.sendMsgLbl.text = msgObj.message
                cell.sendTimeLbl.text = Global.getMessageSendTime(msgObj.msgTime)
            } else {
                cell.receiveTextView.isHidden = false
                
                cell.receiveMsgLbl.text = msgObj.message
                cell.receiveTimeLbl.text = Global.getMessageSendTime(msgObj.msgTime)
            }
        } else if msgObj.type == .IMAGE || msgObj.type == .POST {
            if isMine {
                cell.sendImgView.isHidden = false
                
                cell.sendImg.sd_setImage(with: URL(string: msgObj.pictureUrl), completed: nil)
                cell.sendShareLbl.isHidden = (msgObj.type != .POST)
            } else {
                cell.receiveImgView.isHidden = false
                
                cell.receiveImg.sd_setImage(with: URL(string: msgObj.pictureUrl), completed: nil)
                cell.receiveShareLbl.isHidden = (msgObj.type != .POST)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let msgObj = self.messages[indexPath.row]
        if msgObj.type == .IMAGE {
            return 170.0
        } else if msgObj.type == .POST {
            return 190.0
        } else if msgObj.type == .TEXT {
            return UITableView.automaticDimension
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
    }
}

extension MessageViewController: MessageTableViewCellDelegate {
    func onClickedImageBtn(_ msgObj: MsgObj?) {
        guard let mObj = msgObj else {
            return
        }
        
        if (mObj.type == .IMAGE) {
            let photoUrl = mObj.pictureUrl
            self.performSegue(withIdentifier: "Msg2Photo", sender: photoUrl)
        } else {
            return
        }
    }
    
    func onClickedPartnerBtn(_ userId: String) {
        showUserProfileView(userId, fromChat: true)
    }
}

extension UITableView {
    func scrollToBottom(animated: Bool = true) {
        let section = self.numberOfSections
        if section > 0 {
            let row = self.numberOfRows(inSection: section - 1)
            if row > 0 {

                self.scrollToRow(at: IndexPath(row: row-1, section: section-1), at: .bottom, animated: animated)
            }
        }
    }
}
