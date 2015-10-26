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
    
    public func retrieveChatWithSessionToken(sessionToken: String, productId: String, buyerId: String, completion: ChatRetrieveServiceCompletion?) {

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
            .responseObject { (response: Response<LGChatResponse, NSError>) in
                if let chatResponse = response.result.value {
                    completion?(ChatRetrieveServiceResult(value: chatResponse))
                }
                else if let error = response.result.error {
                    if error.domain == NSURLErrorDomain {
                        completion?(ChatRetrieveServiceResult(error: .Network))
                    }
                    else if let statusCode =  response.response?.statusCode {
                        switch statusCode {
                        case 401:
                            completion?(ChatRetrieveServiceResult(error: .Unauthorized))
                        case 403:
                            completion?(ChatRetrieveServiceResult(error: .Forbidden))
                        case 404:
                            completion?(ChatRetrieveServiceResult(error: .NotFound))
                        default:
                            completion?(ChatRetrieveServiceResult(error: .Internal))
                        }
                    }
                    else {
                        completion?(ChatRetrieveServiceResult(error: .Internal))
                    }
                }
        }
    }
}