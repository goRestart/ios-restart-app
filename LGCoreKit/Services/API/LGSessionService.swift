//
//  LGSessionService.swift
//  LGCoreKit
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON

final public class LGSessionService: SessionService {

    // Constants
    public static let endpoint = "/oauth/v2/token"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        url = baseURL + LGSessionService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - SessionService
    
    public func retrieveTokenWithParams(params: RetrieveTokenParams, completion: RetrieveTokenCompletion) {
        let params = ["client_id": params.clientId, "client_secret": params.clientSecret, "grant_type": "client_credentials"]
        Alamofire.request(.GET, url, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON(options: nil, completionHandler: {
                (request: NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
            
                // Error
                if let actualError = error {
                    if let actualData: AnyObject = data {
                        let json = JSON(actualData)
                        let myError: LGError
                        
                        if let errorResponse = LGSessionErrorResponse(json: json) {
                            myError = LGError(type: .Server(.Session), explanation: errorResponse.error)
                        }
                        else {
                            myError = LGError(type: .Internal(.Parsing), explanation: "Unexpected JSON format")
                        }
                        completion(token: nil, error: myError)
                    }
                    else if actualError.domain == NSURLErrorDomain {
                        let myError: LGError = LGError(type: .Network, explanation: actualError.localizedDescription)
                        completion(token: nil, error: myError)
                    }
                    else {
                        let myError: LGError = LGError(type: .Internal(LGInternalErrorCode.Unexpected), explanation: actualError.localizedDescription)
                        completion(token: nil, error: myError)
                    }
                }
                // Success
                else if let actualData: AnyObject = data {
                    let json = JSON(actualData)
                    if let token = LGSessionToken(json: json) {
                        completion(token: token, error: nil)
                    }
                    else {
                        let myError: LGError = LGError(type: .Internal(.Parsing))
                        completion(token: nil, error: myError)
                    }
                }
            })
    }
}
