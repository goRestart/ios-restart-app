//
//  PAUserPasswordResetService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 17/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAUserPasswordResetService: UserPasswordResetService {
    
    // MARK: - UserPasswordResetService
    
    public func resetPassword(email: String, completion: UserPasswordResetServiceCompletion?) {
        PFUser.requestPasswordResetForEmailInBackground(email, block: { (success, error) -> Void in
            // Success
            if success {
                completion?(UserPasswordResetServiceResult(value: Nil()))
            }
            // Error
            else if let actualError = error {
                switch(actualError.code) {
                case PFErrorCode.ErrorConnectionFailed.rawValue:
                    completion?(UserPasswordResetServiceResult(error: .Network))
                case PFErrorCode.ErrorUserWithEmailNotFound.rawValue:
                    completion?(UserPasswordResetServiceResult(error: .UserNotFound))
                case PFErrorCode.ErrorUserEmailMissing.rawValue, PFErrorCode.ErrorInvalidEmailAddress.rawValue:
                    completion?(UserPasswordResetServiceResult(error: .InvalidEmail))
                default:
                    completion?(UserPasswordResetServiceResult(error: .Internal))
                }
            }
            else {
                completion?(UserPasswordResetServiceResult(error: .Network))
            }
        })
    }
}