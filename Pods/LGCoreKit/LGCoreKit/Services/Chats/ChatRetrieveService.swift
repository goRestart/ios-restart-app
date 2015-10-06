//
//  ChatRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ChatRetrieveServiceError: Printable {
    case Network
    case Unauthorized
    case NotFound
    case Internal
    case Forbidden
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Unauthorized:
            return "Unauthorized"
        case NotFound:
            return "NotFound"
        case Internal:
            return "Internal"
        case Forbidden:
            return "Forbidden"
        }
    }
}

public typealias ChatRetrieveServiceResult = (Result<ChatResponse, ChatRetrieveServiceError>) -> Void

public protocol ChatRetrieveService {
    
    /**
        Retrieves a chat of a user.
    
        :param: sessionToken The user session token.
        :param: productId The product id.
        :param: buyerId The user id of the buyer.
        :param: result The completion closure.
    */
    func retrieveChatWithSessionToken(sessionToken: String, productId: String, buyerId: String, result: ChatRetrieveServiceResult?)
}
