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
    
    public func logInByFacebooWithCompletion(result: UserLogInFBServiceResult) {

        let permissions = ["user_about_me", "user_location", "email", "public_profile"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: { (user: PFUser?, error: NSError?) -> Void in
            // Success
            if let actualUser = user as? User {
                result(Result<User, UserLogInFBServiceError>.success(actualUser))
            }
            // Error
            else if let actualError = error {
                result(Result<User, UserLogInFBServiceError>.failure(.Cancelled))
            }
            else {
                result(Result<User, UserLogInFBServiceError>.failure(.Internal))
            }
        })
    }
}