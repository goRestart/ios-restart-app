//
//  UserLogInEmailService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol UserLogInEmailService {
    
    /**
        Logs in a user using email & password.
    
        :param: email The user's email.
        :param: password The user's password.
        :param: completion The completion closure.
    */
    func logInUserWithEmail(email: String, password: String, completion: UserLogInCompletion)
}
