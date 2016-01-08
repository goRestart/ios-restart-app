//
//  ChatsRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ChatsRetrieveServiceError: ErrorType, CustomStringConvertible {
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

public typealias ChatsRetrieveServiceResult = Result<ChatsResponse, ChatsRetrieveServiceError>
public typealias ChatsRetrieveServiceCompletion = ChatsRetrieveServiceResult -> Void

public protocol ChatsRetrieveService {

    /**
        Retrieves the chats of a user.

        - parameter sessionToken: The user session token.
        - parameter completion: The completion closure.
    */
    func retrieveChatsWithSessionToken(sessionToken: String, completion: ChatsRetrieveServiceCompletion?)
}
