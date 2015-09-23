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
    
    public func retrieveChatsWithSessionToken(sessionToken: String, result: ChatsRetrieveServiceResult?) {
        var parameters = Dictionary<String, AnyObject>()
        parameters["num_results"] = 1000
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        Alamofire.request(.GET, url, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject { (req, httpResponse: NSHTTPURLResponse?, response: LGChatsResponse?, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<ChatsResponse, ChatsRetrieveServiceError>.failure(.Network))
                    }
                    else if let statusCode = httpResponse?.statusCode {
                        switch statusCode {
                        case 401:
                            result?(Result<ChatsResponse, ChatsRetrieveServiceError>.failure(.Unauthorized))
                        default:
                            result?(Result<ChatsResponse, ChatsRetrieveServiceError>.failure(.Internal))
                        }
                    }
                    else {
                        result?(Result<ChatsResponse, ChatsRetrieveServiceError>.failure(.Internal))
                    }
                }
                // Success
                else if let chatsResponse = response {
                    result?(Result<ChatsResponse, ChatsRetrieveServiceError>.success(chatsResponse))
                }
        }
    }
}