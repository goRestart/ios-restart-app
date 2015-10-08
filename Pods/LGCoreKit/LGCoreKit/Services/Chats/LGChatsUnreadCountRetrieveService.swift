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
    
    public func retrieveUnreadMessageCountWithSessionToken(sessionToken: String, result: ChatsUnreadCountRetrieveServiceResult?) {
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        Alamofire.request(.GET, url, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject { (_, httpResponse: NSHTTPURLResponse?, response: LGChatsUnreadCountResponse?, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<Int, ChatsUnreadCountRetrieveServiceError>.failure(.Network))
                    }
                    else if let statusCode = httpResponse?.statusCode {
                        switch statusCode {
                        case 401:
                            result?(Result<Int, ChatsUnreadCountRetrieveServiceError>.failure(.Unauthorized))
                        case 403:
                            result?(Result<Int, ChatsUnreadCountRetrieveServiceError>.failure(.Forbidden))
                        default:
                            result?(Result<Int, ChatsUnreadCountRetrieveServiceError>.failure(.Internal))
                        }
                    }
                    else {
                        result?(Result<Int, ChatsUnreadCountRetrieveServiceError>.failure(.Internal))
                    }
                }
                // Success
                else if let chatsUnreadCountResponse = response {
                    result?(Result<Int, ChatsUnreadCountRetrieveServiceError>.success(chatsUnreadCountResponse.count))
                }
        }
    }
}
