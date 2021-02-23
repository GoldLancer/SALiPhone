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
import AuthenticationServices
import CryptoKit

class SigninViewController: BaseViewController {

    @IBOutlet weak var splashView: UIView!
    @IBOutlet weak var splashViewLeadingContrant: NSLayoutConstraint!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var appleBtnView: UIView!
    let appleButton = ASAuthorizationAppleIDButton(type: .continue, style: .black)
    
    private var userRefHandler: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        self.view.layoutIfNeeded()
        self.appleButton.frame = CGRect(x: 0, y: 0, width: self.appleBtnView.bounds.width, height: self.appleBtnView.bounds.height)
        self.appleBtnView.addSubview(self.appleButton)
        self.appleButton.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        
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
            Global.goMainView()
            /*
            if Global.mCurrentUser!.isVerified {
                Global.goMainView()
            } else {
                self.performSegue(withIdentifier: "Login2Verfy", sender: nil)
            } */
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
    
    @IBAction func onClickAppleSigninBtn(_ sender: Any) {
        showLoadingView("")
        startSignInWithAppleFlow()
    }
    
    @IBAction func onClickGoogleSigninBtn(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        showLoadingView()
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    // MARK: APPLE Login
    
    fileprivate var currentNonce: String?

    @available(iOS 13, *)
    @objc func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
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

@available(iOS 13.0, *)
extension SigninViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }


    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                self.hideLoadingView()
                self.showAlertWithText(errorText: "Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.hideLoadingView()
                self.showAlertWithText(errorText: "Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)
            // Sign in with Firebase.
            self.signWithCredential(credential)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }

}
