//
//  ChatListViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 14.01.2021.
//

import UIKit

class ChatListViewController: BaseViewController {

    @IBOutlet weak var chatlistTV: UITableView!
    
    var isEditingCell: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init ChatList
        let bundle = Bundle(for: type(of: self))
        let chatCellNib = UINib(nibName: "ChatListTVCell", bundle: bundle)
        self.chatlistTV.register(chatCellNib, forCellReuseIdentifier: "ChatListTVCell")
        self.chatlistTV.delegate = self
        self.chatlistTV.dataSource = self
        
        // MARK: Add Notification
        NotificationCenter.default.addObserver(self, selector: #selector(reloadChatRooms), name: .didReloadChatRooms, object:nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func reloadChatRooms() {
        self.chatlistTV.reloadData()
    }
    
    @IBAction func onClickEditBtn(_ sender: Any) {
        self.isEditingCell = !self.isEditingCell
        
        self.chatlistTV.reloadData()
    }
    
    @IBAction func onClickAddBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "Chat2Search", sender: nil)
    }
    
    @IBAction func onClickClearBtn(_ sender: Any) {
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Global.chatObjs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTVCell", for: indexPath as IndexPath) as! ChatListTVCell
        
        cell.delegate = self
        cell.chatIndex = indexPath.row
        
        let chatObj = Global.chatObjs[indexPath.row]
        if chatObj.lastMsg.type == .TEXT {
            cell.msgLbl.text = chatObj.lastMsg.message
        } else if chatObj.lastMsg.type == .IMAGE {
            if chatObj.lastMsg.senderId == Global.mCurrentUser!.id {
                cell.msgLbl.text = "Send a Photo"
            } else {
                cell.msgLbl.text = "Received a Photo"
            }
        }
        for user in chatObj.users {
            if user.id != Global.mCurrentUser!.id {
                cell.partnerId = user.id
                Global.getProfileUrlByID(user.id) { (url) in
                    cell.imgProfile.sd_setImage(with: URL(string: url), placeholderImage: PROFILE_DEFAULT_WHITE_AVATAR, options: [], completed: nil)
                }
                cell.nameLbl.text = user.name
                break
            }
        }
        cell.deleteBtn.isHidden = !self.isEditingCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chatObj = Global.chatObjs[indexPath.row]
        for user in chatObj.users {
            if user.id != Global.mCurrentUser!.id {
                self.showMessageView(chatObj.chatId, pObj: user)
                break
            }
        }        
    }
}

extension ChatListViewController: ChatListTVCellDelegate {
    func clickedDeleteBtn(_ cellIndex: Int) {
        
    }
    
    func showPartnerUserProfile(_ userId: String) {
        showUserProfileView(userId)
    }
}
