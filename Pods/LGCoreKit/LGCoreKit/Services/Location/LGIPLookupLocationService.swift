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
    private var manager: Manager
    
    // MARK: - Lifecycle
    
    public init(baseURL: String, manager: Manager) {
        self.url = baseURL + LGIPLookupLocationService.endpoint
        self.manager = manager
    }
    
    public convenience init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = LGCoreKitConstants.locationRetrievalTimeout
        configuration.timeoutIntervalForResource = LGCoreKitConstants.locationRetrievalTimeout
        let manager = Alamofire.Manager(configuration: configuration)
        
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL, manager: manager)
    }
    
    // MARK: - IPLookupLocationService
    
    public func retrieveLocation(result: IPLookupLocationServiceResult?) {
        manager.request(.GET, url)
            .validate(statusCode: 200..<400)
            .responseObject { (_, _, lookupLocationResponse: LGIPLookupLocationResponse?, error: NSError?) -> Void in
                // Success
                if let actualLookupLocationResponse = lookupLocationResponse {
                    result?(Result<LGLocationCoordinates2D, IPLookupLocationServiceError>.success(actualLookupLocationResponse.coordinates))
                }
                // Error
                else if let actualError = error {
                    let myError: NSError
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<LGLocationCoordinates2D, IPLookupLocationServiceError>.failure(.Network))
                    }
                    else {
                        result?(Result<LGLocationCoordinates2D, IPLookupLocationServiceError>.failure(.Internal))
                    }
                }
                else {
                    result?(Result<LGLocationCoordinates2D, IPLookupLocationServiceError>.failure(.Internal))
                }
        }   
    }
}
