//
//  FBLoginHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 23/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import FBSDKLoginKit
import LGCoreKit

typealias FBLoginCompletion = ((result: ExternalServiceAuthResult) -> ())?

class FBLoginHelper {

    static let fbPermissions = ["email", "public_profile", "user_friends", "user_birthday", "user_likes"]

    static func logInWithFacebook(sessionManager: SessionManager, tracker: Tracker,
        loginSource: EventParameterLoginSourceValue, managerStart: (()->())?,
        completion: FBLoginCompletion) {

            let loginManager = FBSDKLoginManager()
            // Clear the fb token
            loginManager.logOut()
            loginManager.logInWithReadPermissions(fbPermissions, fromViewController: nil) {
                (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in

                if let _ = error {
                    completion?(result: .Internal)
                } else if result.isCancelled {
                    completion?(result: .Cancelled)
                } else if let token = result.token?.tokenString {
                    managerStart?()
                    loginToManagerWith(token, sessionManager: sessionManager, loginManager: loginManager,
                        tracker: tracker, loginSource: loginSource, completion: completion)
                }
            }
    }

    private static func loginToManagerWith(token: String, sessionManager: SessionManager,
        loginManager: FBSDKLoginManager, tracker: Tracker, loginSource: EventParameterLoginSourceValue,
        completion: FBLoginCompletion) {
            sessionManager.loginFacebook(token) { result in
                if let _ = result.value {
                    let trackerEvent = TrackerEvent.loginFB(loginSource)
                    tracker.trackEvent(trackerEvent)
                    callCompletion(completion, withResult: .Success)
                } else if let error = result.error {
                    // If session managers fails we should FB logout to clear the fb token
                    loginManager.logOut()
                    callCompletion(completion, withResult: ExternalServiceAuthResult(sessionError: error))
                }
            }
    }
    
    private static func callCompletion(completion: FBLoginCompletion, withResult result : ExternalServiceAuthResult) {
        /*TODO: Adding delay just because ios queues loading alert while fb is dismissng. this is
         to avoid loading being hang up forever*/
        delay(0.8) {
            completion?(result: result)
        }
    }
}