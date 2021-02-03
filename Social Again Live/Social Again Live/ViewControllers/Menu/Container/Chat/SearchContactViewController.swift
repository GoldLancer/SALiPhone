//
//  SearchContactViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 19.01.2021.
//

import UIKit
import Firebase

class SearchContactViewController: BaseViewController {

    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var contactTV: UITableView!
    
    var contacts: [UserObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initContactList()

        // Init ContactList
        let bundle = Bundle(for: type(of: self))
        let chatCellNib = UINib(nibName: "ChatListTVCell", bundle: bundle)
        self.contactTV.register(chatCellNib, forCellReuseIdentifier: "ChatListTVCell")
        self.contactTV.delegate = self
        self.contactTV.dataSource = self
        
        self.searchTxt.attributedPlaceholder = NSAttributedString(string: "User Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        self.searchTxt.delegate = self
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initContactList() {
        self.contacts.removeAll()
        for chatObj in Global.chatObjs {
            for uObj in chatObj.users {
                if uObj.id != Global.mCurrentUser!.id {
                    let userObj = UserObject()
                    userObj.copyBaseValues(uObj)
                    
                    self.contacts.append(userObj)
                }
            }
        }
        
        refreshContactList()
    }
    
    func refreshContactList() {
        self.contacts.sort(by: { $0.name < $1.name })
        
        self.contactTV.reloadData()
    }

    @IBAction func onClickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchContactViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTxt.resignFirstResponder()
        
        let searchKey = self.searchTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchKey.isEmpty {
            initContactList()
            return false
        }
        
        self.showLoadingView("Searching...")
        Global.userRef.observeSingleEvent(of: .value) { (snapshot) in
            self.contacts.removeAll()
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let data = snap.value as? NSDictionary {
                    let uObj = UserObject()
                    uObj.initUserWithJsonresponse(value: data)
                    
                    if uObj.id != Global.mCurrentUser!.id &&
                        uObj.name.lowercased().contains(searchKey.lowercased()) {
                        self.contacts.append(uObj)
                    }                    
                }
            }
            
            self.hideLoadingView()
            self.refreshContactList()
        }
        
        return false
    }
}

extension SearchContactViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTVCell", for: indexPath as IndexPath) as! ChatListTVCell
        
        cell.delegate = self
        cell.chatIndex = indexPath.row
        
        let userObj = self.contacts[indexPath.row]
        cell.partnerId = userObj.id
        
        Global.getProfileUrlByID(userObj.id) { (url) in
            cell.imgProfile.sd_setImage(with: URL(string: url), placeholderImage: PROFILE_DEFAULT_WHITE_AVATAR, options: [], completed: nil)
        }
        cell.nameLbl.text = userObj.name
        cell.msgLbl.text = userObj.country
        
        cell.deleteBtn.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userObj = self.contacts[indexPath.row]
        self.showUserProfileView(userObj.id)
    }
}

extension SearchContactViewController: ChatListTVCellDelegate {
    func clickedDeleteBtn(_ cellIndex: Int) {
        
    }
    
    func showPartnerUserProfile(_ userId: String) {
        showUserProfileView(userId)
    }
}
