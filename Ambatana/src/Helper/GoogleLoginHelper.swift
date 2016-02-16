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
    var completion: GoogleLoginCompletion
    
    init() {
        self.sessionManager = Core.sessionManager
    }
    
    func signIn(completion: GoogleLoginCompletion) {
        self.completion = completion
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    @objc func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        // Need to be implemented by the protocol
    }
    
    @objc func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let token = user.authentication.idToken {
            sessionManager.loginGoogle(token) { [weak self] result in
                if let _ = result.value {
                    self?.completion?(result: .Success)
                } else if let error = result.error {
                    self?.completion?(result: ExternalServiceAuthResult(sessionError: error))
                }
            }
        } else if let _ = error {
            completion?(result: .Internal)
        }
    }
}
