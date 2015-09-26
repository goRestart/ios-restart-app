//
//  ChatSendMessageService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ChatSendMessageServiceError: Printable {
    case Network
    case Unauthorized
    case NotFound
    case Internal
    
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
        }
    }
}

public typealias ChatSendMessageServiceResult = (Result<Message, ChatSendMessageServiceError>) -> Void

public protocol ChatSendMessageService {

    /**
        Sends a message to a given user and product.
    
        :param: sessionToken The session token.
        :param: userId The sender user id.
        :param: message The message.
        :param: type The type.
        :param: recipientUserId The recipient user id.
        :param: productId The product id.
        :param: result The completion closure.
    */
    func sendMessageWithSessionToken(sessionToken: String, userId: String, message: String, type: MessageType, recipientUserId: String, productId: String, result: ChatSendMessageServiceResult?)
}
