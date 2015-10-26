//
//  UserRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Result

public enum UserRetrieveServiceError: ErrorType, CustomStringConvertible {
    case Network
    case Internal
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Internal:
            return "Internal"
        }
    }
}

public typealias UserRetrieveServiceResult = Result<User, UserRetrieveServiceError>
public typealias UserRetrieveServiceCompletion = UserRetrieveServiceResult -> Void

public protocol UserRetrieveService {
    
    /**
        Retrieves a user.
    
        - parameter user: The user.
        - parameter completion: The completion closure.
    */
    func retrieveUserWithId(userId: String, completion: UserRetrieveServiceCompletion?)
}

