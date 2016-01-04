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
            loginManager.logInWithReadPermissions(fbPermissions, fromViewController: nil) {
                (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in

                if let _ = error {
                    completion?(result: .Internal)
                } else if result.isCancelled {
                    completion?(result: .Cancelled)
                } else if let token = result.token?.tokenString {
                    managerStart?()
                    loginToManagerWith(token, sessionManager: sessionManager, tracker: tracker,
                        loginSource: loginSource, completion: completion)
                }
            }
    }

    private static func loginToManagerWith(token: String, sessionManager: SessionManager, tracker: Tracker,
        loginSource: EventParameterLoginSourceValue, completion: ((result: FBLoginResult) -> ())?) {
            sessionManager.loginFacebook(token) { result in
                if let myUser = result.value {
                    tracker.setUser(myUser)
                    let trackerEvent = TrackerEvent.loginFB(loginSource)
                    tracker.trackEvent(trackerEvent)

                    completion?(result: .Success)
                } else if let error = result.error{
                    switch (error) {
                    case .Api(let apiError):
                        switch apiError {
                        case .Network:
                            completion?(result: .Network)
                        case .Scammer:
                            completion?(result: .Forbidden)
                        case .NotFound:
                            completion?(result: .NotFound)
                        case .AlreadyExists:
                            completion?(result: .AlreadyExists)
                        case .Internal, .Unauthorized, .InternalServerError:
                            completion?(result: .Internal)
                        }
                    case .Internal:
                        completion?(result: .Internal)
                    }
                } else {
                    completion?(result: .Internal)
                }
            }
    }

}