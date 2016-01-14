//
//  FBLoginHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 23/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import FBSDKLoginKit
import LGCoreKit

enum FBLoginResult {
    case Success
    case Cancelled
    case Network
    case Forbidden
    case NotFound
    case AlreadyExists
    case Internal
}

class FBLoginHelper {

    static let fbPermissions = ["email", "public_profile", "user_friends", "user_birthday", "user_likes"]

    static func logInWithFacebook(sessionManager: SessionManager, tracker: Tracker,
        loginSource: EventParameterLoginSourceValue, managerStart: (()->())?,
        completion: ((result: FBLoginResult) -> ())?) {

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
        completion: ((result: FBLoginResult) -> ())?) {
            sessionManager.loginFacebook(token) { result in
                if let myUser = result.value {
                    tracker.setUser(myUser)
                    let trackerEvent = TrackerEvent.loginFB(loginSource)
                    tracker.trackEvent(trackerEvent)

                    callCompletion(completion, withResult: .Success)
                } else if let error = result.error {
                    // If session managers fails we should FB logout to clear the fb token
                    loginManager.logOut()
                    switch (error) {
                    case .Network:
                        callCompletion(completion, withResult: .Network)
                    case .Scammer:
                        callCompletion(completion, withResult: .Forbidden)
                    case .NotFound:
                        callCompletion(completion, withResult: .NotFound)
                    case .AlreadyExists:
                        callCompletion(completion, withResult: .AlreadyExists)
                    case .Internal, .Unauthorized:
                        callCompletion(completion, withResult: .Internal)
                    }
                } else {
                    // If session managers fails we should FB logout to clear the fb token
                    loginManager.logOut()
                    callCompletion(completion, withResult: .Internal)
                }
            }
    }
    
    private static func callCompletion(completion: ((result: FBLoginResult) -> ())?,
        withResult result : FBLoginResult) {
            /*TODO: Adding delay just because ios queues loading alert while fb is dismissng. this is
            to avoid loading being hang up forever*/
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                completion?(result: result)
            }
    }
}