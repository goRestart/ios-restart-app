//
//  UserSignUpService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum UserSignUpServiceError: ErrorType {
    case Network
    case InvalidUsername, InvalidEmail, InvalidPassword
    case EmailTaken
    case UsernameTaken
    case Internal
}

public typealias UserSignUpServiceResult = Result<MyUser, UserSignUpServiceError>
public typealias UserSignUpServiceCompletion =  UserSignUpServiceResult -> Void
/**
    User sign up service.
*/
public protocol UserSignUpService {
    
    /**
        Signs up a user.

        - parameter email: The user's email.
        - parameter password: The user's password.
        - parameter publicUsername: The user's public username
        - parameter completion: The completion closure.
    */
    func signUpUserWithEmail(email: String, password: String, publicUsername: String, completion: UserSignUpServiceCompletion?)
}