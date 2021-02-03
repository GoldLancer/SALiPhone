//
//  ChatListTVCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 14.01.2021.
//

import UIKit

protocol ChatListTVCellDelegate {
    func showPartnerUserProfile(_ userId: String)
    func clickedDeleteBtn(_ cellIndex: Int)
}
class ChatListTVCell: UITableViewCell {

    @IBOutlet weak var imgProfile: ProfileGreenImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var delegate: ChatListTVCellDelegate?
    var partnerId: String = ""
    var chatIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickDeleteCellBtn(_ sender: Any) {
        self.delegate?.clickedDeleteBtn(self.chatIndex)
    }
    
    @IBAction func onClickProfileBtn(_ sender: Any) {
        self.delegate?.showPartnerUserProfile(self.partnerId)
    }
}
