//
//  ChatsUnreadCountRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ChatsUnreadCountRetrieveServiceError: ErrorType, CustomStringConvertible {
    case Network
    case Unauthorized
    case Internal
    case Forbidden
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Unauthorized:
            return "Unauthorized"
        case Internal:
            return "Internal"
        case Forbidden:
            return "Forbidden"
        }
    }
    
    init(apiError: ApiError) {
        switch apiError {
        case .Network:
            self = .Network
        case .Scammer:
            self = .Forbidden
        case .Internal, .Unauthorized, .NotFound, .AlreadyExists, .InternalServerError:
            self = .Internal
        }
    }
}

public typealias ChatsUnreadCountRetrieveServiceResult = Result<Int, ChatsUnreadCountRetrieveServiceError>
public typealias ChatsUnreadCountRetrieveServiceCompletion = ChatsUnreadCountRetrieveServiceResult -> Void

public protocol ChatsUnreadCountRetrieveService {
    
    /**
        Retrieves the unread message count for the current user.
    
        - parameter sessionToken: The user session token.
        - parameter completion: The completion closure.
    */
    func retrieveUnreadMessageCountWithSessionToken(sessionToken: String, completion: ChatsUnreadCountRetrieveServiceCompletion?)
}