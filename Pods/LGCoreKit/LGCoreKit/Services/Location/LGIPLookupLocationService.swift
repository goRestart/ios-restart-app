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
    
    public func retrieveLocationWithCompletion(completion: IPLookupLocationServiceCompletion?) {
        manager.request(.GET, url)
            .validate(statusCode: 200..<400)
            .responseObject({ (lookupLocationResponse: Response<LGIPLookupLocationResponse, NSError>) -> Void in
                // Success
                if let actualLookupLocationResponse = lookupLocationResponse.result.value {
                    completion?(IPLookupLocationServiceResult(value: actualLookupLocationResponse.coordinates))
                }
                // Error
                else if let error = lookupLocationResponse.result.error {
                    if error.domain == NSURLErrorDomain {
                        completion?(IPLookupLocationServiceResult(error: .Network))
                    }
                    else {
                        completion?(IPLookupLocationServiceResult(error: .Internal))
                    }
                }
                else {
                    completion?(IPLookupLocationServiceResult(error: .Internal))
                }
            })
    }
}
