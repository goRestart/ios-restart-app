//
//  LGChatsRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

public class LGChatsRetrieveService: ChatsRetrieveService {
    
    // Constants
    public static let endpoint = "/api/products/messages"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.url = baseURL + LGChatsRetrieveService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ChatsRetrieveService
    
    public func retrieveChatsWithSessionToken(sessionToken: String, completion: ChatsRetrieveServiceCompletion?) {
        var parameters = Dictionary<String, AnyObject>()
        parameters["num_results"] = 1000
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        Alamofire.request(.GET, url, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject({ (response: Response<LGChatsResponse, NSError>) -> Void in
                // Success
                if let chatsResponse = response.result.value {
                    completion?(ChatsRetrieveServiceResult(value: chatsResponse))
                }
                // Error
                else if let actualError = response.result.error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ChatsRetrieveServiceResult(error: .Network))
                    }
                    else if let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case 401:
                            completion?(ChatsRetrieveServiceResult(error: .Unauthorized))
                        case 403:
                            completion?(ChatsRetrieveServiceResult(error: .Forbidden))
                        default:
                            completion?(ChatsRetrieveServiceResult(error: .Internal))
                        }
                    }
                    else {
                        completion?(ChatsRetrieveServiceResult(error: .Internal))
                    }
                }
            })
    }
}