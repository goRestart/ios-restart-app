//
//  LGChatsUnreadCountRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result
import Argo

public class LGChatsUnreadCountRetrieveService: ChatsUnreadCountRetrieveService {

    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
       
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    // MARK: - Public methods
    
    public func retrieveUnreadMessageCountWithSessionToken(sessionToken: String,
        completion: ChatsUnreadCountRetrieveServiceCompletion?) {

            let request = ChatRouter.UnreadCount
            apiClient.request(request, decoder: LGChatsUnreadCountRetrieveService.decoder) {
                (result: Result<Int, ApiError>) -> () in

                if let value = result.value {
                    completion?(ChatsUnreadCountRetrieveServiceResult(value: value))
                } else if let error = result.error {
                    let countError = ChatsUnreadCountRetrieveServiceError(apiError: error)
                    completion?(ChatsUnreadCountRetrieveServiceResult(error: countError))
                }
            }
    }

    static func decoder(object: AnyObject) -> Int? {
        let count: Int? = JSON.parse(object) <| "count"
        return count
    }
}
