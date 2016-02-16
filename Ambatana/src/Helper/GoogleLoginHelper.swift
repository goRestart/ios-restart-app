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

class GoogleLoginHelper: GIDSignInDelegate {
    
    static let sharedInstance = GoogleLoginHelper()
    
    let sessionManager: SessionManager
    var loginCompletion: GoogleLoginCompletion
    var authCompletion: (() -> ())?
    
    init() {
        self.sessionManager = Core.sessionManager
    }
    
    func signIn(authCompletion: (() -> ())?, loginCompletion: GoogleLoginCompletion) {
        self.loginCompletion = loginCompletion
        self.authCompletion = authCompletion
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    @objc func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        // Need to be implemented by the protocol
    }
    
    @objc func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let token = user?.authentication.accessToken {
            authCompletion?()
            sessionManager.loginGoogle(token) { [weak self] result in
                if let _ = result.value {
                    self?.loginCompletion?(result: .Success)
                } else if let error = result.error {
                    self?.loginCompletion?(result: ExternalServiceAuthResult(sessionError: error))
                }
            }
        } else if let loginError = error {
            if loginError.code == -5 {
                loginCompletion?(result: .Cancelled)
            } else {
                loginCompletion?(result: .Internal)
            }
        }
    }
}
