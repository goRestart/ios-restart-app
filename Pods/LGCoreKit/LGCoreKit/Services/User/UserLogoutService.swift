//
//  UserLogOutService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum UserLogOutServiceError: ErrorType {
    case Internal
}

public typealias UserLogOutServiceResult = Result<Nil, UserLogOutServiceError>
public typealias UserLogOutServiceCompletion = UserLogOutServiceResult -> Void

public protocol UserLogOutService {
    
    /**
        Logs out a user.
    
        - parameter user: The user.
        - parameter completion: The completion closure.
    */
    func logOutUser(user: User, completion: UserLogOutServiceCompletion?)
}