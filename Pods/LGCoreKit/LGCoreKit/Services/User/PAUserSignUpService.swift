//
//  PAUserSignUpService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

final public class PAUserSignUpService: UserSignUpService {
    
    public func signUpUserWithEmail(email: String, password: String, publicUsername: String, completion: UserSignUpCompletion) {
        let user = PFUser()
        user.username = email
        user.email = email
        user.password = password
        user.publicUsername = publicUsername
        user.signUpInBackgroundWithBlock( { (success: Bool, error: NSError?) -> Void in
            completion(success: success, error: error)
        })
    }
}