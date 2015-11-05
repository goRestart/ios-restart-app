//
//  PAUserLoginEmailService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAUserLogInEmailService: UserLogInEmailService {

    // MARK: - UserLogInEmailService
    
    public func logInUserWithEmail(email: String, password: String, completion: UserLogInEmailServiceCompletion?) {
        PFUser.logInWithUsernameInBackground(email, password: password)  { (user: PFUser?, error: NSError?) -> Void in
            // Success
            if let actualUser = user {
                completion?(UserLogInEmailServiceResult(value: actualUser))
            }
            // Error
            else if let actualError = error {
                switch(actualError.code) {
                case PFErrorCode.ErrorConnectionFailed.rawValue:
                    completion?(UserLogInEmailServiceResult(error: .Network))
                case PFErrorCode.ErrorInvalidEmailAddress.rawValue:
                    completion?(UserLogInEmailServiceResult(error: .InvalidEmail))
                case PFErrorCode.ErrorObjectNotFound.rawValue:
                    completion?(UserLogInEmailServiceResult(error: .UserNotFoundOrWrongPassword))
                default:
                    completion?(UserLogInEmailServiceResult(error: .Internal))
                }
            }
            else {
                completion?(UserLogInEmailServiceResult(error: .Internal))
            }
        }
    }
}
