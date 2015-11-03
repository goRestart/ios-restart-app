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
    
    public func saveUser(user: MyUser, completion: UserSaveServiceCompletion?) {
        if let parseUser = user as? PFUser {
            parseUser.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                // Success
                if success {
                    completion?(UserSaveServiceResult(value: user))
                }
                // Error
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        completion?(UserSaveServiceResult(error: .Network))
                    case PFErrorCode.ErrorUserEmailTaken.rawValue:
                        completion?(UserSaveServiceResult(error: .EmailTaken))
                    default:
                        completion?(UserSaveServiceResult(error: .Internal))
                    }
                }
                else {
                    completion?(UserSaveServiceResult(error: .Internal))
                }
            }
        }
        else {
            completion?(UserSaveServiceResult(error: .Internal))
        }
    }
}


