//
//  ChatRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ChatRetrieveServiceError: ErrorType, CustomStringConvertible {
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

public typealias ChatRetrieveServiceResult = Result<ChatResponse, ChatRetrieveServiceError>
public typealias ChatRetrieveServiceCompletion = ChatRetrieveServiceResult -> Void

public protocol ChatRetrieveService {
    
    /**
        Retrieves a chat of a user.
    
        - parameter sessionToken: The user session token.
        - parameter productId: The product id.
        - parameter buyerId: The user id of the buyer.
        - parameter completion: The completion closure.
    */
    func retrieveChatWithSessionToken(sessionToken: String, productId: String, buyerId: String, completion: ChatRetrieveServiceCompletion?)
}
