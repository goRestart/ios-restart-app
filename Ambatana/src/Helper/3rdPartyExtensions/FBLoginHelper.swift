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

enum FBConnectResult {
    case Success(token: String), Cancelled, Error(error: NSError?)
}

class FBLoginHelper {

    private static let fbPermissions = ["email", "public_profile", "user_friends", "user_birthday", "user_likes"]

    static func connectWithFacebook(completion: (result: FBConnectResult) -> Void) {

        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        loginManager.logInWithReadPermissions(fbPermissions, fromViewController: nil) {
            (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if let result = result {
                if let token = result.token?.tokenString {
                    completion(result: .Success(token: token))
                } else if result.isCancelled {
                    completion(result: .Cancelled)
                } else {
                    completion(result: .Error(error: error))
                }
            } else {
                completion(result: .Error(error: error))
            }
        }
    }

    static func logInWithFacebook(sessionManager: SessionManager, tracker: Tracker,
        loginSource: EventParameterLoginSourceValue, managerStart: (()->())?,
        completion: FBLoginCompletion) {

        connectWithFacebook { result in
            switch result {
            case let .Success(token):
                managerStart?()
                loginToManagerWith(token, sessionManager: sessionManager, tracker: tracker, loginSource: loginSource,
                    completion: completion)
            case .Cancelled:
                completion?(result: .Cancelled)
            case .Error:
                completion?(result: .Internal(description: "FB SDK error"))
            }
        }
    }

    private static func loginToManagerWith(token: String, sessionManager: SessionManager,
        tracker: Tracker, loginSource: EventParameterLoginSourceValue, completion: FBLoginCompletion) {
            sessionManager.loginFacebook(token) { result in
                if let myUser = result.value {
                    let trackerEvent = TrackerEvent.loginFB(loginSource)
                    tracker.trackEvent(trackerEvent)
                    callCompletion(completion, withResult: .Success(myUser: myUser))
                } else if let error = result.error {
                    // If session managers fails we should FB logout to clear the fb token
                    let loginManager = FBSDKLoginManager()
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
