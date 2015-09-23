//
//  LGChatRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

public class LGChatRetrieveService: ChatRetrieveService {
    
    // Constants
    public static func endpointWithProductId(productId: String) -> String {
        return "/api/products/\(productId)/messages"
    }
    
    // iVars
    var baseURL: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ChatsRetrieveService
    
    public func retrieveChatWithSessionToken(sessionToken: String, productId: String, buyerId: String, result: ChatRetrieveServiceResult?) {

        let url = EnvironmentProxy.sharedInstance.apiBaseURL + LGChatRetrieveService.endpointWithProductId(productId)
        var parameters = Dictionary<String, AnyObject>()
        parameters["buyer"] = buyerId
        parameters["productId"] = productId
        parameters["num_results"] = 1000
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        Alamofire.request(.GET, url, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject { (req, httpResponse: NSHTTPURLResponse?, response: LGChatResponse?, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<ChatResponse, ChatRetrieveServiceError>.failure(.Network))
                    }
                    else if let statusCode = httpResponse?.statusCode {
                        switch statusCode {
                        case 401:
                            result?(Result<ChatResponse, ChatRetrieveServiceError>.failure(.Unauthorized))
                        case 404:
                            result?(Result<ChatResponse, ChatRetrieveServiceError>.failure(.NotFound))
                        default:
                            result?(Result<ChatResponse, ChatRetrieveServiceError>.failure(.Internal))
                        }
                    }
                    else {
                        result?(Result<ChatResponse, ChatRetrieveServiceError>.failure(.Internal))
                    }
                }
                // Success
                else if let chatResponse = response {
                    result?(Result<ChatResponse, ChatRetrieveServiceError>.success(chatResponse))
                }
        }
    }
}