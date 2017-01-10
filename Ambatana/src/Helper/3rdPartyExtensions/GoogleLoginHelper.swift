
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
    fileprivate var googleSignInCompletion: ExternalAuthTokenRetrievalCompletion?
    fileprivate let sessionManager: SessionManager
    
    
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
    func googleSignIn(_ googleSignInCompletion: @escaping ExternalAuthTokenRetrievalCompletion) {
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
    @objc func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: NSError!) {
        // Needs to be implemented by the protocol
    }

    @objc func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let serverAuthCode = user?.serverAuthCode {
            googleSignInCompletion?(.success(serverAuthCode:serverAuthCode))
        } else if let loginError = error, loginError.code == -5 {
            googleSignInCompletion?(.cancelled)
        } else {
            googleSignInCompletion?(.error(error: error))
        }
    }
}

// MARK: - ExternalAuthHelper

extension GoogleLoginHelper: ExternalAuthHelper {
    func login(_ authCompletion: (() -> Void)?, loginCompletion: ExternalAuthLoginCompletion?) {
        googleSignIn { [weak self] result in
            switch result {
            case let .success(serverAuthCode):
                authCompletion?()
                self?.sessionManager.loginGoogle(serverAuthCode) { result in
                    if let myUser = result.value {
                        loginCompletion?(.success(myUser: myUser))
                    } else if let error = result.error {
                        loginCompletion?(ExternalServiceAuthResult(sessionError: error))
                    }
                }
            case .cancelled:
                loginCompletion?(.cancelled)
            case .error:
                loginCompletion?(.internalError(description: "Google SDK error"))
            }
        }
    }
}
