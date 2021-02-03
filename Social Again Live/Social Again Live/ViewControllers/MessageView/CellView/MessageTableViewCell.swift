//
//  MessageTableViewCell.swift
//  Social Again Live
//
//  Created by Anton Yagov on 15.01.2021.
//

import UIKit

protocol MessageTableViewCellDelegate {
    func onClickedImageBtn(_ msgObj: MsgObj?)
    func onClickedPartnerBtn(_ userId: String)
}

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var receiveView: UIView!
    @IBOutlet weak var receiveTimeLbl: UILabel!
    @IBOutlet weak var receiveImgProfile: ProfileWhiteImageView!
    @IBOutlet weak var receiveTextView: UIView!
    @IBOutlet weak var receiveMsgLbl: UILabel!
    @IBOutlet weak var receiveImgView: UIView!
    @IBOutlet weak var receiveImg: UIImageView!
    @IBOutlet weak var receiveShareLbl: UILabel!
    
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var sendTimeLbl: UILabel!
    @IBOutlet weak var sendImgProfile: ProfileWhiteImageView!
    @IBOutlet weak var sendTextView: UIView!
    @IBOutlet weak var sendMsgLbl: UILabel!
    @IBOutlet weak var sendImgView: UIView!
    @IBOutlet weak var sendImg: UIImageView!
    @IBOutlet weak var sendShareLbl: UILabel!
    
    var mMsgObj: MsgObj?
    var delegate: MessageTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickReceiveImageBtn(_ sender: Any) {
        self.delegate?.onClickedImageBtn(self.mMsgObj)
    }
    
    @IBAction func onClickSendImageBtn(_ sender: Any) {
        self.delegate?.onClickedImageBtn(self.mMsgObj)
    }
    
    @IBAction func onClickPartnerAvatarBtn(_ sender: Any) {
        self.delegate?.onClickedPartnerBtn(mMsgObj!.senderId)
    }
}
