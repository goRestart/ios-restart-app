//
//  UserLogInEmailService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum UserLogInEmailServiceError: ErrorType {
    case Network
    case InvalidEmail
    case InvalidPassword
    case UserNotFoundOrWrongPassword
    case Forbidden
    case Internal
}

public typealias UserLogInEmailServiceResult = Result<User, UserLogInEmailServiceError>
public typealias UserLogInEmailServiceCompletion = UserLogInEmailServiceResult -> Void

public protocol UserLogInEmailService {
    
    /**
        Logs in a user using email & password.
    
        - parameter email: The user's email.
        - parameter password: The user's password.
        - parameter completion: The completion closure.
    */
    func logInUserWithEmail(email: String, password: String, completion: UserLogInEmailServiceCompletion?)
}
