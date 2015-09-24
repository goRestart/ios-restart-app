//
//  ChatsUnreadCountRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ChatsUnreadCountRetrieveServiceError: Printable {
    case Network
    case Unauthorized
    case Internal
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Unauthorized:
            return "Unauthorized"
        case Internal:
            return "Internal"
        }
    }
}

public typealias ChatsUnreadCountRetrieveServiceResult = (Result<Int, ChatsUnreadCountRetrieveServiceError>) -> Void

public protocol ChatsUnreadCountRetrieveService {
    
    /**
        Retrieves the unread message count for the current user.
    
        :param: sessionToken The user session token.
        :param: result The completion closure.
    */
    func retrieveUnreadMessageCountWithSessionToken(sessionToken: String, result: ChatsUnreadCountRetrieveServiceResult?)
}