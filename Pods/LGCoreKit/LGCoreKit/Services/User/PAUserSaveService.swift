//
//  PAUserSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAUserSaveService: UserSaveService {
    
    // MARK: - UserSaveService
    
    public func saveUser(user: User, result: UserSaveServiceResult?) {
        if let parseUser = user as? PFUser {
            parseUser.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                // Success
                if success {
                    result?(Result<User, UserSaveServiceError>.success(user))
                }
                // Error
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        result?(Result<User, UserSaveServiceError>.failure(.Network))
                    case PFErrorCode.ErrorUserEmailTaken.rawValue:
                        result?(Result<User, UserSaveServiceError>.failure(.EmailTaken))
                    default:
                        result?(Result<User, UserSaveServiceError>.failure(.Internal))
                    }
                }
                else {
                    result?(Result<User, UserSaveServiceError>.failure(.Internal))
                }
            }
        }
        else {
            result?(Result<User, UserSaveServiceError>.failure(.Internal))
        }
    }
}


