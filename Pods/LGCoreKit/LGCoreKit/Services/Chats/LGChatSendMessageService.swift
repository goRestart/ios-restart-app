//
//  LGChatSendMessageService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public class LGChatSendMessageService: ChatSendMessageService {
    
    public func sendMessageWithSessionToken(sessionToken: String, userId: String, message: String, type: MessageType, recipientUserId: String, productId: String, completion: ChatSendMessageServiceCompletion?) {
        
        var parameters = Dictionary<String, AnyObject>()
        parameters["type"] = type.rawValue
        parameters["content"] = message
        parameters["userTo"] = recipientUserId
        
        let request = ChatRouter.CreateMessage(objectId: productId, params: parameters)
        ApiClient.request(request, decoder: {$0}) { (result: Result<AnyObject, ApiError>) -> () in
            if let _ = result.value {
                var msg = LGMessage()
                msg.createdAt = NSDate()
                msg.userId = userId
                msg.text = message
                msg.type = type
                completion?(ChatSendMessageServiceResult(value: msg))
            } else if let error = result.error {
                completion?(ChatSendMessageServiceResult(error: ChatSendMessageServiceError(apiError: error)))
            }
        }
    }
}