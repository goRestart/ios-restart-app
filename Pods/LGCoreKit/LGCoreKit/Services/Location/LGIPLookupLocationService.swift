//
//  LGIPLookupLocationService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

final public class LGIPLookupLocationService: IPLookupLocationService {
    
    // Constants
    public static let endpoint = "/api/iplookup.json"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.url = baseURL + LGIPLookupLocationService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - IPLookupLocationService
    
    public func retrieveLocation(result: IPLookupLocationServiceResult?) {
        Alamofire.request(.GET, url)
            .validate(statusCode: 200..<400)
            .responseObject { (_, _, lookupLocationResponse: LGIPLookupLocationResponse?, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    let myError: NSError
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<LGLocationCoordinates2D, IPLookupLocationServiceError>.failure(.Network))
                    }
                    else {
                        result?(Result<LGLocationCoordinates2D, IPLookupLocationServiceError>.failure(.Internal))
                    }
                }
                    // Success
                else if let actualLookupLocationResponse = lookupLocationResponse {
                    result?(Result<LGLocationCoordinates2D, IPLookupLocationServiceError>.success(actualLookupLocationResponse.coordinates))
                }
        }   
    }
}
