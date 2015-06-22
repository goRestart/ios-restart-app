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
    
    public func resetPassword(email: String, result: UserPasswordResetServiceResult?) {
        PFUser.requestPasswordResetForEmailInBackground(email, block: { (success, error) -> Void in
            // Success
            if success {
                result?(Result<Nil, UserPasswordResetServiceError>.success(Nil()))
            }
                // Error
            else if let actualError = error {
                kPFParseServer
                switch(actualError.code) {
                case PFErrorCode.ErrorConnectionFailed.rawValue:
                    result?(Result<Nil, UserPasswordResetServiceError>.failure(.Network))
                case PFErrorCode.ErrorUserWithEmailNotFound.rawValue:
                    result?(Result<Nil, UserPasswordResetServiceError>.failure(.UserNotFound))
                case PFErrorCode.ErrorUserEmailMissing.rawValue, PFErrorCode.ErrorInvalidEmailAddress.rawValue:
                    result?(Result<Nil, UserPasswordResetServiceError>.failure(.InvalidEmail))
                default:
                    result?(Result<Nil, UserPasswordResetServiceError>.failure(.Internal))
                }
            }
            else {
                result?(Result<Nil, UserPasswordResetServiceError>.failure(.Network))
            }
        })
    }
}