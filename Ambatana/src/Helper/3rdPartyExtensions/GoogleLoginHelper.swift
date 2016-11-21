//
//  GoogleLoginHelper.swift
//  LetGo
//
//  Created by Isaac Roldan on 15/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

typealias GoogleLoginCompletion = ((result: ExternalServiceAuthResult) -> ())?

enum GoogleSignInResult {
    case Success(serverAuthCode: String), Cancelled, Error(error: NSError?)
}

class GoogleLoginHelper: NSObject, GIDSignInDelegate {

    private var googleSignInCompletion: ((result: GoogleSignInResult) -> ())?
    private var tracker: Tracker
    private var loginSource: EventParameterLoginSourceValue
    private var sessionManager: SessionManager
    
    
    // MARK: - Inits
    
    convenience init(loginSource: EventParameterLoginSourceValue) {
        let tracker = TrackerProxy.sharedInstance
        self.init(tracker: tracker, loginSource: loginSource)
    }
    
    init(tracker: Tracker, loginSource: EventParameterLoginSourceValue) {
        self.tracker = tracker
        self.loginSource = loginSource
        self.sessionManager = Core.sessionManager
    }

    func googleSignIn(googleSignInCompletion: (result: GoogleSignInResult) -> Void) {
        self.googleSignInCompletion = googleSignInCompletion
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().scopes =
            ["https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo.profile"]
        GIDSignIn.sharedInstance().serverClientID = EnvironmentProxy.sharedInstance.googleServerClientID
        GIDSignIn.sharedInstance().clientID = EnvironmentProxy.sharedInstance.googleClientID
        GIDSignIn.sharedInstance().signIn()
    }

    func login(authCompletion: (() -> Void)?, loginCompletion: GoogleLoginCompletion) {
        googleSignIn { [weak self] result in
                switch result {
                case let .Success(serverAuthCode):
                    authCompletion?()
                    self?.sessionManager.loginGoogle(serverAuthCode) { [weak self] result in
                        if let myUser = result.value {
                            if let loginSource = self?.loginSource {
                                let trackerEvent = TrackerEvent.loginGoogle(loginSource)
                                self?.tracker.trackEvent(trackerEvent)
                            }
                            loginCompletion?(result: .Success(myUser: myUser))
                        } else if let error = result.error {
                            loginCompletion?(result: ExternalServiceAuthResult(sessionError: error))
                        }
                    }
                case .Cancelled:
                    loginCompletion?(result: .Cancelled)
                case .Error:
                    loginCompletion?(result: .Internal(description: "Google SDK error"))
                }
        }
    }
    
    
    // MARK: GIDSignInDelegate
    
    @objc func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        // Need to be implemented by the protocol
    }
    
    @objc func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let serverAuthCode = user?.serverAuthCode {
            googleSignInCompletion?(result: .Success(serverAuthCode:serverAuthCode))
        } else if let loginError = error where loginError.code == -5 {
            googleSignInCompletion?(result: .Cancelled)
        } else {
            googleSignInCompletion?(result: .Error(error: error))
        }
    }
}
