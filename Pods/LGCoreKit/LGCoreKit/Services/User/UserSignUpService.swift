//
//  UserSignUpService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol UserSignUpService {
    
    /**
        Signs up a user.

        :param: email The user's email.
        :param: password The user's password.
        :param: publicUsername The user's public username
        :param: completion The completion closure.
    */
    func signUpUserWithEmail(email: String, password: String, publicUsername: String, completion: UserSignUpCompletion)
}