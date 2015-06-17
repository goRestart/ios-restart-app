//
//  UserLogInFBService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum UserLogInFBServiceError {
    case Cancelled
    case Internal
}

public typealias UserLogInFBServiceResult = (Result<User, UserLogInFBServiceError>) -> Void

public protocol UserLogInFBService {
    
    /**
        Logs in / signs up a user via Facebook.
    
        :param: result The closure containing the result.
    */
    func logInByFacebooWithCompletion(result: UserLogInFBServiceResult)
}