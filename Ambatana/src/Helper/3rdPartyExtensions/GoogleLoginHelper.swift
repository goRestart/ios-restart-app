//
//  GoogleLoginHelper.swift
//  LetGo
//
//  Created by Isaac Roldan on 15/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum GoogleSignInResult {
    case Success(serverAuthCode: String), Cancelled, Error(error: NSError?)
}

class GoogleLoginHelper: NSObject {
    private var googleSignInCompletion: ((result: GoogleSignInResult) -> ())?
    private let tracker: Tracker
    private let loginSource: EventParameterLoginSourceValue
    private let sessionManager: SessionManager
    
    
    // MARK: - Lifecycle
    
    convenience init(loginSource: EventParameterLoginSourceValue) {
        let sessionManager = Core.sessionManager
        let tracker = TrackerProxy.sharedInstance
        self.init(sessionManager: sessionManager, tracker: tracker, loginSource: loginSource)
    }
    
    init(sessionManager: SessionManager, tracker: Tracker, loginSource: EventParameterLoginSourceValue) {
        self.tracker = tracker
        self.loginSource = loginSource
        self.sessionManager = sessionManager
    }
}


// MARK: - Public methods

extension GoogleLoginHelper {
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
}


// MARK: - GIDSignInDelegate

extension GoogleLoginHelper: GIDSignInDelegate {
    @objc func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        // Needs to be implemented by the protocol
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

// MARK: - ExternalAuthHelper

extension GoogleLoginHelper: ExternalAuthHelper {
    func login(authCompletion: (() -> Void)?, loginCompletion: ExternalAuthLoginCompletion?) {
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
                        loginCompletion?(.Success(myUser: myUser))
                    } else if let error = result.error {
                        loginCompletion?(ExternalServiceAuthResult(sessionError: error))
                    }
                }
            case .Cancelled:
                loginCompletion?(.Cancelled)
            case .Error:
                loginCompletion?(.Internal(description: "Google SDK error"))
            }
        }
    }
}
