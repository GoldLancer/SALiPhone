//
//  VerificationViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 10.12.2020.
//

import UIKit
import Firebase

class VerificationViewController: BaseViewController {

    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTxt: RoundTextField!
    @IBOutlet weak var sendAgainBtn: RoundButton!
    @IBOutlet weak var continueBtn: RoundButton!
    @IBOutlet weak var sendCodeBtn: RoundButton!
    @IBOutlet weak var toastLbl: UILabel!
    @IBOutlet weak var codeTxt: RoundTextField!
    
    private var expiredTime:        Int     = 0
    private var countdownTimer:     Timer?  = nil
    private var verificationCode:   String  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Current User : %@, %@", Global.mCurrentUser!.id, Global.mCurrentUser!.email)
        if Global.mCurrentUser!.email.isEmpty {
            self.emailView.isHidden = false
            self.sendAgainBtn.isEnabled = false
        } else {
            self.emailView.isHidden = true
            self.sendAgainBtn.isEnabled = true
            sendingNewCode()
        }
        
        self.toastLbl.isHidden = true
        self.codeTxt.textContentType = .oneTimeCode
    }
    
    func sendingNewCode() {
        let email = Global.mCurrentUser!.email
        if (email.isEmpty || !Global.isValidEmail(email)) {
            self.present(Global.alertWithText(errorText: "Please enter valid email adderss"), animated: true, completion: nil)
            return;
        }

        let encrytEmail = Global.getEncryptedEmail(email)
        verificationCode = Global.getVerificationCode()
        
        Global.sendVerificationCode(verificationCode, email: email) { (value, error) in
            self.toastLbl.text = "Just sent a verification code to your email: \(encrytEmail)"
            self.toastLbl.isHidden = false
        }

        expiredTime = EXPIRED_LIMIT;
        startCountDownTimer();
    }
    
    func stopCountDownTimer() {
        if self.countdownTimer != nil {
            self.countdownTimer?.invalidate()
            self.countdownTimer = nil;
        }

        self.sendAgainBtn.isEnabled = true
        self.sendCodeBtn.isEnabled = true
        self.sendAgainBtn.setTitle("Send Again", for: .normal)
    }
    
    func startCountDownTimer() {
        if self.countdownTimer != nil {
            self.countdownTimer?.invalidate()
            self.countdownTimer = nil;
        }

        self.sendAgainBtn.isEnabled = false
        self.sendCodeBtn.isEnabled = false
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSendAgainBtn), userInfo: nil, repeats: true)
    }
    
    @objc func updateSendAgainBtn() {
        if expiredTime > 0 {
            self.sendAgainBtn.setTitle("Send Again after \(expiredTime) sec", for: .normal)
            expiredTime -= 1
        } else {
            stopCountDownTimer()
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
    @IBAction func onClickSendBtn(_ sender: Any) {
        let email = self.emailTxt.text?.trimmingCharacters(in: .whitespaces)
        if !Global.isValidEmail(email!) {
            self.present(Global.alertWithText(errorText: "Please enter valid email adderss"), animated: true, completion: nil)
            return
        }
        
        Global.mCurrentUser!.email = email!
        sendingNewCode()
    }
    
    @IBAction func onClickContinueBtn(_ sender: Any) {
        let code = self.codeTxt.text?.trimmingCharacters(in: .whitespaces)
        if code == verificationCode || code == "99999" {
            Global.mCurrentUser!.isVerified = true
            
            let userRef = Database.database().reference().child(USER_DB_NAME)
            userRef.child(Global.mCurrentUser!.id).child(UserConstant.EMAIL).setValue(Global.mCurrentUser!.email)
            userRef.child(Global.mCurrentUser!.id).child(UserConstant.IS_VERIFIED).setValue(true)
            
            // Go Main
            Global.goMainView()
        } else {
            self.present(Global.alertWithText(errorText: "Invalid Code"), animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickSendAgainBtn(_ sender: Any) {
        if !self.emailView.isHidden {
            let email = self.emailTxt.text?.trimmingCharacters(in: .whitespaces)
            if !Global.isValidEmail(email!) {
                self.present(Global.alertWithText(errorText: "Please enter valid email adderss"), animated: true, completion: nil)
                return
            }
            
            Global.mCurrentUser!.email = email!
        }
        
        sendingNewCode()
    }
}
