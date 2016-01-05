//
//  LGChatRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result
import Argo

public class LGChatRetrieveService: ChatRetrieveService {
        
    public func retrieveChatWithSessionToken(sessionToken: String, productId: String, buyerId: String,
        completion: ChatRetrieveServiceCompletion?) {
        
        var parameters = Dictionary<String, AnyObject>()
        parameters["buyer"] = buyerId
        parameters["productId"] = productId
        parameters["num_results"] = 1000
        
        struct CustomChatResponse: ChatResponse {
            var chat: Chat
        }
        
        let request = ChatRouter.Show(objectId: productId, params: parameters)
        ApiClient.request(request, decoder: LGChatRetrieveService.decoder) { (result: Result<Chat, ApiError>) -> () in
            if let value = result.value {
                completion?(ChatRetrieveServiceResult(value: CustomChatResponse(chat: value)))
            } else if let error = result.error {
                completion?(ChatRetrieveServiceResult(error: ChatRetrieveServiceError(apiError: error)))
            }
        }
    }

    static func decoder(object: AnyObject) -> Chat? {
        let chat: LGChat? = decode(object)
        return chat
    }
}