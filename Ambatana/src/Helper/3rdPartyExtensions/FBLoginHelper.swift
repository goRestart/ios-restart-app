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
    func connectWithFacebook(_ completion: @escaping ExternalAuthTokenRetrievalCompletion) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        loginManager.logIn(withReadPermissions: FBLoginHelper.fbPermissions, from: nil) {
            (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if let result = result {
                if let token = result.token?.tokenString {
                    completion(.success(serverAuthCode: token))
                } else if result.isCancelled {
                    completion(.cancelled)
                } else {
                    completion(.error(error: error))
                }
            } else {
                completion(.error(error: error))
            }
        }
    }
}


// MARK: - ExternalAuthHelper

extension FBLoginHelper: ExternalAuthHelper {
    func login(_ authCompletion: (() -> Void)?, loginCompletion: ExternalAuthLoginCompletion?) {
        connectWithFacebook { [weak self] fbResult in
            switch fbResult {
            case let .success(token):
                authCompletion?()
                self?.sessionManager.loginFacebook(token, completion: { result in
                    if let myUser = result.value {
                        loginCompletion?(.Success(myUser: myUser))
                    } else if let error = result.error {
                        loginCompletion?(ExternalServiceAuthResult(sessionError: error))
                    }
                })
            case .cancelled:
                loginCompletion?(.cancelled)
            case .error:
                loginCompletion?(.internal(description: "FB SDK error"))
            }
        }
    }
}
