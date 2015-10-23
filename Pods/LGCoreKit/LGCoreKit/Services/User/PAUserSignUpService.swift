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
    
    // MARK: - UserSignUpService
    
    public func signUpUserWithEmail(email: String, password: String, publicUsername: String, completion: UserSignUpServiceCompletion?) {
        let user = PFUser()
        user.username = email
        user.email = email
        user.password = password
        user.publicUsername = publicUsername
        user.signUpInBackgroundWithBlock( { (success: Bool, error: NSError?) -> Void in
            // Success
            if success {
                completion?(UserSignUpServiceResult(value: Nil()))
            }
            // Error
            else if let actualError = error {
                switch(actualError.code) {
                case PFErrorCode.ErrorConnectionFailed.rawValue:
                    completion?(UserSignUpServiceResult(error: .Network))
                case PFErrorCode.ErrorUsernameMissing.rawValue:
                    completion?(UserSignUpServiceResult(error: .InvalidUsername))
                case PFErrorCode.ErrorUserEmailMissing.rawValue, PFErrorCode.ErrorInvalidEmailAddress.rawValue:
                    completion?(UserSignUpServiceResult(error: .InvalidEmail))
                case PFErrorCode.ErrorUsernameTaken.rawValue, PFErrorCode.ErrorUserEmailTaken.rawValue:
                    completion?(UserSignUpServiceResult(error: .EmailTaken))
                default:
                    completion?(UserSignUpServiceResult(error: .Internal))
                }
            }
            else {
                completion?(UserSignUpServiceResult(error: .Internal))
            }
        })
    }
}