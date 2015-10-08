//
//  UserLogInEmailService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum UserLogInEmailServiceError {
    case Network
    case InvalidEmail
    case InvalidPassword
    case UserNotFoundOrWrongPassword
    case Forbidden
    case Internal
}

public typealias UserLogInEmailServiceResult = (Result<User, UserLogInEmailServiceError>) -> Void

public protocol UserLogInEmailService {
    
    /**
        Logs in a user using email & password.
    
        :param: email The user's email.
        :param: password The user's password.
        :param: result The closure containing the result.
    */
    func logInUserWithEmail(email: String, password: String, result: UserLogInEmailServiceResult?)
}
