//
//  LGChatSendMessageService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

public class LGChatSendMessageService: ChatSendMessageService {
    
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
    
    // MARK: - ChatSendMessageService
    
    public func sendMessageWithSessionToken(sessionToken: String, userId: String, message: String, type: MessageType, recipientUserId: String, productId: String, completion: ChatSendMessageServiceCompletion?) {
        let url = EnvironmentProxy.sharedInstance.apiBaseURL + LGChatSendMessageService.endpointWithProductId(productId)
        var parameters = Dictionary<String, AnyObject>()
        parameters["type"] = type.rawValue
        parameters["content"] = message
        parameters["userTo"] = recipientUserId
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        Alamofire.request(.POST, url, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<400)
            .response { (_, httpResponse: NSHTTPURLResponse?, _, error: NSError?) -> Void in
                
                // Error
                if let actualError = error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ChatSendMessageServiceResult(error: .Network))
                    }
                    else if let statusCode = httpResponse?.statusCode {
                        switch statusCode {
                        case 401:
                            completion?(ChatSendMessageServiceResult(error: .Unauthorized))
                        case 403:
                            completion?(ChatSendMessageServiceResult(error: .Forbidden))
                        case 404:
                            completion?(ChatSendMessageServiceResult(error: .NotFound))
                        default:
                            completion?(ChatSendMessageServiceResult(error: .Internal))
                        }
                    }
                    else {
                        completion?(ChatSendMessageServiceResult(error: .Internal))
                    }
                }
                // Success (status code 201)
                else {
                    var msg = LGMessage()
                    msg.createdAt = NSDate()
                    msg.userId = userId
                    msg.text = message
                    msg.type = type
                    completion?(ChatSendMessageServiceResult(value: msg))
                }
        }
    }
}