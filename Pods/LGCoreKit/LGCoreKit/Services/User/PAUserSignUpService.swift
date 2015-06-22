//
//  PAUserSignUpService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAUserSignUpService: UserSignUpService {
    
    public func signUpUserWithEmail(email: String, password: String, publicUsername: String, result: UserSignUpServiceResult?) {
        let user = PFUser()
        user.username = email
        user.email = email
        user.password = password
        user.publicUsername = publicUsername
        user.signUpInBackgroundWithBlock( { (success: Bool, error: NSError?) -> Void in
            // Success
            if success {
                result?(Result<Nil, UserSignUpServiceError>.success(Nil()))
            }
            // Error
            else if let actualError = error {
                switch(actualError.code) {
                case PFErrorCode.ErrorConnectionFailed.rawValue:
                    result?(Result<Nil, UserSignUpServiceError>.failure(.Network))
                case PFErrorCode.ErrorUsernameMissing.rawValue:
                    result?(Result<Nil, UserSignUpServiceError>.failure(.InvalidUsername))
                case PFErrorCode.ErrorUserEmailMissing.rawValue, PFErrorCode.ErrorInvalidEmailAddress.rawValue:
                    result?(Result<Nil, UserSignUpServiceError>.failure(.InvalidEmail))
                case PFErrorCode.ErrorUsernameTaken.rawValue, PFErrorCode.ErrorUserEmailTaken.rawValue:
                    result?(Result<Nil, UserSignUpServiceError>.failure(.EmailTaken))
                default:
                    result?(Result<Nil, UserSignUpServiceError>.failure(.Internal))
                }
            }
            else {
                result?(Result<Nil, UserSignUpServiceError>.failure(.Internal))
            }
        })
    }
}