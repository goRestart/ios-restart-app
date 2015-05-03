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
                    let myError: NSError
                    
                    if let actualData: AnyObject = data {
                        let json = JSON(actualData)
                        
                        if let errorResponse = LGSessionErrorResponse(json: json) {
                            myError = NSError(code: LGErrorCode.Internal)
                        }
                        else {
                            myError = NSError(code: LGErrorCode.Parsing)
                        }
                        completion(token: nil, error: myError)
                    }
                    else if actualError.domain == NSURLErrorDomain {
                        myError = NSError(code: LGErrorCode.Network)
                        completion(token: nil, error: myError)
                    }
                    else {
                        myError = NSError(code: LGErrorCode.Internal)
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
                        let myError = NSError(code: LGErrorCode.Parsing)
                        completion(token: nil, error: myError)
                    }
                }
            })
    }
}
