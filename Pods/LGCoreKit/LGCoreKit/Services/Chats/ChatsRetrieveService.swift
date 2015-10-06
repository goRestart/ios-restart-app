//
//  ChatsRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ChatsRetrieveServiceError: Printable {
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
}

public typealias ChatsRetrieveServiceResult = (Result<ChatsResponse, ChatsRetrieveServiceError>) -> Void

public protocol ChatsRetrieveService {
    
    /**
        Retrieves the chats of a user.
    
        :param: sessionToken The user session token.
        :param: result The completion closure.
    */
    func retrieveChatsWithSessionToken(sessionToken: String, result: ChatsRetrieveServiceResult?)
}
