//
//  FollowViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 21.01.2021.
//

import UIKit

class FollowViewController: BaseViewController {

    @IBOutlet weak var titleLBl: UILabel!
    @IBOutlet weak var followTV: UITableView!
    
    var isFollower = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init ContactList
        let bundle = Bundle(for: type(of: self))
        let followCellNib = UINib(nibName: "FollowTableViewCell", bundle: bundle)
        self.followTV.register(followCellNib, forCellReuseIdentifier: "FollowTableViewCell")
        self.followTV.delegate = self
        self.followTV.dataSource = self
        
        self.titleLBl.text = isFollower ? "Followers" : "Followings"
        
        // MARK: Add Notification
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFollowUserList), name: .didReloadFollowers, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFollowUserList), name: .didReloadFollowings, object:nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func reloadFollowUserList() {
        self.followTV.reloadData()
    }

    @IBAction func onClickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FollowViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFollower {
            return Global.followerObjs.count
        } else {
            return Global.followingObjs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath as IndexPath) as! FollowTableViewCell
        
        cell.delegate = self
        cell.cellIndex = indexPath.row
        
        var userObj: BaseUserObject
        if self.isFollower {
            userObj = Global.followerObjs[indexPath.row]
        } else {
            userObj = Global.followingObjs[indexPath.row]
        }
        
        let followed = Global.alreadyFollowed(userObj.id)
        cell.followBtn.setTitle(followed ? "UnFollow" : "Follow", for: .normal)
        
        cell.countryLbl.text = userObj.country
        Global.getProfileNameByID(userObj.id) { (name) in
            cell.userNameLbl.text = name
        }
        Global.getProfileUrlByID(userObj.id) { (url) in
            cell.userProfileImg.sd_setImage(with: URL(string: url), placeholderImage: PROFILE_DEFAULT_GREEN_AVATAR, options: [], completed: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}

extension FollowViewController: FollowTableViewCellDelegate {
    func clickedUserProfile(_ cellIndex: Int) {
        var userObj: BaseUserObject
        if self.isFollower {
            userObj = Global.followerObjs[cellIndex]
        } else {
            userObj = Global.followingObjs[cellIndex]
        }
        
        self.showUserProfileView(userObj.id)
    }
    
    func clickedFollowingBtn(_ cellIndex: Int) {
        var userObj: BaseUserObject
        if self.isFollower {
            userObj = Global.followerObjs[cellIndex]
        } else {
            userObj = Global.followingObjs[cellIndex]
        }
        
        _ = Global.followUser(userObj.id)
    }
}
