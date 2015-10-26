//
//  LGContactSendService.swift
//  LGCoreKit
//
//  Created by Dídac on 04/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Alamofire
import Result

final public class LGContactSendService: ContactSendService {
    
    // Constants
    public static let endpoint = "/api/contacts"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        
        self.url = baseURL + LGContactSendService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ContactSendService
    
    public func sendContact(contact: Contact, sessionToken: String, completion: ContactSendServiceCompletion?) {
        
        var params = Dictionary<String, AnyObject>()
        
        params["email"] = contact.email
        params["title"] = contact.title
        params["description"] = contact.message

        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]

        Alamofire.request(.POST, url, parameters: params, headers: headers)
            .validate(statusCode: 200..<400)
            .response { (request, response, _, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ContactSendServiceResult(error: .Network))
                    }
                    else {
                        completion?(ContactSendServiceResult(error: .Internal))
                    }
                } else {
                    if response?.statusCode == 201 {
                        // success
                        completion?(ContactSendServiceResult(value: contact))
                    } else {
                        // error
                        completion?(ContactSendServiceResult(error: .Internal))
                    }
                }
        }
    }
}