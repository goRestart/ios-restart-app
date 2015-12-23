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

    static func logInWithFacebook(sessionManager: SessionManager, start: (() -> ())?,
        finish: ((result: FBLoginResult, user: MyUser?) -> ())?) {

            let loginManager = FBSDKLoginManager()
            loginManager.logInWithReadPermissions(fbPermissions, fromViewController: nil) {
                (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in

                if let _ = error {
                    finish?(result: .Internal, user: nil)
                } else if result.isCancelled {
                    finish?(result: .Cancelled, user: nil)
                } else if let token = result.token?.tokenString {

                    start?()

                    sessionManager.loginFacebook(token) { result in

                        if let myUser = result.value {
                            finish?(result: .Success, user: myUser)
                        } else if let error = result.error{
                            switch (error) {
                            case .Api(let apiError):
                                switch apiError {
                                case .Network:
                                    finish?(result: .Network, user: nil)
                                case .Scammer:
                                    finish?(result: .Forbidden, user: nil)
                                case .NotFound:
                                    finish?(result: .NotFound, user: nil)
                                case .Internal, .Unauthorized, .AlreadyExists, .InternalServerError:
                                    finish?(result: .Internal, user: nil)
                                }
                            case .Internal:
                                finish?(result: .Internal, user: nil)
                            }
                        } else {
                            finish?(result: .Internal, user: nil)
                        }
                    }
                }
            }
    }

}