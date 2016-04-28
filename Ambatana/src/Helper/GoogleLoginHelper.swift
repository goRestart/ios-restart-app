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


class GoogleLoginHelper: NSObject, GIDSignInDelegate {
    
    let googleServerClientID = "914431496661-7s28hvdioe432kpco4lvh53frmkqlllv.apps.googleusercontent.com"
    var loginCompletion: GoogleLoginCompletion
    var authCompletion: (() -> ())?
    var tracker: Tracker
    var loginSource: EventParameterLoginSourceValue
    var sessionManager: SessionManager
    
    
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
    
    func signIn(authCompletion: (() -> ())?, loginCompletion: GoogleLoginCompletion) {
        self.loginCompletion = loginCompletion
        self.authCompletion = authCompletion
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().scopes =
            ["https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo.profile"]
        GIDSignIn.sharedInstance().serverClientID = googleServerClientID
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    // MARK: GIDSignInDelegate
    
    @objc func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        // Need to be implemented by the protocol
    }
    
    @objc func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let serverAuthCode = user?.serverAuthCode {
            authCompletion?()
            sessionManager.loginGoogle(serverAuthCode) { [weak self] result in
                if let _ = result.value {
                    if let loginSource = self?.loginSource {
                        let trackerEvent = TrackerEvent.loginGoogle(loginSource)
                        self?.tracker.trackEvent(trackerEvent)
                    }
                    self?.loginCompletion?(result: .Success)
                } else if let error = result.error {
                    self?.loginCompletion?(result: ExternalServiceAuthResult(sessionError: error))
                }
            }
        } else if let loginError = error where loginError.code == -5 {
            loginCompletion?(result: .Cancelled)
        } else {
            loginCompletion?(result: .Internal)
        }
    }
}
