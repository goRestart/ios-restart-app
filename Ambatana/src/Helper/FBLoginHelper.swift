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
    case Internal
}

class FBLoginHelper {

    static let fbPermissions = ["email", "public_profile", "user_friends", "user_birthday", "user_likes"]

    static func logInWithFacebook(sessionManager: SessionManager, tracker: Tracker,
        loginSource: EventParameterLoginSourceValue, finish: ((result: FBLoginResult) -> ())?) {

            let loginManager = FBSDKLoginManager()
            loginManager.logInWithReadPermissions(fbPermissions, fromViewController: nil) {
                (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in

                if let _ = error {
                    finish?(result: .Internal)
                } else if result.isCancelled {
                    finish?(result: .Cancelled)
                } else if let token = result.token?.tokenString {

                    sessionManager.loginFacebook(token) { result in

                        if let myUser = result.value {
                            tracker.setUser(myUser)
                            let trackerEvent = TrackerEvent.loginFB(loginSource)
                            tracker.trackEvent(trackerEvent)

                            finish?(result: .Success)
                        } else if let error = result.error{
                            switch (error) {
                            case .Api(let apiError):
                                switch apiError {
                                case .Network:
                                    finish?(result: .Network)
                                case .Scammer:
                                    finish?(result: .Forbidden)
                                case .NotFound:
                                    finish?(result: .NotFound)
                                case .Internal, .Unauthorized, .AlreadyExists, .InternalServerError:
                                    finish?(result: .Internal)
                                }
                            case .Internal:
                                finish?(result: .Internal)
                            }
                        } else {
                            finish?(result: .Internal)
                        }
                    }
                }
            }
    }

}