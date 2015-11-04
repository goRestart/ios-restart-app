//
//  UserLogInFBService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum UserLogInFBServiceError: ErrorType {
    case Cancelled
    case Forbidden
    case Internal
}

public typealias UserLogInFBServiceResult = Result<MyUser, UserLogInFBServiceError>
public typealias UserLogInFBServiceCompletion = UserLogInFBServiceResult -> Void

public protocol UserLogInFBService {
    
    /**
        Logs in / signs up a user via Facebook.
    
        - parameter result: The completion closure.
    */
    func logInByFacebooWithCompletion(completion: UserLogInFBServiceCompletion?)
}