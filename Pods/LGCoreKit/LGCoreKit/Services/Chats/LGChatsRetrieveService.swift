//
//  LGChatsRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result
import Argo

public class LGChatsRetrieveService: ChatsRetrieveService {

    public func retrieveChatsWithSessionToken(sessionToken: String, completion: ChatsRetrieveServiceCompletion?) {
        var parameters = Dictionary<String, AnyObject>()
        parameters["num_results"] = 1000

        struct CustomChatsResponse: ChatsResponse {
            var chats: [Chat]
        }

        let request = ChatRouter.Index(params: parameters)
        ApiClient.request(request, decoder: LGChatsRetrieveService.decoder) {
            (result: Result<[Chat], ApiError>) -> () in

            if let value = result.value {
                completion?(ChatsRetrieveServiceResult(value: CustomChatsResponse(chats: value)))
            } else if let error = result.error {
                completion?(ChatsRetrieveServiceResult(error: ChatsRetrieveServiceError(apiError: error)))
            }
        }
    }

    static func decoder(object: AnyObject) -> [Chat]? {
        guard let chats : [LGChat] = decode(object) else { return nil }
        return chats.map{$0}
    }
}
