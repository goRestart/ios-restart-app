
//
//  GoogleLoginHelper.swift
//  LetGo
//
//  Created by Isaac Roldan on 15/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class GoogleLoginHelper: NSObject {
    private var googleSignInCompletion: ExternalAuthTokenRetrievalCompletion?
    private let sessionManager: SessionManager
    
    
    // MARK: - Lifecycle

    convenience override init() {
        let sessionManager = Core.sessionManager
        self.init(sessionManager: sessionManager)
    }
    
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
}


// MARK: - Public methods

extension GoogleLoginHelper {
    func googleSignIn(googleSignInCompletion: ExternalAuthTokenRetrievalCompletion) {
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
            googleSignInCompletion?(.Success(serverAuthCode:serverAuthCode))
        } else if let loginError = error where loginError.code == -5 {
            googleSignInCompletion?(.Cancelled)
        } else {
            googleSignInCompletion?(.Error(error: error))
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
                self?.sessionManager.loginGoogle(serverAuthCode) { result in
                    if let myUser = result.value {
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
