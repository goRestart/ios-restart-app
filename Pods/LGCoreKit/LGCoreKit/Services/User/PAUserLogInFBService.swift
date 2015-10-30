//
//  PAUserLogInFBService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import ParseFacebookUtilsV4
import Parse
import Result

final public class PAUserLogInFBService: UserLogInFBService {
    
    // MARK: - UserLogInEmailService
    
    public func logInByFacebooWithCompletion(completion: UserLogInFBServiceCompletion?) {

        let permissions = ["email", "public_profile", "user_friends"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: { (user: PFUser?, error: NSError?) -> Void in
            // Success
            if let actualUser = user as? User {
                completion?(UserLogInFBServiceResult(value: actualUser))
            }
            // Error
            else if let _ = error {
                completion?(UserLogInFBServiceResult(error: .Internal))
            }
            else {
                completion?(UserLogInFBServiceResult(error: .Cancelled))
            }
        })
    }
}