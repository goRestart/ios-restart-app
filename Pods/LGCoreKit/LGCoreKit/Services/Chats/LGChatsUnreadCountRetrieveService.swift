//
//  LGChatsUnreadCountRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

public class LGChatsUnreadCountRetrieveService: ChatsUnreadCountRetrieveService {

    public static let endpoint = "/api/products/messages/unread-count"

    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.url = baseURL + LGChatsUnreadCountRetrieveService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ChatsUnreadCountRetrieveService
    
    public func retrieveUnreadMessageCountWithSessionToken(sessionToken: String, completion: ChatsUnreadCountRetrieveServiceCompletion?) {
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        Alamofire.request(.GET, url, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject({ (response: Response<LGChatsUnreadCountResponse, NSError>) -> Void in
                // Success
                if let chatsUnreadCountResponse = response.result.value {
                    completion?(ChatsUnreadCountRetrieveServiceResult(value: chatsUnreadCountResponse.count))
                }
                // Error
                else if let actualError = response.result.error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ChatsUnreadCountRetrieveServiceResult(error: .Network))
                    }
                    else if let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case 401:
                            completion?(ChatsUnreadCountRetrieveServiceResult(error: .Unauthorized))
                        case 403:
                            completion?(ChatsUnreadCountRetrieveServiceResult(error: .Forbidden))
                        default:
                            completion?(ChatsUnreadCountRetrieveServiceResult(error: .Internal))
                        }
                    }
                    else {
                        completion?(ChatsUnreadCountRetrieveServiceResult(error: .Internal))
                    }
                }
            })
    }
}
