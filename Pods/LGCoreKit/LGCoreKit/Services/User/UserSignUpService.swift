//
//  UserSignUpService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum UserSignUpServiceError {
    case Network
    case InvalidUsername, InvalidEmail, InvalidPassword
    case EmailTaken
    case Internal
}

public typealias UserSignUpServiceResult = (Result<Nil, UserSignUpServiceError>) -> Void

/**
    User sign up service.
*/
public protocol UserSignUpService {
    
    /**
        Signs up a user.

        :param: email The user's email.
        :param: password The user's password.
        :param: publicUsername The user's public username
        :param: result The closure containing the result.
    */
    func signUpUserWithEmail(email: String, password: String, publicUsername: String, result: UserSignUpServiceResult?)
}