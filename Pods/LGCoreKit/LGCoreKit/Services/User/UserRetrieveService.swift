//
//  UserRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Result

public enum UserRetrieveServiceError: Printable {
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

public typealias UserRetrieveServiceResult = (Result<User, UserRetrieveServiceError>) -> Void

public protocol UserRetrieveService {
    
    /**
        Retrieves a user.
    
        :param: user The user.
        :param: completion The completion closure.
    */
    func retrieveUserWithId(userId: String, result: UserRetrieveServiceResult?)
}

