//
//  FBLoginHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 23/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import FBSDKLoginKit
import LGCoreKit

class FBLoginHelper {
    private static let fbPermissions = ["email", "public_profile", "user_friends", "user_birthday", "user_likes"]

    private let sessionManager: SessionManager


    // MARK: - Lifecycle

    convenience init() {
        let sessionManager = Core.sessionManager
        self.init(sessionManager: sessionManager)
    }

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
}


// MARK: - Public methods

extension FBLoginHelper {
    func connectWithFacebook(completion: ExternalAuthTokenRetrievalCompletion) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        loginManager.logInWithReadPermissions(FBLoginHelper.fbPermissions, fromViewController: nil) {
            (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if let result = result {
                if let token = result.token?.tokenString {
                    completion(.Success(serverAuthCode: token))
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
