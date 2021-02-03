//
//  SigninViewController.swift
//  Social Again Live
//
//  Created by Anton Yagov on 09.12.2020.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class SigninViewController: BaseViewController {

    @IBOutlet weak var splashView: UIView!
    @IBOutlet weak var splashViewLeadingContrant: NSLayoutConstraint!
    @IBOutlet weak var loginView: UIView!
    
    private var userRefHandler: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        self.splashViewLeadingContrant.constant = 0
        showLoadingView()
        let firebaseAuth = Auth.auth()        
        if let userAuth = firebaseAuth.currentUser {
            self.getUserInfoFromFBDatabase(userAuth.uid)
        } else {
            self.splashViewLeadingContrant.constant = 0 - self.view.bounds.width
            hideLoadingView()
        }
        
    }
    
    func getUserInfoFromFBDatabase(_ uId: String) {
        if Global.mCurrentUser == nil {
            Global.mCurrentUser = UserObject()
        }
        
        Global.userRef.child(uId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let userValue = snapshot.value as? NSDictionary {
                    Global.mCurrentUser?.initUserWithJsonresponse(value: userValue)
                }
            } else {
                Global.mCurrentUser?.id = uId
                Global.mCurrentUser?.uploadObjectToFirebase()
            }
            
            self.hideLoadingView()
            
            // Go to Main
            if Global.mCurrentUser!.isVerified {
                Global.goMainView()
            } else {
                self.performSegue(withIdentifier: "Login2Verfy", sender: nil)
            }
        }
    }
    
    func signWithCredential(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                self.hideLoadingView()
                self.showAlertWithText(errorText: error.localizedDescription)
                return
            } else {
                let firebaseAuth = Auth.auth()
                if let fbUser = firebaseAuth.currentUser {
                    self.getUserInfoFromFBDatabase(fbUser.uid)
                } else {
                    self.hideLoadingView()
                    self.showAlertWithText(errorText: "Firebase Authentication Failed!")
                    return
                }
            }
        }
    }

    @IBAction func onClickFacebookBtn(_ sender: Any) {
        let loginManager = LoginManager()
        showLoadingView()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                self.showAlertWithText(errorText: error.localizedDescription)
                self.hideLoadingView()
                return
            }

            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                self.showAlertWithText(errorText: "Failed to get access token")
                self.hideLoadingView()
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Global.mCurrentUser = UserObject();
            Global.mCurrentUser?.accountType = .FACEBOOK
            
            let graphRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                          parameters: ["fields": "email, name, picture.type(large)"],
                                                          tokenString: accessToken.tokenString,
                                                          version: nil,
                                                          httpMethod: .get)
            graphRequest.start { (connection, result, error) -> Void in
                if error == nil {
                    if let Info = result as? [String: Any] {
                        Global.mCurrentUser!.name = Info["name"] as? String ?? ""
                        Global.mCurrentUser!.email = Info["email"] as? String ?? ""
                        Global.mCurrentUser!.avatar = Info["profile_pic"] as? String ?? ""
                    } else {
                        print("GraphRequest Failed!")
                    }
                } else {
                    print("error \(error?.localizedDescription ?? "")")
                }
                
                self.signWithCredential(credential)
            }
        }
    }
    
    @IBAction func onClickGoogleSigninBtn(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        showLoadingView()
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance().signIn()
    }
}

extension SigninViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.hideLoadingView()
            self.showAlertWithText(errorText: error.localizedDescription)
            return
        }

        guard let authentication = user.authentication else {
            self.hideLoadingView()
            self.showAlertWithText(errorText: "Google Authentication Failed!")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                            accessToken: authentication.accessToken)
        Global.mCurrentUser = UserObject();
        Global.mCurrentUser?.accountType = .GMAIL
        if let userName = user.profile.name {
            Global.mCurrentUser?.name = userName
        }
        if let userEmail = user.profile.email {
            Global.mCurrentUser?.email = userEmail
        }
        if let userImg = user.profile.imageURL(withDimension: 100) {
            Global.mCurrentUser?.avatar = userImg.absoluteString
        }
        
        self.signWithCredential(credential)
    }
}
