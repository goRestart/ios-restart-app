//
//  FBLoginHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 23/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import FBSDKLoginKit
import LGCoreKit

enum FBConnectResult {
    case Success(token: String), Cancelled, Error(error: NSError?)
}

class FBLoginHelper {
    private static let fbPermissions = ["email", "public_profile", "user_friends", "user_birthday", "user_likes"]

    private let tracker: Tracker
    private let loginSource: EventParameterLoginSourceValue
    private let sessionManager: SessionManager


    // MARK: - Lifecycle

    convenience init(loginSource: EventParameterLoginSourceValue) {
        let sessionManager = Core.sessionManager
        let tracker = TrackerProxy.sharedInstance
        self.init(sessionManager: sessionManager, tracker: tracker, loginSource: loginSource)
    }

    init(sessionManager: SessionManager, tracker: Tracker, loginSource: EventParameterLoginSourceValue) {
        self.tracker = tracker
        self.loginSource = loginSource
        self.sessionManager = sessionManager
    }
}


// MARK: - Public methods

extension FBLoginHelper {
    func connectWithFacebook(completion: FBConnectResult -> ()) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        loginManager.logInWithReadPermissions(FBLoginHelper.fbPermissions, fromViewController: nil) {
            (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if let result = result {
                if let token = result.token?.tokenString {
                    completion(.Success(token: token))
                } else if result.isCancelled {
                    completion(.Cancelled)
                } else {
                    completion(.Error(error: error))
                }
            } else {
                completion(.Error(error: error))
            }
        }
    }
}


// MARK: - ExternalAuthHelper

extension FBLoginHelper: ExternalAuthHelper {
    func login(authCompletion: (() -> Void)?, loginCompletion: ExternalAuthLoginCompletion?) {
        connectWithFacebook { [weak self] fbResult in
            switch fbResult {
            case let .Success(token):
                authCompletion?()
                self?.sessionManager.loginFacebook(token, completion: { result in
                    if let myUser = result.value {
                        if let loginSource = self?.loginSource {
                            let trackerEvent = TrackerEvent.loginFB(loginSource)
                            self?.tracker.trackEvent(trackerEvent)
                        }
                        loginCompletion?(.Success(myUser: myUser))
                    } else if let error = result.error {
                        loginCompletion?(ExternalServiceAuthResult(sessionError: error))
                    }
                })
            case .Cancelled:
                loginCompletion?(.Cancelled)
            case .Error:
                loginCompletion?(.Internal(description: "FB SDK error"))
            }
        }
    }
}
