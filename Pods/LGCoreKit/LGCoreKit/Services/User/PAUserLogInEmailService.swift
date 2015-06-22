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

    public func logInUserWithEmail(email: String, password: String, result: UserLogInEmailServiceResult?) {
        PFUser.logInWithUsernameInBackground(email, password: password)  { (user: PFUser?, error: NSError?) -> Void in
            // Success
            if let actualUser = user as? User {
                result?(Result<User, UserLogInEmailServiceError>.success(actualUser))
            }
            // Error
            else if let actualError = error {
                switch(actualError.code) {
                case PFErrorCode.ErrorConnectionFailed.rawValue:
                    result?(Result<User, UserLogInEmailServiceError>.failure(.Network))
                case PFErrorCode.ErrorInvalidEmailAddress.rawValue:
                    result?(Result<User, UserLogInEmailServiceError>.failure(.InvalidEmail))
                case PFErrorCode.ErrorObjectNotFound.rawValue:
                    result?(Result<User, UserLogInEmailServiceError>.failure(.UserNotFoundOrWrongPassword))
                default:
                    result?(Result<User, UserLogInEmailServiceError>.failure(.Internal))
                }
            }
            else {
                result?(Result<User, UserLogInEmailServiceError>.failure(.Internal))
            }
        }
    }
}
