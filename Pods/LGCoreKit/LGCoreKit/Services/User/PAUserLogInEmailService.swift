//
//  PAUserLoginEmailService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

final public class PAUserLogInEmailService: UserLogInEmailService {

    public func logInUserWithEmail(email: String, password: String, completion: UserLogInCompletion) {
        PFUser.logInWithUsernameInBackground(email, password: password)  { (user: PFUser?, error: NSError?) -> Void in
            if let actualError = error {
                completion(user: nil, error: error)
            }
            else if let actualUser = user as? User {
                completion(user: actualUser, error: nil)
            }
            else {
                completion(user: nil, error: NSError(code: LGErrorCode.Internal))
            }
        }
    }
}
