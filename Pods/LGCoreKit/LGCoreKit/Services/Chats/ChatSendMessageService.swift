//
//  ChatSendMessageService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ChatSendMessageServiceError: ErrorType, CustomStringConvertible {
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
    
    init(apiError: ApiError) {
        switch apiError {
        case .Network:
            self = .Network
        case .Scammer:
            self = .Forbidden
        case .NotFound:
            self = .NotFound
        case .Internal, .Unauthorized, .AlreadyExists, .InternalServerError:
            self = .Internal
        }
    }
}

public typealias ChatSendMessageServiceResult = Result<Message, ChatSendMessageServiceError>
public typealias ChatSendMessageServiceCompletion = ChatSendMessageServiceResult -> Void

public protocol ChatSendMessageService {

    /**
        Sends a message to a given user and product.
    
        - parameter sessionToken: The session token.
        - parameter userId: The sender user id.
        - parameter message: The message.
        - parameter type: The type.
        - parameter recipientUserId: The recipient user id.
        - parameter productId: The product id.
        - parameter completion: The completion closure.
    */
    func sendMessageWithSessionToken(sessionToken: String, userId: String, message: String, type: MessageType, recipientUserId: String, productId: String, completion: ChatSendMessageServiceCompletion?)
}
